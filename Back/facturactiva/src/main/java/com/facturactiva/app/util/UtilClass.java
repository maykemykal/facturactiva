package com.facturactiva.app.util;

import java.util.Base64;
import java.util.Collection;

public class UtilClass {

    public static String encode(String input) {
        if (input == null || input.isEmpty()) {
            return input;
        }
        return Base64.getEncoder().encodeToString(input.getBytes());
    }
    
    public static boolean isNullOrEmpty(Object value) {
        if (value == null) {
            return true;
        }
        
        // Validación para String
        if (value instanceof String) {
            return ((String) value).isEmpty();
        }
        
        // Validación para Collection
        if (value instanceof Collection) {
            return ((Collection<?>) value).isEmpty();
        }
        
        // Validación para Array
        if (value.getClass().isArray()) {
            return java.lang.reflect.Array.getLength(value) == 0;
        }
        
        return false;
    }
}
