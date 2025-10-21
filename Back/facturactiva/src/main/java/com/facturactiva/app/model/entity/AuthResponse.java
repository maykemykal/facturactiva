package com.facturactiva.app.model.entity;

public class AuthResponse {
    private String roleName;
    private String message;

    public AuthResponse(String roleName, String message) {
        this.roleName = roleName;
        this.message = message;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
