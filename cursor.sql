CREATE FUNCTION instrutores_internos(id_instrutor INTEGER)
RETURNS refcursor AS $$
	DECLARE
		cursor_salarios refcursor;
	BEGIN
		OPEN cursor_salarios FOR
			SELECT instrutor.salario FROM instrutor
			WHERE id <> id_instrutor AND salario > 0;
			
		RETURN cursor_salarios;
	END;
$$ LANGUAGE plpgsql;

DROP FUNCTION cria_instrutor;

CREATE OR REPLACE FUNCTION cria_instrutor() RETURNS trigger AS $$
	DECLARE
		media_salarial DECIMAL;
		instrutores_recebem_menos INTEGER DEFAULT 0;
		total_instrutores INTEGER DEFAULT 0;
		salario DECIMAL;
		percentual DECIMAL(5, 2);
		cursor_salarios refcursor;
	BEGIN
		SELECT AVG(instrutor.salario) INTO media_salarial FROM instrutor WHERE id <> NEW.id;
		
		IF NEW.salario > media_salarial THEN
			INSERT INTO log_instrutores (informacao) VALUES (NEW.nome || ' recebe acima da média');
		END IF;
		
		SELECT instrutores_internos(NEW.id) INTO cursor_salarios;
		LOOP
			FETCH cursor_salarios INTO salario;
			EXIT WHEN NOT FOUND; 
			total_instrutores := total_instrutores + 1;
			
			IF NEW.salario > salario THEN
				instrutores_recebem_menos := instrutores_recebem_menos +1;
			END IF;
		END LOOP;
		
		percentual = instrutores_recebem_menos::DECIMAL / total_instrutores::DECIMAL * 100;
		ASSERT percentual < 100::DECIMAL, 'Intrutores novos não podem receber mais do que intrutores antigos';
		
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
SELECT * FROM log_instrutores;