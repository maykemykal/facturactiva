package com.facturactiva.app.util;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class PropertiesExterno {

    @Value("${spring.datasource.sp}")
    public String SP_VERIFICAR_USER;
    
    @Value("${spring.web.url}")
    public String FRONT_URL;
}
