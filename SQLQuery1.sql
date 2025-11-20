SELECT 
		claveSecretaMFA
	FROM
		SCGI..SIST_USUARIO
	WHERE
		idUsuario = 79028


select * from SCGI..SIST_COLA_ENVIO_CORREO order by idColaMail desc

Select Top 1 
Convert(varchar(30), fechaTipoVenta, 106) as fechaTipoVentaF,
tipoVenta, tipoCompra, fechaTipoVenta 
From SIFIN..TIPO_CAMBIO_MONEDA
Order By fechaTipoVenta Desc

select * from SCGI..SIST_USUARIO where idUsuario = 77383

Select top 1
					Reverse
					(
						Replace(
							Left
							(
								subString(Cast(claveB as varchar(50)), charIndex('~',Cast(claveB as varchar(50)))+1,100),
								charIndex
								(
									'~',
									subString(Cast(claveB as varchar(50)), charIndex('~',Cast(claveB as varchar(50)))+1,100)
								)
							), '~',''
						)
					)
				From SCGI..SIST_USUARIO
				Where 
				(
					 2870469 = idPersona
				)

update SCGI..SIST_USUARIO
set claveSecretaMFA = null
where idUsuario = 79028

select claveSecretaMFA from SCGI..SIST_USUARIO where idUsuario = 79028
--VS4KN7KONCJWQKQFLK2MHC5G4J6N2P6Q

