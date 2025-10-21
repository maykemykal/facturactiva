package com.facturactiva.app.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.facturactiva.app.model.dto.AuthDto;
import com.facturactiva.app.model.entity.AuthRequest;
import com.facturactiva.app.model.entity.AuthResponse;
import com.facturactiva.app.util.Constantes;
import com.facturactiva.app.util.UtilClass;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

@Service
public class FacturactivaService {

    private static final Logger logger = LogManager.getLogger(FacturactivaService.class);

    @Autowired
    private AuthDto authRepository;

    public AuthResponse authenticateUser(AuthRequest request) {
        if (request == null) {
            logger.error("Solicitud de autenticación nula");
            return new AuthResponse(null, Constantes.INVALID_INPUT);
        }

        if (request.getUsername() == null || request.getUsername().isEmpty() ||
            request.getPassword() == null || request.getPassword().isEmpty()) {
            logger.warn("Intento de login con campos vacíos");
            return new AuthResponse(null, Constantes.INVALID_INPUT);
        }

        String username = request.getUsername();

        try {
            logger.info("Intentando autenticar usuario: {}", username);

            String encodedPassword = UtilClass.encode(request.getPassword());
            AuthResponse response = authRepository.verificarUsuario(username, encodedPassword);

            if (response == null || response.getRoleName() == null || response.getMessage() == null) {
                logger.warn("Autenticación fallida para usuario: {}", username);
                return new AuthResponse(null, Constantes.MSG_AUTH_FAILURE);
            }

            logger.info("Usuario autenticado con éxito: {}, Rol: {}", username, response.getRoleName());
            return response;

        } catch (Exception e) {
            logger.error("Error en autenticación para usuario: {}", username, e);
            return new AuthResponse(null, Constantes.DATABASE_ERROR);
        }
    }
}
