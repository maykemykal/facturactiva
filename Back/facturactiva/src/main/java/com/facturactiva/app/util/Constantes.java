package com.facturactiva.app.util;

public class Constantes {
	
    // PARAMETROS DEL SP
    public static final String PARAM_USERNAME = "username";
    public static final String PARAM_PASSWORD = "psw";
    public static final String PARAM_ROLE_NAME = "roleName";
    public static final String PARAM_MESSAGE = "mensaje";

    // MENSAJES DE AUTENTICACION
    public static final String MSG_AUTH_SUCCESS = "Autenticación exitosa";
    public static final String MSG_AUTH_FAILURE = "Usuario o contraseña incorrectos";

    // NOMBRE DE TABLAS
    public static final String TABLE_USERS = "Users";
    public static final String TABLE_ROLES = "Roles";
    public static final String COLUMN_USER_ID = "userId";
    public static final String COLUMN_USER_NAME = "userName";
    public static final String COLUMN_PASSWORD = "psw";
    public static final String COLUMN_ROLE_ID = "roleIdUsers";
    public static final String COLUMN_ROLE_NAME = "roleName";
    public static final String OUT_MENSAJE = "mensaje";
    public static final String OUT_ROLE_NAME = "roleName";

    // POSIBLES ERRORES
    public static final String DATABASE_ERROR = "ERROR_DB";
    public static final String INVALID_CREDENTIALS = "INVALID_CREDENTIALS";
    public static final String UNKNOWN_ERROR = "UNKNOWN_ERROR";
    public static final String INVALID_INPUT = "ERROR_INVALID_INPUT";
    
    // METODOS
    public static final String GET = "GET";
    public static final String POST = "POST";
    public static final String PUT = "PUT";
    public static final String DELETE = "DELETE";
    
    // CARACTERES EXTRAÑOS
    public static final String ASTERISCO = "*";
    public static final String UNO = "1";
    
    private Constantes() {
        
    }
}
