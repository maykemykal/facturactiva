-- =============================================
-- SCRIPTS - FACTURACTIVA
-- =============================================

-- Crear la base de datos
CREATE DATABASE facturactiva;
GO

USE facturactiva;
GO

-- =============================================
-- 1. TABLAS MAESTRAS (DIMENSIONES)
-- =============================================

-- 1.1 TABLA DE ROLES
CREATE TABLE Roles (
    id_rol INT IDENTITY(1,1) PRIMARY KEY,
    nombre_rol VARCHAR(50) UNIQUE NOT NULL
);
GO

-- 1.2 TABLA DE ESTADOS DEL TICKET
CREATE TABLE Estados (
    id_estado INT IDENTITY(1,1) PRIMARY KEY,
    nombre_estado VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255) NULL
);
GO

-- 1.3 TABLA DE PRIORIDADES
CREATE TABLE Prioridades (
    id_prioridad INT IDENTITY(1,1) PRIMARY KEY,
    nombre_prioridad VARCHAR(20) UNIQUE NOT NULL,
    nivel INT UNIQUE NOT NULL
);
GO

-- 1.4 TABLA DE TIPOS DE COMPROBANTE
CREATE TABLE TiposComprobante (
    id_comprobante INT IDENTITY(1,1) PRIMARY KEY,
    nombre_comprobante VARCHAR(100) UNIQUE NOT NULL
);
GO

-- =============================================
-- 2. TABLAS TRANSACCIONALES Y DE USUARIOS
-- =============================================

-- 2.1 TABLA DE USUARIOS
CREATE TABLE Usuarios (
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,
    id_rol INT NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NULL,
    fecha_registro DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),
    activo BIT DEFAULT 1,
    CONSTRAINT FK_Usuarios_Roles FOREIGN KEY (id_rol) REFERENCES Roles(id_rol)
);
GO

-- 2.2 TABLA DE TICKETS (Centro del sistema)
CREATE TABLE Tickets (
    id_ticket INT IDENTITY(1,1) PRIMARY KEY,
    -- Relaciones con Usuarios
    id_usuario_cliente INT NOT NULL,
    id_usuario_agente INT NULL,
    id_usuario_jefe INT NULL,
    -- Clasificación
    id_estado INT NOT NULL,
    id_prioridad INT NOT NULL,
    id_tipo_comprobante INT NOT NULL,
    -- Contenido
    asunto VARCHAR(255) NOT NULL,
    descripcion TEXT NOT NULL,
    numero_documento_rechazado VARCHAR(50) NULL,
    -- Fechas
    fecha_creacion DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),
    fecha_ultima_actualizacion DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),
    fecha_cierre DATETIMEOFFSET NULL,
    -- Constraints
    CONSTRAINT FK_Tickets_Cliente FOREIGN KEY (id_usuario_cliente) REFERENCES Usuarios(id_usuario),
    CONSTRAINT FK_Tickets_Agente FOREIGN KEY (id_usuario_agente) REFERENCES Usuarios(id_usuario),
    CONSTRAINT FK_Tickets_Jefe FOREIGN KEY (id_usuario_jefe) REFERENCES Usuarios(id_usuario),
    CONSTRAINT FK_Tickets_Estados FOREIGN KEY (id_estado) REFERENCES Estados(id_estado),
    CONSTRAINT FK_Tickets_Prioridades FOREIGN KEY (id_prioridad) REFERENCES Prioridades(id_prioridad),
    CONSTRAINT FK_Tickets_TiposComprobante FOREIGN KEY (id_tipo_comprobante) REFERENCES TiposComprobante(id_comprobante)
);
GO

-- 2.3 TABLA DE COMENTARIOS/INTERACCIONES
CREATE TABLE Comentarios (
    id_comentario INT IDENTITY(1,1) PRIMARY KEY,
    id_ticket INT NOT NULL,
    id_usuario INT NOT NULL,
    contenido TEXT NOT NULL,
    fecha_creacion DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),
    tipo_comunicacion VARCHAR(50) NULL,
    CONSTRAINT FK_Comentarios_Tickets FOREIGN KEY (id_ticket) REFERENCES Tickets(id_ticket),
    CONSTRAINT FK_Comentarios_Usuarios FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
);
GO

-- 2.4 TABLA DE ARCHIVOS ADJUNTOS
CREATE TABLE ArchivosAdjuntos (
    id_archivo INT IDENTITY(1,1) PRIMARY KEY,
    id_ticket INT NOT NULL,
    id_usuario INT NOT NULL,
    nombre_archivo VARCHAR(255) NOT NULL,
    ruta_almacenamiento VARCHAR(500) UNIQUE NOT NULL,
    es_correccion BIT DEFAULT 0,
    fecha_subida DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),
    CONSTRAINT FK_Archivos_Tickets FOREIGN KEY (id_ticket) REFERENCES Tickets(id_ticket),
    CONSTRAINT FK_Archivos_Usuarios FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
);
GO

-- 2.5 TABLA DE HISTORIAL DEL TICKET (Auditoría)
CREATE TABLE HistorialTicket (
    id_historial INT IDENTITY(1,1) PRIMARY KEY,
    id_ticket INT NOT NULL,
    id_usuario_afector INT NULL,
    tipo_evento VARCHAR(50) NOT NULL,
    detalle TEXT NULL,
    fecha_evento DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),
    CONSTRAINT FK_Historial_Tickets FOREIGN KEY (id_ticket) REFERENCES Tickets(id_ticket),
    CONSTRAINT FK_Historial_Usuarios FOREIGN KEY (id_usuario_afector) REFERENCES Usuarios(id_usuario)
);
GO

-- =============================================
-- 3. ÍNDICES PARA OPTIMIZACIÓN (RNF2.5)
-- =============================================

-- Índices en Tickets
CREATE INDEX IDX_Tickets_Cliente ON Tickets(id_usuario_cliente);
CREATE INDEX IDX_Tickets_Agente ON Tickets(id_usuario_agente);
CREATE INDEX IDX_Tickets_Estado ON Tickets(id_estado);
CREATE INDEX IDX_Tickets_FechaCreacion ON Tickets(fecha_creacion);
GO

-- Índices en HistorialTicket para reportes
CREATE INDEX IDX_Historial_Ticket ON HistorialTicket(id_ticket);
CREATE INDEX IDX_Historial_Usuario ON HistorialTicket(id_usuario_afector);
CREATE INDEX IDX_Historial_Fecha ON HistorialTicket(fecha_evento);
GO

-- Índices en Comentarios
CREATE INDEX IDX_Comentarios_Ticket ON Comentarios(id_ticket);
GO

-- =============================================
-- 4. INSERCIÓN DE DATOS INICIALES
-- =============================================

-- 4.1 INSERCIÓN INICIAL: ROLES
INSERT INTO Roles (nombre_rol) VALUES
('Cliente'),
('Jefe de Soporte'),
('Agente de Soporte'),
('Administrador');
GO

-- 4.2 INSERCIÓN INICIAL: ESTADOS
INSERT INTO Estados (nombre_estado, descripcion) VALUES
('Nuevo', 'Ticket recién creado, pendiente de asignación.'),
('Asignado', 'Ticket en manos de un Agente, iniciando el análisis.'),
('En Espera de Cliente', 'Agente solicitó más información al cliente.'),
('En Proceso (Técnico)', 'Agente realizando correcciones (JSON, Postman).'),
('Propuesta Enviada', 'Solución enviada al Cliente para aceptación.'),
('Cerrado (Solucionado)', 'Cliente aceptó la solución.');
GO

-- 4.3 INSERCIÓN INICIAL: PRIORIDADES
INSERT INTO Prioridades (nombre_prioridad, nivel) VALUES
('Baja', 1),
('Media', 2),
('Alta', 3);
GO

-- 4.4 INSERCIÓN INICIAL: TIPOS DE COMPROBANTE
INSERT INTO TiposComprobante (nombre_comprobante) VALUES
('Factura'),
('Boleta de Venta'),
('Nota de Crédito'),
('Nota de Débito'),
('Guía de Remisión - Remitente'),
('Guía de Remisión - Transportista');
GO

-- =============================================
-- 5. TRIGGERS PARA AUDITORÍA AUTOMÁTICA
-- =============================================

-- 5.1 Trigger para actualizar fecha_ultima_actualizacion
CREATE TRIGGER TR_Tickets_UpdateFecha
ON Tickets
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Tickets
    SET fecha_ultima_actualizacion = SYSDATETIMEOFFSET()
    FROM Tickets t
    INNER JOIN inserted i ON t.id_ticket = i.id_ticket;
END;
GO

-- 5.2 Trigger para registrar cambios de estado en HistorialTicket
CREATE TRIGGER TR_Tickets_AuditarEstado
ON Tickets
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(id_estado)
    BEGIN
        INSERT INTO HistorialTicket (id_ticket, id_usuario_afector, tipo_evento, detalle)
        SELECT 
            i.id_ticket,
            i.id_usuario_agente,
            'ESTADO_CAMBIADO',
            'Estado cambiado de ' + e1.nombre_estado + ' a ' + e2.nombre_estado
        FROM inserted i
        INNER JOIN deleted d ON i.id_ticket = d.id_ticket
        INNER JOIN Estados e1 ON d.id_estado = e1.id_estado
        INNER JOIN Estados e2 ON i.id_estado = e2.id_estado
        WHERE i.id_estado <> d.id_estado;
    END
END;
GO

-- 5.3 Trigger para registrar asignaciones en HistorialTicket
CREATE TRIGGER TR_Tickets_AuditarAsignacion
ON Tickets
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(id_usuario_agente)
    BEGIN
        INSERT INTO HistorialTicket (id_ticket, id_usuario_afector, tipo_evento, detalle)
        SELECT 
            i.id_ticket,
            i.id_usuario_jefe,
            'ASIGNACION',
            'Ticket asignado al agente ID: ' + CAST(i.id_usuario_agente AS VARCHAR)
        FROM inserted i
        INNER JOIN deleted d ON i.id_ticket = d.id_ticket
        WHERE ISNULL(i.id_usuario_agente, 0) <> ISNULL(d.id_usuario_agente, 0);
    END
END;
GO

-- =============================================
-- 6. VISTAS PARA REPORTES (CU6)
-- =============================================

-- 6.1 Vista: Tickets Activos por Agente
CREATE VIEW VW_TicketsPorAgente AS
SELECT 
    u.id_usuario,
    u.nombres + ' ' + ISNULL(u.apellidos, '') AS nombre_completo,
    COUNT(t.id_ticket) AS total_tickets,
    SUM(CASE WHEN e.nombre_estado = 'Nuevo' THEN 1 ELSE 0 END) AS tickets_nuevos,
    SUM(CASE WHEN e.nombre_estado = 'Asignado' THEN 1 ELSE 0 END) AS tickets_asignados,
    SUM(CASE WHEN e.nombre_estado = 'En Proceso (Técnico)' THEN 1 ELSE 0 END) AS tickets_en_proceso
FROM Usuarios u
LEFT JOIN Tickets t ON u.id_usuario = t.id_usuario_agente
LEFT JOIN Estados e ON t.id_estado = e.id_estado
WHERE u.id_rol = 3 -- Agente de Soporte
  AND t.fecha_cierre IS NULL
GROUP BY u.id_usuario, u.nombres, u.apellidos;
GO

-- 6.2 Vista: Tiempo Promedio de Solución
CREATE VIEW VW_TiempoPromedioSolucion AS
SELECT 
    AVG(DATEDIFF(HOUR, t.fecha_creacion, t.fecha_cierre)) AS horas_promedio,
    p.nombre_prioridad,
    COUNT(t.id_ticket) AS total_tickets_cerrados
FROM Tickets t
INNER JOIN Prioridades p ON t.id_prioridad = p.id_prioridad
WHERE t.fecha_cierre IS NOT NULL
GROUP BY p.nombre_prioridad;
GO

-- 6.3 Vista: Resumen de Tickets por Cliente
CREATE VIEW VW_TicketsPorCliente AS
SELECT 
    u.id_usuario,
    u.nombres + ' ' + ISNULL(u.apellidos, '') AS nombre_completo,
    u.email,
    COUNT(t.id_ticket) AS total_tickets,
    SUM(CASE WHEN t.fecha_cierre IS NULL THEN 1 ELSE 0 END) AS tickets_abiertos,
    SUM(CASE WHEN t.fecha_cierre IS NOT NULL THEN 1 ELSE 0 END) AS tickets_cerrados
FROM Usuarios u
INNER JOIN Tickets t ON u.id_usuario = t.id_usuario_cliente
WHERE u.id_rol = 1 -- Cliente
GROUP BY u.id_usuario, u.nombres, u.apellidos, u.email;
GO

-- =============================================
-- 7. STORED PROCEDURES PARA OPERACIONES CLAVE
-- =============================================

-- 7.1 SP: Crear Ticket (CU1)
CREATE PROCEDURE SP_CrearTicket
    @id_usuario_cliente INT,
    @id_tipo_comprobante INT,
    @asunto VARCHAR(255),
    @descripcion TEXT,
    @numero_documento_rechazado VARCHAR(50) = NULL,
    @id_prioridad INT = 2 -- Media por defecto
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Insertar el ticket
        INSERT INTO Tickets (
            id_usuario_cliente,
            id_estado,
            id_prioridad,
            id_tipo_comprobante,
            asunto,
            descripcion,
            numero_documento_rechazado
        )
        VALUES (
            @id_usuario_cliente,
            1, -- Estado: Nuevo
            @id_prioridad,
            @id_tipo_comprobante,
            @asunto,
            @descripcion,
            @numero_documento_rechazado
        );
        
        -- Registrar en historial
        DECLARE @id_ticket INT = SCOPE_IDENTITY();
        
        INSERT INTO HistorialTicket (id_ticket, id_usuario_afector, tipo_evento, detalle)
        VALUES (@id_ticket, @id_usuario_cliente, 'CREACION', 'Ticket creado por el cliente');
        
        COMMIT TRANSACTION;
        SELECT @id_ticket AS id_ticket_creado;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- 7.2 SP: Asignar Ticket (CU2)
CREATE PROCEDURE SP_AsignarTicket
    @id_ticket INT,
    @id_usuario_agente INT,
    @id_usuario_jefe INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Actualizar el ticket
        UPDATE Tickets
        SET id_usuario_agente = @id_usuario_agente,
            id_usuario_jefe = @id_usuario_jefe,
            id_estado = 2 -- Asignado
        WHERE id_ticket = @id_ticket;
        
        COMMIT TRANSACTION;
        SELECT 'Ticket asignado exitosamente' AS mensaje;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- 7.3 SP: Cerrar Ticket (CU1.2)
CREATE PROCEDURE SP_CerrarTicket
    @id_ticket INT,
    @id_usuario_cliente INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Actualizar el ticket
        UPDATE Tickets
        SET id_estado = 6, -- Cerrado (Solucionado)
            fecha_cierre = SYSDATETIMEOFFSET()
        WHERE id_ticket = @id_ticket
          AND id_usuario_cliente = @id_usuario_cliente;
        
        -- Registrar en historial
        INSERT INTO HistorialTicket (id_ticket, id_usuario_afector, tipo_evento, detalle)
        VALUES (@id_ticket, @id_usuario_cliente, 'CIERRE', 'Ticket cerrado por el cliente - Solución aceptada');
        
        COMMIT TRANSACTION;
        SELECT 'Ticket cerrado exitosamente' AS mensaje;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- 7.4 SP: Validar Usuario
CREATE PROCEDURE SP_Validar_User
    @username VARCHAR(100),  -- Cambiado a email
    @psw VARCHAR(255),
    @roleName VARCHAR(50) OUTPUT,
    @mensaje BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Buscar el usuario en la base de datos
    IF EXISTS (
        SELECT 1 FROM Usuarios u
        INNER JOIN Roles r ON u.id_rol = r.id_rol
        WHERE u.email = @username AND u.password_hash = @psw AND u.activo = 1
    )
    BEGIN
        -- Obtener el nombre del rol del usuario
        SELECT @roleName = r.nombre_rol
        FROM Usuarios u
        INNER JOIN Roles r ON u.id_rol = r.id_rol
        WHERE u.email = @username AND u.password_hash = @psw AND u.activo = 1;
        
        SET @mensaje = 1; -- True: Autenticación exitosa
    END
    ELSE
    BEGIN
        SET @roleName = NULL;
        SET @mensaje = 0; -- False: Usuario o contraseña incorrectos
    END
END;
GO

-- =============================================
-- 8. CONSULTAS DE VERIFICACIÓN
-- =============================================

-- Verificar datos maestros
SELECT 'Roles' AS Tabla, COUNT(*) AS Total FROM Roles
UNION ALL
SELECT 'Estados', COUNT(*) FROM Estados
UNION ALL
SELECT 'Prioridades', COUNT(*) FROM Prioridades
UNION ALL
SELECT 'TiposComprobante', COUNT(*) FROM TiposComprobante;
GO

-- =============================================
-- 9. Inserts
-- =============================================
INSERT INTO usuarios (id_usuario, id_rol, email, password_hash, nombres, apellidos, fecha_registro, activo) VALUES
(1, 1, 'admin@facturactiva.com', 'YWRtaW&MM=', 'Juan Carlos', 'Administrador Sistema', '2025-10-17 00:29:43.3795700 -05:00', 1), -- admin123
(2, 2, 'jefe@facturactiva.com', 'amVmZTEyMw==', 'Maria Elena', 'Supervisor García', '2025-10-17 00:29:43.4001313 -05:00', 1), -- jefe123
(3, 3, 'agente1@facturactiva.com', 'YWdbnRIMTlz', 'Carlos Alberto', 'Técnico Pérez', '2025-10-17 00:29:43.4011286 -05:00', 1); -- agente123