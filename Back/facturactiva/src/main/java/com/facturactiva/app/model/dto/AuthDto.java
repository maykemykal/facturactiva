package com.facturactiva.app.model.dto;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

import com.facturactiva.app.model.entity.AuthResponse;
import com.facturactiva.app.util.Constantes;
import com.facturactiva.app.util.PropertiesExterno;

import java.sql.Types;
import java.util.HashMap;
import java.util.Map;

@Repository
public class AuthDto {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private PropertiesExterno propertiesExterno;

    public AuthResponse verificarUsuario(String username, String password) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
            .withProcedureName(propertiesExterno.SP_VERIFICAR_USER)
            .declareParameters(
                new SqlParameter(Constantes.PARAM_USERNAME, Types.VARCHAR),
                new SqlParameter(Constantes.PARAM_PASSWORD, Types.VARCHAR),
                new SqlOutParameter(Constantes.PARAM_ROLE_NAME, Types.VARCHAR),
                new SqlOutParameter(Constantes.PARAM_MESSAGE, Types.VARCHAR)
            );

        // Agregar parámetros de entrada y salida
        Map<String, Object> params = new HashMap<>();
        params.put(Constantes.PARAM_USERNAME, username);
        params.put(Constantes.PARAM_PASSWORD, password);
        params.put(Constantes.PARAM_ROLE_NAME, null);
        params.put(Constantes.PARAM_MESSAGE, null);

        Map<String, Object> result = jdbcCall.execute(params);

        String roleName = (String) result.get(Constantes.PARAM_ROLE_NAME);
        String message = (String) result.get(Constantes.PARAM_MESSAGE);

        return new AuthResponse(roleName, message);
    }
}
