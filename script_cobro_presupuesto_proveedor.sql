-- ============================================================
-- Base de datos: Ferretería
-- Módulos: Proveedores, Presupuestos, Cobros
-- Adaptado para MySQL / phpMyAdmin
-- ============================================================

-- Configuración inicial
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";
SET NAMES utf8mb4;

-- --------------------------------------------------------
-- Tabla: categoria (mínima, requerida para producto si se desea FK)
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `categoria` (
  `id_categoria` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(60) NOT NULL,
  `descripcion` VARCHAR(150) DEFAULT NULL,
  PRIMARY KEY (`id_categoria`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Tabla: producto (necesaria para los detalles de nota y presupuesto)
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `producto` (
  `id_producto` INT NOT NULL AUTO_INCREMENT,
  `codigo` VARCHAR(20) NOT NULL,
  `descripcion` VARCHAR(200) NOT NULL,
  `id_categoria` INT DEFAULT NULL,
  `unidad_medida` VARCHAR(10) NOT NULL COMMENT 'UND, KG, M, etc.',
  `precio_venta` DECIMAL(12,2) NOT NULL,
  `stock_actual` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `stock_minimo` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `estatus` VARCHAR(10) NOT NULL DEFAULT 'ACTIVO' COMMENT 'ACTIVO/INACTIVO',
  PRIMARY KEY (`id_producto`),
  UNIQUE KEY `uk_codigo` (`codigo`),
  KEY `fk_producto_categoria` (`id_categoria`),
  CONSTRAINT `fk_producto_categoria`
    FOREIGN KEY (`id_categoria`)
    REFERENCES `categoria` (`id_categoria`)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Tabla: cliente
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `cliente` (
  `id_cliente` INT NOT NULL AUTO_INCREMENT,
  `tipo_documento` CHAR(1) NOT NULL COMMENT 'V,E,J,G',
  `documento` VARCHAR(12) NOT NULL,
  `nombre_razonsocial` VARCHAR(150) NOT NULL,
  `direccion` TEXT,
  `telefono` VARCHAR(20) DEFAULT NULL,
  `email` VARCHAR(80) DEFAULT NULL,
  `tipo_cliente` VARCHAR(20) DEFAULT NULL COMMENT 'NATURAL, JURIDICO',
  `estatus` VARCHAR(15) NOT NULL DEFAULT 'PROSPECTO' COMMENT 'PROSPECTO, ACTIVO, INACTIVO',
  PRIMARY KEY (`id_cliente`),
  UNIQUE KEY `uk_cliente_doc` (`tipo_documento`, `documento`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Tabla: proveedor
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `proveedor` (
  `id_proveedor` INT NOT NULL AUTO_INCREMENT,
  `rif` VARCHAR(12) NOT NULL,
  `razon_social` VARCHAR(150) NOT NULL,
  `nombre_comercial` VARCHAR(100) DEFAULT NULL,
  `tipo_producto` VARCHAR(50) DEFAULT NULL COMMENT 'Ej. Materiales eléctricos, Plomería',
  `direccion` TEXT,
  `ciudad` VARCHAR(50) DEFAULT NULL,
  `estado` VARCHAR(50) DEFAULT NULL,
  `telefono` VARCHAR(20) DEFAULT NULL,
  `email` VARCHAR(80) DEFAULT NULL,
  `persona_contacto` VARCHAR(100) DEFAULT NULL,
  `tipo_proveedor` VARCHAR(20) NOT NULL DEFAULT 'NACIONAL' COMMENT 'NACIONAL, INTERNACIONAL',
  `estatus` VARCHAR(10) NOT NULL DEFAULT 'ACTIVO' COMMENT 'ACTIVO, INACTIVO',
  `fecha_registro` DATE DEFAULT NULL,
  PRIMARY KEY (`id_proveedor`),
  UNIQUE KEY `uk_rif` (`rif`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Tabla: contacto_proveedor
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `contacto_proveedor` (
  `id_contacto` INT NOT NULL AUTO_INCREMENT,
  `id_proveedor` INT NOT NULL,
  `nombre` VARCHAR(100) NOT NULL,
  `cargo` VARCHAR(50) DEFAULT NULL,
  `telefono` VARCHAR(20) DEFAULT NULL,
  `email` VARCHAR(80) DEFAULT NULL,
  PRIMARY KEY (`id_contacto`),
  KEY `fk_contacto_proveedor` (`id_proveedor`),
  CONSTRAINT `fk_contacto_proveedor`
    FOREIGN KEY (`id_proveedor`)
    REFERENCES `proveedor` (`id_proveedor`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Tabla: nota_entrega
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `nota_entrega` (
  `id_nota_entrega` INT NOT NULL AUTO_INCREMENT,
  `id_proveedor` INT NOT NULL,
  `numero_nota` VARCHAR(20) NOT NULL,
  `fecha_emision` DATE NOT NULL,
  `fecha_recepcion` DATE DEFAULT NULL,
  `observaciones` TEXT,
  `estatus` VARCHAR(15) NOT NULL DEFAULT 'RECIBIDA' COMMENT 'RECIBIDA, VERIFICADA, RECHAZADA',
  PRIMARY KEY (`id_nota_entrega`),
  UNIQUE KEY `uk_numero_nota` (`numero_nota`),
  KEY `fk_nota_entrega_proveedor` (`id_proveedor`),
  CONSTRAINT `fk_nota_entrega_proveedor`
    FOREIGN KEY (`id_proveedor`)
    REFERENCES `proveedor` (`id_proveedor`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Tabla: detalle_nota_entrega
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `detalle_nota_entrega` (
  `id_detalle` INT NOT NULL AUTO_INCREMENT,
  `id_nota_entrega` INT NOT NULL,
  `id_producto` INT NOT NULL,
  `cantidad_recibida` DECIMAL(10,2) NOT NULL,
  `costo_unitario` DECIMAL(12,2) NOT NULL,
  `estado_calidad` VARCHAR(10) DEFAULT 'OK' COMMENT 'OK, DEFECTUOSO, FALTANTE',
  PRIMARY KEY (`id_detalle`),
  KEY `fk_det_nota_nota` (`id_nota_entrega`),
  KEY `fk_det_nota_producto` (`id_producto`),
  CONSTRAINT `fk_det_nota_nota`
    FOREIGN KEY (`id_nota_entrega`)
    REFERENCES `nota_entrega` (`id_nota_entrega`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_det_nota_producto`
    FOREIGN KEY (`id_producto`)
    REFERENCES `producto` (`id_producto`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Tabla: presupuesto
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `presupuesto` (
  `id_presupuesto` INT NOT NULL AUTO_INCREMENT,
  `numero_presupuesto` VARCHAR(20) NOT NULL,
  `id_cliente` INT NOT NULL,
  `fecha_emision` DATE NOT NULL,
  `fecha_validez_hasta` DATE DEFAULT NULL,
  `subtotal` DECIMAL(12,2) NOT NULL,
  `impuesto_porcentaje` DECIMAL(5,2) NOT NULL DEFAULT 16.00,
  `impuesto_monto` DECIMAL(12,2) NOT NULL,
  `total` DECIMAL(12,2) NOT NULL,
  `estado` VARCHAR(15) NOT NULL DEFAULT 'EMITIDO' COMMENT 'EMITIDO, ACEPTADO, RECHAZADO, EXPIRADO, COBRADO',
  `notas` TEXT,
  PRIMARY KEY (`id_presupuesto`),
  UNIQUE KEY `uk_numero_presupuesto` (`numero_presupuesto`),
  KEY `fk_presupuesto_cliente` (`id_cliente`),
  CONSTRAINT `fk_presupuesto_cliente`
    FOREIGN KEY (`id_cliente`)
    REFERENCES `cliente` (`id_cliente`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Tabla: detalle_presupuesto
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `detalle_presupuesto` (
  `id_detalle` INT NOT NULL AUTO_INCREMENT,
  `id_presupuesto` INT NOT NULL,
  `id_producto` INT NOT NULL,
  `cantidad` DECIMAL(10,2) NOT NULL,
  `precio_unitario` DECIMAL(12,2) NOT NULL,
  `validez` DATE DEFAULT NULL COMMENT 'Fecha de validez de este ítem en particular',
  `subtotal` DECIMAL(12,2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED COMMENT 'Calculado automáticamente',
  PRIMARY KEY (`id_detalle`),
  KEY `fk_det_presup_presup` (`id_presupuesto`),
  KEY `fk_det_presup_producto` (`id_producto`),
  CONSTRAINT `fk_det_presup_presup`
    FOREIGN KEY (`id_presupuesto`)
    REFERENCES `presupuesto` (`id_presupuesto`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_det_presup_producto`
    FOREIGN KEY (`id_producto`)
    REFERENCES `producto` (`id_producto`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Tabla: cobro (representa una deuda o cuenta por cobrar)
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `cobro` (
  `id_cobro` INT NOT NULL AUTO_INCREMENT,
  `id_cliente` INT NOT NULL,
  `fecha_creacion` DATE NOT NULL,
  `fecha_vencimiento` DATE DEFAULT NULL,
  `monto_total` DECIMAL(12,2) NOT NULL,
  `saldo_pendiente` DECIMAL(12,2) NOT NULL,
  `estado` VARCHAR(15) NOT NULL DEFAULT 'PENDIENTE' COMMENT 'PENDIENTE, PAGADO, VENCIDO, ANULADO',
  PRIMARY KEY (`id_cobro`),
  KEY `fk_cobro_cliente` (`id_cliente`),
  CONSTRAINT `fk_cobro_cliente`
    FOREIGN KEY (`id_cliente`)
    REFERENCES `cliente` (`id_cliente`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Tabla: metodo_pago
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `metodo_pago` (
  `id_metodo_pago` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(30) NOT NULL COMMENT 'EFECTIVO, PAGO_MOVIL, TRANSFERENCIA, DIVISAS',
  `descripcion` VARCHAR(100) DEFAULT NULL,
  PRIMARY KEY (`id_metodo_pago`),
  UNIQUE KEY `uk_nombre_metodo` (`nombre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Tabla: recibo_pago
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `recibo_pago` (
  `id_recibo_pago` INT NOT NULL AUTO_INCREMENT,
  `fecha_pago` DATE NOT NULL,
  `monto_total` DECIMAL(12,2) NOT NULL,
  `referencia` VARCHAR(50) DEFAULT NULL,
  `observaciones` TEXT,
  `anulado` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '0=Vigente, 1=Anulado',
  `motivo_anulacion` TEXT COMMENT 'Solo se completa si anulado=1',
  PRIMARY KEY (`id_recibo_pago`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Tabla: detalle_recibo
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `detalle_recibo` (
  `id_detalle` INT NOT NULL AUTO_INCREMENT,
  `id_recibo_pago` INT NOT NULL,
  `id_metodo_pago` INT NOT NULL,
  `monto` DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (`id_detalle`),
  KEY `fk_det_recibo_recibo` (`id_recibo_pago`),
  KEY `fk_det_recibo_metodo` (`id_metodo_pago`),
  CONSTRAINT `fk_det_recibo_recibo`
    FOREIGN KEY (`id_recibo_pago`)
    REFERENCES `recibo_pago` (`id_recibo_pago`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_det_recibo_metodo`
    FOREIGN KEY (`id_metodo_pago`)
    REFERENCES `metodo_pago` (`id_metodo_pago`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Tabla: cobro_recibo (relación muchos a muchos entre cobro y recibo_pago)
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `cobro_recibo` (
  `id_aplicacion` INT NOT NULL AUTO_INCREMENT,
  `id_cobro` INT NOT NULL,
  `id_recibo_pago` INT NOT NULL,
  `monto_aplicado` DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (`id_aplicacion`),
  KEY `fk_cobro_recibo_cobro` (`id_cobro`),
  KEY `fk_cobro_recibo_recibo` (`id_recibo_pago`),
  CONSTRAINT `fk_cobro_recibo_cobro`
    FOREIGN KEY (`id_cobro`)
    REFERENCES `cobro` (`id_cobro`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_cobro_recibo_recibo`
    FOREIGN KEY (`id_recibo_pago`)
    REFERENCES `recibo_pago` (`id_recibo_pago`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Finalizar transacción
COMMIT;