/*
    O desafio é composto de duas partes:

    Caso o instrutor inserido receba acima da média, cancele a instrução, ou seja, não permita que a inserção do instrutor ocorra.

    Depois... Desfaça o desafio anterior.
    
    Caso o instrutor inserido receba mais do que 100% dos instrutores existentes, modifique a inserção para que ele passe a receber o mesmo que o instrutor mais bem pago.
*/

CREATE OR REPLACE FUNCTION cria_instrutor() RETURNS trigger AS $$
    DECLARE
      media_salarial DECIMAL;
      instrutores_recebem_menos INTEGER DEFAULT 0;
      total_instrutores INTEGER DEFAULT 0;
      salario DECIMAL;
      maior_salario DECIMAL;
      percentual DECIMAL (5, 2);
    BEGIN
        SELECT AVG(instrutor.salario) INTO media_salarial FROM instrutor WHERE id <> NEW.id;

        IF NEW.salario > media_salarial THEN
            INSERT INTO log_instrutores (informacao) VALUES (NEW.nome || ' recebe acima da média!');
        END IF;

        FOR salario IN SELECT instrutor.salario FROM instrutor WHERE id <> NEW.salario LOOP
            total_instrutores := total_instrutores + 1;

            IF NEW.salario > salario THEN
                instrutores_recebem_menos := instrutores_recebem_menos + 1;
            END IF;
        END LOOP;

        percentual = instrutores_recebem_menos::DECIMAL / total_instrutores::DECIMAL * 100;

        -- Condição do desafio
        IF percentual >= 100 THEN
            SELECT MAX(instrutor.salario) INTO maior_salario FROM instrutor WHERE id <> NEW.id;
            NEW.salario := maior_salario;
        END IF;

        INSERT INTO log_instrutores(informacao) 
        VALUES (NEW.nome || ' recebe mais do que ' || percentual || '% da grade de instrutores');
        
        RETURN NEW;
    END;    
$$ LANGUAGE plpgsql;


----------------------------------------------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION cria_instrutor() RETURNS trigger AS $$ 
    DECLARE
        media_salarial DECIMAL;
        instrutores_recebem_menos INTEGER DEFAULT 0;
        total_instrutores INTEGER DEFAULT 0;
        salario DECIMAL;
        maior_salario DECIMAL;
        percentual DECIMAL (5, 2);
    BEGIN
        SELECT AVG(instrutor.salario) INTO media_salarial FROM instrutor WHERE id <> NEW.id;
        -- Condição do desafio
        SELECT MAX(instrutor.salario) INTO maior_salario FROM instrutor WHERE id <> NEW.id;

        IF NEW.salario > maior_salario THEN
            NEW.salario := maior_salario;        
        ELSIF NEW.salario > media_salarial THEN
            INSERT INTO log_instrutores (informacao) VALUES (NEW.nome || ' recebe acima da média');
        ELSE 
            INSERT INTO log_instrutores (informacao) VALUES (NEW.nome || ' recebe abaixo da média');
        END IF;

        FOR salario IN SELECT instrutor.salario FROM instrutor WHERE id <> NEW.id LOOP 
            total_instrutores := total_instrutores + 1;

            IF NEW.salario > salario THEN 
                instrutores_recebem_menos := instrutores_recebem_menos + 1;
            END IF;
        END LOOP;

        percentual = instrutores_recebem_menos::DECIMAL / total_instrutores::DECIMAL * 100;

        INSERT INTO log_instrutores (informacao)
            VALUES (NEW.nome || ' recebe mais do que' || percentual || '% da grade de instrutores');

        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;


-----------------------------------------------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION cria_instrutor() RETURNS trigger AS $$
    DECLARE
      media_salarial DECIMAL;
      instrutores_recebem_menos INTEGER DEFAULT 0;
      total_instrutores INTEGER DEFAULT 0;
      salario DECIMAL;
      maior_salario DECIMAL;
      percentual DECIMAL (5, 2);
    BEGIN
        SELECT AVG(instrutor.salario) INTO media_salarial FROM instrutor WHERE id <> NEW.id;

        IF NEW.salario > media_salarial THEN
            INSERT INTO log_instrutores (informacao) VALUES (NEW.nome || ' recebe acima da média!');
        END IF;

        FOR salario IN SELECT instrutor.salario FROM instrutor WHERE id <> NEW.salario LOOP
            total_instrutores := total_instrutores + 1;

            IF NEW.salario > salario THEN
                instrutores_recebem_menos := instrutores_recebem_menos + 1;
            END IF;
        END LOOP;

        percentual = instrutores_recebem_menos::DECIMAL / total_instrutores::DECIMAL * 100;
        -- Condição do desafio
        ASSERT percentual < 100::DECIMAL;

        INSERT INTO log_instrutores(informacao) 
        VALUES (NEW.nome || ' recebe mais do que ' || percentual || '% da grade de instrutores');
        
        RETURN NEW;
    END;    
$$ LANGUAGE plpgsql;