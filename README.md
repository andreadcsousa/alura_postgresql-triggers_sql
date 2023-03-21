# PostgreSQL: Triggers, transações, erros e cursores

Aprendendo a executar funções em eventos com Triggers; entendendo sobre gerenciamento de transações em funções; conhecendo o tratamento de erros e exceções em PLpgSQL; entendendo na prática como funcionam cursores; aprendendo alguns detalhes sobre o processo de desenvolvimento de funções.

1. [Triggers](#1-triggers)
2. [Gerenciamento de transações](#2-gerenciamento-de-transações)
3. [Erros e exceções](#3-erros-e-exceções)
4. [Cursores](#4-cursores)
5. [Processo de desenvolvimento](#5-processo-de-desenvolvimento)

Saiba mais sobre o curso [aqui](https://cursos.alura.com.br/course/postgresql-triggers-transacoes-erros-cursores) ou acompanhe minhas anotações abaixo. ⬇️

## 1. Triggers

### **Eventos no banco**

Triggers ou gatilhos são eventos em SQL que disparam um código caso um comando (insert, update, delete) seja executado.

Por exemplo, ao inserir um registro na tabela de instrutores o gatilho "avisaria" que esse comando está sendo executado e faria com que a tabela que guarda o log desses instrutores receba tal atualização também.

- ***Quando faz sentido criar um trigger?***

> Um trigger deve ser criado quando uma função precisar ser executada sempre que determinado evento ocorrer, por exemplo, sempre que um instrutor for inserido.

- ***Sintaxe da trigger como retorno da função:***

```sql
CREATE OR REPLACE FUNCTION nome RETURNS trigger AS $$
    BEGIN
        -- Corpo da função
    RETURN NEW;
    END;
$$
```

**Documentação:** [Triggers](https://www.postgresql.org/docs/current/plpgsql-trigger.html)

### **Trigger Procedures**

Os triggers possuem variáveis especiais que são utilizadas para identificar os argumentos de uma trigger, na execução de uma função.

A variável `NEW` contém uma nova linha que está sendo inserida (INSERT) ou atualizada (UPDATE) no gatilho de linha. Sendo nula no comando de exclusão (DELETE) do registro.

A variável `OLD` contém a linha que está sendo removida (DELETE) ou a linha antes da alteração (UPDATE) no gatilho de linha. Sendo nula no comando de inserção (INSERT) do registro.

- ***O que uma Trigger Procedure tem como seu retorno?***

> Uma Trigger Procedure tem como seu retorno o tipo especial TRIGGER. Isso define que essa função vai ser usada em algum trigger e ativa algumas verificações do PostgreSQL.

- ***Sintaxe para a criação de uma trigger:***

```sql
CREATE TRIGGER nome { BEFORE | AFTER } evento ON tabela
FOR EACH ROW
    EXECUTE PROCEDURE funcao();
```

**Para saber mais:** [Criação do trigger](Para%20saber%20mais/Aula%201%20-%20Atividade%207%20Para%20saber%20mais_%20Criação%20do%20Trigge.pdf)

### **Detalhes de Triggers**

Ao criar uma trigger é possível definir em que momento o evento acontecerá. Podendo ser antes (BEFORE), depois (AFTER) ou ao invés (INSTEAD OF) de uma instrução.

- `AFTER` após realizar uma ação, continua essa ação com o evento predefinido.
- `BEFORE` modifica valores inseridos ou impede uma ação de ser executada.
- `evento` inserção, atualização ou exclusão de registro na função.
- `FOR EACH ROW` executa o evento para cada linha, utilizando as variáveis new ou old na função.
- `FOR EACH STATEMENT` executa o evento para cada instrução, sem necessidade de variáveis.

- ***Qual a diferença entre um trigger definido para executar FOR EACH ROW e FOR EACH STATEMENT?***

> O primeiro executará a função uma vez para cada linha modificada. Já o segundo executará a função apenas uma vez para cada instrução, independente do número de linhas modificadas.

**Para saber mais:** [Desafios](Para%20saber%20mais/Aula%201%20-%20Atividade%2010%20Para%20saber%20mais_%20Desafios.pdf)

## 2. Gerenciamento de transações

Uma função não tem transação própria, então ela funciona dentro da transação que a chamou. Caso ocorra um erro em uma instrução e seja necessário realizar um rollback na transação, a função também sofrerá um rollback.

- ***PLs fazem parte da transação do código SQL que as chamou?***

> Uma PL já está por padrão dentro de uma transação. Se for chamada em um código SQL, ela fará parte da mesma transação que aquele código. Se for chamada automaticamente por um trigger, ela fará parte da transação da instrução que gerou esse trigger.

- ***Como é possível cancelar a transação de dentro da PL?***

> Se um erro for gerado na PL, a transação a qual ela pertence será cancelada.

## 3. Erros e exceções

### **Para saber mais: Blocos**

> Caso nós quiséssemos que apenas parte do código fosse “cancelado” no caso de um erro, poderíamos separar nossa função em diversos blocos, como vimos no início do treinamento inicial.
>
> Cada bloco pode tratar suas exceções de forma individual. Então se quiséssemos tratar a exceção do segundo INSERT e não cancelar a execução do primeiro, bastaria rodear esse segundo INSERT em um bloco BEGIN - EXCEPTION - END.

### **Exibindo mensagens**

Um dos recursos comuns do desenvolvimento com PL é o a exibição de mensagens ou de erros. Esse recurso exibe mensagens de diversos níveis e necessita de um formato.

***Sintaxe básica:***

```sql
RAISE level 'mensagem a ser exibida'
```

***Níveis (level):***

- `DEBUG` mensagem de log
- `LOG` mensagem de log
- `INFO` mensagem de log
- `NOTICE` mensagem de aviso
- `WARNING` mensagem de aviso
- `EXCEPTION` mensagem de erro

> Nem todas as mensagens são exibidas. Por padrão, as mensagens de severidade DEBUG e LOG não são exibidas, conforme a [documentação](https://www.postgresql.org/docs/current/runtime-config-client.html#GUC-CLIENT-MIN-MESSAGES).

- ***Como definir onde um valor de uma variável deve ser inserido em uma mensagem?***

> Através do caractere %. Para cada caractere % que adicionarmos no formato da mensagem, ou seja, na string que definimos com o RAISE, precisamos informar um outro parâmetro que será o valor que vai ocupar o espaço desse %.

## 4. Cursores

### **Cursores e quando usar**

Cursores representam tabelas armazenadas temporariamente na memória e são utilizadas para poupar memória alocada.

```sql
-- Sintaxe básica do cursor
nome CURSOR FOR query;

-- Abrindo e fechando o cursor
OPEN nome_cursor FOR query;
CLOSE nome_cursor;
```

- ***Quando cursores devem ser utilizados?***

> Se precisamos retornar um resultado muito grande, cursores podem ajudar a poupar a quantidade de memória alocada pois o PostgreSQL não alocará na memória o resultado todo, mas sim apenas o suficiente para executar a query futuramente e pegar uma linha por vez. Um detalhe importante é que o FOR faz isso automaticamente, ou seja, apenas um salário por vez está sendo alocado em nossa query hoje.

**Para saber mais:** [Performance](Para%20saber%20mais/Aula%204%20-%20Atividade%204%20Para%20saber%20mais_%20Performance.pdf)

### **Manipulando o cursor**

O `FETCH` pega uma linha e adiciona a uma variável. Funciona como o INSERT INTO, contudo pode-se definir a direção em que o cursor irá "se mover". Para mover, de fato, o cursor pode-se utilizar o `MOVE`.

```sql
-- Sintaxe básica do fetch
FETCH direcao FROM nome_cursor INTO variavel;

-- Sintaxe básica do move
MOVE direcao FROM nome_cursor;
```

> O FETCH além de mover o “ponteiro” do cursor, devolve o valor após mover.
> O MOVE apenas move o “ponteiro” sem devolver nenhum valor.

***Direções do cursor:***

- `LAST` último
- `NEXT` próximo (padrão)
- `PRIOR` anterior
- `FIRST` primeiro

## 5. Processo de desenvolvimento

### **Blocos anônimos**

Blocos anônimos servem para validar uma declaração e/ou uma transação antes de adicioná-la numa função. Ao passar uma instrução dentro do comando `DO`. Apesar de não retornar um resultado, pode-se utilizar a funcionalidade `RAISE` para exibir uma mensagem ao executar o código.

> Se for necessário executar um script pontual que gere um relatório mais completo, podemos dentro desse bloco criar uma tabela temporária, preenchê-la com os dados do relatório, e após executar o script, fazer um simples SELECT na tabela temporária.

A instrução `DO` pode ser utilizada para executar scripts pontuais que não serão reutilizados e no processo de desenvolvimento de uma função para testar sua execução.

```sql
DO $$
	DECLARE
		cursor_salarios refcursor;
		salario DECIMAL;
		total_instrutores INTEGER DEFAULT 0;
		instrutores_recebem_menos INTEGER DEFAULT 0;
		percentual DECIMAL(5, 2);
	BEGIN
		SELECT instrutores_internos(12) INTO cursor_salarios;
		LOOP
			FETCH cursor_salarios INTO salario;
			EXIT WHEN NOT FOUND; 
			total_instrutores := total_instrutores + 1;

			IF 600::DECIMAL > salario THEN
				instrutores_recebem_menos := instrutores_recebem_menos +1;
			END IF;
		END LOOP;
		percentual = instrutores_recebem_menos::DECIMAL / total_instrutores::DECIMAL * 100;
		RAISE NOTICE 'Percentual: % %%', percentual;
	END;
$$;
```

### **Boa práticas**

É uma boa prática ter um padrão de escrita dos nomes e das variáveis. Se uma variável é criada no formato snake case, todas as demais devem ser criadas no mesmo formato. Se cada pessoa da equipe costuma escrever em um formato diferente, isso vai causar uma confusão no código.

    snake_case
    camelCase
    PascalCase
    kebab-case

*Importante saber: Algumas linguagens possuem uma convenção (padrão próprio) na escrita.*

**Para saber mais:** [Padrões de escrita](https://www.alura.com.br/artigos/convencoes-nomenclatura-camel-pascal-kebab-snake-case)

Em toda linguagem é essencial trabalhar com indentações no código para melhorar a legibilidade. Paa saber onde começa e onde termina cada bloco de código. Principalmente porque a leitura vertical é mais fluída.

![Efeito Hadouken na indentação](https://miro.medium.com/v2/resize:fit:640/format:webp/0*56HW6eZ4xDeZNIDW.jpg)

Outra boa prática é evitar o uso do ELSE, isso é chamado de *early return*. Essa prática diz que o retorno rápido do valor além de deixar o código mais legível, deixa mais curto e diminui a indentação. Então, ao invés de criar várias condições para uma função, por exemplo, pode-se retornar logo o valor e obter o resultado mais rápido.

**Para saber mais:** [Early return](https://www.alura.com.br/artigos/quanto-mais-simples-melhor)

### **Ferramentas de edição**

- pgAdmin
- SQL Manager
- Datagrip

⬆️ [Voltar ao topo](#postgresql-triggers-transações-erros-e-cursores) ⬆️