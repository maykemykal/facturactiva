package com.facturactiva.app.util;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

	@Autowired
    private PropertiesExterno propertiesExterno;
	
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOrigins(propertiesExterno.FRONT_URL)
                .allowedMethods(Constantes.GET, Constantes.POST, Constantes.PUT, Constantes.DELETE)
                .allowedHeaders(Constantes.ASTERISCO)
                .allowCredentials(true);
    }
}