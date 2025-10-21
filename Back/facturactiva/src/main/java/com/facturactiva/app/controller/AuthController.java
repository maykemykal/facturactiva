package com.facturactiva.app.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.facturactiva.app.model.entity.AuthRequest;
import com.facturactiva.app.model.entity.AuthResponse;
import com.facturactiva.app.service.FacturactivaService;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private FacturactivaService authService;

    @PostMapping("/validarLogin")
    public AuthResponse validarLogin(@RequestBody AuthRequest request) {
        return authService.authenticateUser(request);
    }
}
