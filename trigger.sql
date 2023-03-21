CREATE TABLE log_instrutores (
	id SERIAL PRIMARY KEY,
	informacao VARCHAR(255),
	momento_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP FUNCTION cria_instrutor;

CREATE OR REPLACE FUNCTION cria_instrutor() RETURNS trigger AS $$
	DECLARE
		media_salarial DECIMAL;
		instrutores_recebem_menos INTEGER DEFAULT 0;
		total_instrutores INTEGER DEFAULT 0;
		salario DECIMAL;
		percentual DECIMAL(5, 2);
	BEGIN
		SELECT AVG(instrutor.salario) INTO media_salarial FROM instrutor WHERE id <> NEW.id;
		
		IF NEW.salario > media_salarial THEN
			INSERT INTO log_instrutores (informacao) VALUES (NEW.nome || ' recebe acima da média');
		END IF;
		
		FOR salario IN SELECT instrutor.salario FROM instrutor WHERE id <> NEW.id LOOP
			total_instrutores := total_instrutores + 1;
			
			RAISE NOTICE 'Salário inserido: % Salário do instrutor existente: %', NEW.salario, salario;
			IF NEW.salario > salario THEN
				instrutores_recebem_menos := instrutores_recebem_menos +1;
			END IF;
		END LOOP;
		
		percentual = instrutores_recebem_menos::DECIMAL / total_instrutores::DECIMAL * 100;
		
		INSERT INTO log_instrutores (informacao)
		VALUES (NEW.nome || ' recebe mais do que ' || percentual || '% da grade de instrutores');
	
		RETURN NEW;
		
	EXCEPTION
		WHEN undefined_column THEN
			RAISE NOTICE 'Algo de errado não está certo';
			RAISE EXCEPTION 'Erro complicado de resolver';
	END;
$$ LANGUAGE plpgsql;

DROP TRIGGER cria_log_instrutores ON instrutor;

CREATE TRIGGER cria_log_instrutores AFTER INSERT ON instrutor
	FOR EACH ROW EXECUTE FUNCTION cria_instrutor();

SELECT * FROM instrutor;

SELECT cria_instrutor('Outro instrutor', 500);

SELECT * FROM log_instrutores;

BEGIN;
INSERT INTO instrutor (nome, salario) VALUES ('Maria', 5000);
ROLLBACK;