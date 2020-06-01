CREATE DATABASE campeonato
GO
USE campeonato

CREATE TABLE times (
codigo		INT IDENTITY,
nome		VARCHAR(30),
sigla		CHAR(3)
primary key (codigo))

CREATE TABLE jogos (
time1		INT,
time2		INT,
golsa		INT,
golsb		INT,
datajogo	DATETIME
PRIMARY KEY(time1,time2),
FOREIGN KEY(time1) REFERENCES times(codigo),
FOREIGN KEY(time2) REFERENCES times(codigo))

CREATE TABLE campeonato (
codigo		INT,
jogos		INT,
vitorias	INT,
empates		INT,
derrotas	INT,
gols_pro	INT,
gols_contra	INT
PRIMARY KEY(codigo),
FOREIGN KEY(codigo) REFERENCES times(codigo))

CREATE FUNCTION fn_campeonato ()
RETURNS @tabela	TABLE (
sigla		CHAR(3),
jogos		INT,
vitorias	INT,
empates		INT,
derrotas	INT,
gols_pro	INT,
gols_contra	INT,
pontos		INT
)
AS
BEGIN
	INSERT INTO @tabela (sigla, jogos, vitorias, empates, derrotas, gols_pro, gols_contra) 
	SELECT t.sigla, c.jogos, c.vitorias, c.empates, c.derrotas, c.gols_pro, c.gols_contra 
	FROM times AS t INNER JOIN campeonato AS c ON t.codigo=c.codigo
	UPDATE @tabela SET pontos=vitorias*3+empates
	RETURN
END

CREATE TRIGGER t_campeonato ON jogos
FOR INSERT
AS
BEGIN
	DECLARE @time1		INT,
			@time2		INT,
			@vitoria1	INT,
			@vitoria2	INT,
			@empate1	INT,
			@empate2	INT,
			@derrota1	INT,
			@derrota2	INT,
			@gols1		INT,
			@gols2		INT

	SELECT @time1=time1, @time2=time2, @gols1=golsa, @gols2=golsb FROM INSERTED
	IF(@gols1 > @gols2)
	BEGIN
		SET @vitoria1 = 1;
		SET @vitoria2 = 0;
		SET @empate1 = 0;
		SET @empate2 = 0;
		SET @derrota1 = 0;
		SET @derrota2 = 1;
	END
	IF(@gols1 = @gols2)
	BEGIN
		SET @vitoria1 = 0;
		SET @vitoria2 = 0;
		SET @empate1 = 1;
		SET @empate2 = 1;
		SET @derrota1 = 0;
		SET @derrota2 = 0;
	END
	IF(@gols1 < @gols2)
	BEGIN
		SET @vitoria1 = 0;
		SET @vitoria2 = 1;
		SET @empate1 = 0;
		SET @empate2 = 0;
		SET @derrota1 = 1;
		SET @derrota2 = 0;
	END

	UPDATE campeonato SET
		jogos = jogos +1,
		vitorias = vitorias + @vitoria1,
		empates = empates + @empate1,
		derrotas = derrotas + @derrota1,
		gols_pro = gols_pro + @gols1,
		gols_contra = gols_contra + @gols2
		WHERE codigo = @time1

	UPDATE campeonato SET
		jogos = jogos +1,
		vitorias = vitorias + @vitoria2,
		empates = empates + @empate2,
		derrotas = derrotas + @derrota2,
		gols_pro = gols_pro + @gols2,
		gols_contra = gols_contra + @gols1
		WHERE codigo = @time2
END

INSERT INTO times VALUES
('Barcelona','BAR'),
('Celta de Vigo','CEL'),
('Málaga','MAL'),
('Real Madrid','RMA')

INSERT INTO campeonato (codigo, jogos, vitorias, empates, derrotas, gols_pro, gols_contra) 
	SELECT codigo, 0, 0, 0, 0, 0, 0 FROM times

INSERT INTO jogos (time1, time2, golsa, golsb, datajogo) VALUES (1, 2, 3, 1, '22/04/2013 15:00')
INSERT INTO jogos (time1, time2, golsa, golsb, datajogo) VALUES (1, 3, 2, 1, '29/04/2013 15:00')
INSERT INTO jogos (time1, time2, golsa, golsb, datajogo) VALUES (1, 4, 1, 1, '06/05/2013 15:00')
INSERT INTO jogos (time1, time2, golsa, golsb, datajogo) VALUES (2, 1, 1, 1, '25/04/2013 15:00')
INSERT INTO jogos (time1, time2, golsa, golsb, datajogo) VALUES (2, 3, 2, 3, '02/04/2013 15:00')
INSERT INTO jogos (time1, time2, golsa, golsb, datajogo) VALUES (2, 4, 1, 3, '09/05/2013 15:00')
INSERT INTO jogos (time1, time2, golsa, golsb, datajogo) VALUES (3, 1, 3, 3, '12/05/2013 15:00')
INSERT INTO jogos (time1, time2, golsa, golsb, datajogo) VALUES (3, 2, 2, 2, '15/05/2013 15:00')
INSERT INTO jogos (time1, time2, golsa, golsb, datajogo) VALUES (3, 4, 1, 3, '18/05/2013 15:00')
INSERT INTO jogos (time1, time2, golsa, golsb, datajogo) VALUES (4, 1, 3, 4, '23/05/2013 15:00')
INSERT INTO jogos (time1, time2, golsa, golsb, datajogo) VALUES (4, 2, 2, 0, '27/05/2013 15:00')
INSERT INTO jogos (time1, time2, golsa, golsb, datajogo) VALUES (4, 3, 1, 0, '31/05/2013 15:00')

SELECT * FROM times
SELECT * FROM jogos
SELECT * FROM campeonato
SELECT * FROM fn_campeonato()
