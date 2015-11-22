---
layout: post
title:  "Spring Boot Security in distributed system"
date:   2015-11-20 14:03
categories: java
tags: java spring spring-boot spring-security redis distributed-system
author: Łukasz Stypka
---
Spring Security is indispensable part of every enterprise Spring based application. Everything looks pretty easy, when you want to secure single web-application. Unfortunately, everything looks completely different when your system consists of many components. In that cases the expected behavior is single login for whole system, not separate login for each web-services. Suppose, you have two RESTful web-services. Application should allow a user to login, receive session token and give access to resources of both services using the token.
At this point we come across the first problem. Spring does not support authentication by JSON object out of the box. In order to send credentials as json object, we have to write some handlers. But let's start from the beginning. 

*__All sources for this project you can find on my github repository:__

[https://github.com/lstypka/spring-security-distributed-system](https://github.com/lstypka/spring-security-distributed-system)

{% highlight text %}
|-pom.xml
|--\client1
|--\client2
|--\security-config
{% endhighlight %}

The client1 and the client2 will be RESTful web-services with single endpoint. The security-config will be heart of this article - this project will include whole security stuff, some JSON handlers and filters as well.

Parent pom.xml
{% highlight xml %}
...
 <properties>
        <java.version>1.8</java.version>
        <spring.boot.version>1.3.0.RELEASE</spring.boot.version>
        <spring.session.version>1.0.2.RELEASE</spring.session.version>
    </properties>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-dependencies</artifactId>
                <version>${spring.boot.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-starter-web</artifactId>
                <version>${spring.boot.version}</version>
            </dependency>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-starter-security</artifactId>
                <version>${spring.boot.version}</version>
            </dependency>
            <dependency>
                <groupId>org.springframework.session</groupId>
                <artifactId>spring-session-data-redis</artifactId>
                <version>${spring.session.version}</version>
                <type>pom</type>
            </dependency>
        </dependencies>

    </dependencyManagement>
...
{% endhighlight %}

client1 and client2 pom.xml
{% highlight xml %}
...
 <dependencies>
        <dependency>
            <groupId>pl.lstypka.spring-security-distributed-system</groupId>
            <artifactId>security-config</artifactId>
            <version>1.0-SNAPSHOT</version>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
	...
{% endhighlight %}


security-config pom.xml
{% highlight java %}
...
 <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.session</groupId>
            <artifactId>spring-session-data-redis</artifactId>
            <type>pom</type>
        </dependency>
 </dependencies>
...
{% endhighlight %}

Once we have the basic projects configuration, we can proceed to something more interesting. The first thing will be configuring spring security in our project. 
For this purpose we'll create `SecurityConfig` class which extends `WebSecurityConfigurerAdapter`. 


{% highlight java %}
public class SecurityConfig extends WebSecurityConfigurerAdapter {

    private final static String AUTHENTICATE_ENDPOINT = "/authenticate";

   
    // Beans connected with translating input and output to JSON
    @Bean
    AuthenticationFailureHandler authenticationFailureHandler() {
        return new AuthenticationFailureHandler();
    }

    @Bean
    AuthenticationSuccessHandler authenticationSuccessHandler() {
        return new AuthenticationSuccessHandler();
    }

    @Bean
    RestAuthenticationEntryPoint restAuthenticationEntryPoint() {
        return new RestAuthenticationEntryPoint();
    }

    // Bean responsible for getting information about user details
    @Bean
    AuthService authService() {
        return new AuthService();
    }
	
    @Bean
    public CustomUsernamePasswordAuthenticationFilter authenticationFilter() throws Exception {
        CustomUsernamePasswordAuthenticationFilter authFilter = new CustomUsernamePasswordAuthenticationFilter();
        authFilter.setRequiresAuthenticationRequestMatcher(new AntPathRequestMatcher(AUTHENTICATE_ENDPOINT, "POST"));
        authFilter.setAuthenticationManager(super.authenticationManager());
        authFilter.setAuthenticationSuccessHandler(authenticationSuccessHandler());
        authFilter.setAuthenticationFailureHandler(authenticationFailureHandler());
        authFilter.setUsernameParameter("j_username");
        authFilter.setPasswordParameter("j_password");
        return authFilter;
    }
	
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.exceptionHandling().authenticationEntryPoint(restAuthenticationEntryPoint())
		.and().addFilterBefore(authenticationFilter(), CustomUsernamePasswordAuthenticationFilter.class)
		.csrf().disable().authorizeRequests().antMatchers("/**").authenticated().and().formLogin()
		.loginProcessingUrl(AUTHENTICATE_ENDPOINT).failureHandler(authenticationFailureHandler())
		.successHandler(authenticationSuccessHandler()).and().logout();
    }

    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
        auth.userDetailsService(authService());
    }
}
{% endhighlight %}

As you can see, there are two overridden configure methods. Inside the first one I have added some filters, handlers, and I have indicated that all request should be protected (authorizeRequests().antMatchers("/**").authenticated()). I've also configured login endpoint as ("/authenticate"). We will back in a moment to discuss the `AuthenticationFailureHandler`, `AuthenticationSuccessHandler` and `CustomUsernamePasswordAuthenticationFilter`. First, I would like to take a minute to highlight the `AuthService` class. It's simple service class which implements `org.springframework.security.core.userdetails.UserDetailsService` interface. The class is responsible for provide information about user. Example implementation:
{% highlight java %}
@Service("authService")
public class AuthService implements UserDetailsService {

	@Override
	public SecurityUser loadUserByUsername(String username) {
		List<GrantedAuthority> authorities = new ArrayList<>();
		if("admin".equals(username)) {
			authorities.add(()-> "ROLE_ADMIN");
			return new SecurityUser(1L, username, "s3cr3t", authorities);
		}
		if("user".equals(username)) {
			authorities.add(()-> "ROLE_USER");
			return new SecurityUser(2L, username, "s3cr3t", authorities);
		}

		throw new UserNotFoundException("User %s not found".format(username));
	};

	public UserDto getLoggedUser() {
		SecurityUser securityUser = (SecurityUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
		return new UserDto(securityUser.getUserNo(), securityUser.getUsername(), securityUser.getAuthorities().stream().map(x -> x.getAuthority()).collect(Collectors.toList()));
	};

}
{% endhighlight %}

As you can see, current implementation allows to login users: 'user' and 'admin'. This implementation makes sense only for tests, and production implementation should invoke some repositories to get real user details. 

The key thing that is needed to send credentials as JSON object is writing custom filter which extends `UsernamePasswordAuthenticationFilter`. 

{% highlight java %}
public class CustomUsernamePasswordAuthenticationFilter extends UsernamePasswordAuthenticationFilter {

	private final static String USERNAME = "user";
	private final static String PASSWORD = "password";
	private final static String CONTENT_TYPE = "Content-Type";

	@Override
	protected String obtainPassword(HttpServletRequest request) {
		if (request.getHeader(CONTENT_TYPE).contains("application/json")) {
			return (String) request.getAttribute(PASSWORD);
		} else {
			return super.obtainPassword(request);
		}
	}

	@Override
	protected String obtainUsername(HttpServletRequest request) {
		if (request.getHeader(CONTENT_TYPE).contains("application/json")) {
			return (String) request.getAttribute(USERNAME);
		} else {
			return super.obtainUsername(request);
		}
	}

	@Override
	public Authentication attemptAuthentication(HttpServletRequest request, HttpServletResponse response) {
		if (request.getHeader(CONTENT_TYPE).contains("application/json")) {
			try {
				/*
				 * HttpServletRequest can be read only once
				 */
				StringBuffer sb = new StringBuffer();
				String line = null;

				BufferedReader reader = request.getReader();
				while ((line = reader.readLine()) != null) {
					sb.append(line);
				}

				// json transformation
				ObjectMapper mapper = new ObjectMapper();
				LoginRequestDto loginRequest = mapper.readValue(sb.toString(), LoginRequestDto.class);

				// persist user and password as request attribute
				request.setAttribute(USERNAME, loginRequest.getUser());
				request.setAttribute(PASSWORD, loginRequest.getPassword());
			} catch (IOException e) {
				throw new RuntimeException(e.getMessage());
			}
		}

		return super.attemptAuthentication(request, response);
	}
}
{% endhighlight %}

This filter provides information about username and password for security spring. But, what about situation when credentials are incorrect. 
RESTful service should return appropriate Http code and error as a JSON object. To do this, we have to create `AuthenticationSuccessHandler`:

{% highlight java %}
public class AuthenticationFailureHandler extends SimpleUrlAuthenticationFailureHandler {

	@Override
	public void onAuthenticationFailure(HttpServletRequest request, HttpServletResponse response, AuthenticationException exception) throws IOException, ServletException {
		response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
		PrintWriter writer = response.getWriter();
		ObjectMapper mapper = new ObjectMapper();
		FaultDto faultDto = new FaultDto("SPRING-SECURITY-1", exception.getMessage());
		writer.println(mapper.writeValueAsString(faultDto));
	}
}
{% endhighlight %}

In the case of valid credentials, we should return response as a JSON object too. In the following example, I return object consists of userNo, username and list of roles. 
{% highlight java %}
public class AuthenticationSuccessHandler extends SimpleUrlAuthenticationSuccessHandler {

	@Override
	public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response, Authentication authentication) throws ServletException, IOException {
		SecurityUser userSecurity =  (SecurityUser) authentication.getPrincipal();
		ObjectMapper mapper = new ObjectMapper();
		PrintWriter writer = response.getWriter();

		UserDto userDto = new UserDto(userSecurity.getUserNo(), userSecurity.getUsername(), userSecurity.getAuthorities().stream().map(x -> x.getAuthority()).collect(Collectors.toList()));

		mapper.writeValue(writer, userDto);
		writer.flush();
	}
}
{% endhighlight %}

At this moment, we have a fully working configuration of Spring Security with JSON credentials. Now, you can add endpoint and configuration to client1 application:

Example endpoint:
{% highlight java %}
@RestController
public class HomeController {

    @RequestMapping("/time")
    public String getTime() {
        return LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME);
    }

}
{% endhighlight %}

SpringBoot application:
{% highlight java %}
@SpringBootApplication
@ComponentScan({"pl.lstypka.springSecurityDistributedSystem.client1"})
@Import({SecurityConfig.class})
public class Application {

    public static void main(String[] args) throws Throwable {
        SpringApplication.run(Application.class, args);
    }

}
{% endhighlight %}

You can run main method from your IDE or execute the following command in your terminal:
`mvn spring-boot:run -Dserver.port=8099`

If you try to invoke the endpoint http://localhost:8099/time , you will receive the following error:

{% highlight javaScript %}
{
	"errorCode" : "SPRING-SECURITY-1",
	"message" : "Full authentication is required to access this resource"
}
{% endhighlight %}
It shouldn't be a surprise, because we have forgotten about authorisation. We have defined authentication endpoint as '\authenticate', so let's send credentials there

{% highlight java %}
curl -X POST http://localhost:8099/authenticate 
     -H "Content-Type: application/json" -d "{\"user\" : \"admin\", \"password\" : \"s3cr3t\"}" -v
{% endhighlight %}

Result is easy to predict:
{% highlight java %}
* Connected to localhost (::1) port 8099 (#0)
> POST /authenticate HTTP/1.1
> User-Agent: curl/7.30.0
> Host: localhost:8099
> Accept: */*
> Content-Type: application/json
> Content-Length: 41
>
* upload completely sent off: 41 out of 41 bytes
< HTTP/1.1 200 OK
* Server Apache-Coyote/1.1 is not blacklisted
< Server: Apache-Coyote/1.1
< X-Content-Type-Options: nosniff
< X-XSS-Protection: 1; mode=block
< Cache-Control: no-cache, no-store, max-age=0, must-revalidate
< Pragma: no-cache
< Expires: 0
< X-Frame-Options: DENY
< Set-Cookie: SESSION=449b0dce-cad9-4aa5-9b27-8896b20265ae; Path=/; HttpOnly
< Content-Length: 54
< Date: Sat, 21 Nov 2015 20:12:44 GMT
<
{"userNo":1,"username":"admin","roles":["ROLE_ADMIN"]}
{% endhighlight %}

Once we have a session id, we can try invoke `curl http://localhost:8099/time --cookie "SESSION=449b0dce-cad9-4aa5-9b27-8896b20265ae"` once again. This time with success. Unfortunately, when you try to invoke similar endpoint for client2, you will receive "Full authentication is required to access this resource" error. This is understandable, because the security context is not shared. So what should we do to have such an opportunity? We should use redis as  database of session tokens. First of all, you need to install redis on your computer. If you use Windows, you will find appropriate installer here: [https://github.com/MSOpenTech/redis/releases](https://github.com/MSOpenTech/redis/releases)
Installers for other systems are available here: [http://redis.io/download](http://redis.io/download)

To use Redis in our application we need to add dependency to security-config pom.xml:
{% highlight xml %}
<dependency>
    <groupId>org.springframework.session</groupId>
    <artifactId>spring-session-data-redis</artifactId>
    <type>pom</type>
</dependency>
{% endhighlight %}

Spring configuration is quite simple: one annotation `@EnableRedisHttpSession` above  `SecurityConfig` class, and two beans within this class:
{% highlight java %}
@EnableRedisHttpSession
public class SecurityConfig extends WebSecurityConfigurerAdapter {
	
	...

    // These beans are required to sharing session tokens (in the redis database) between applications
    @Bean
    public JedisConnectionFactory connectionFactory() {
        return new JedisConnectionFactory();
    }

    @Bean
    public HttpSessionStrategy httpSessionStrategy() {
        return new HeaderHttpSessionStrategy();
    }
	
	...
}
{% endhighlight %} 

Let's try invoke `\authenticate` endpoint once again. Response is similar to previous one, but there is one additional `x-auth-token` header.
If you want to invoke `http://localhost:8099/time`, you have to remember resend `x-auth-token`. You can also invoke any endpoint on the client2 by using the token generated within the client1. Everything will work correctly. 

__All sources for this project you can find on my github repository:__

[https://github.com/lstypka/spring-security-distributed-system](https://github.com/lstypka/spring-security-distributed-system)
