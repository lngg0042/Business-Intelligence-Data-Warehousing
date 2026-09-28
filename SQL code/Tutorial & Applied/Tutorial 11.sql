-- Task 2
-- Q1
CREATE OR REPLACE PROCEDURE ITemployee  as
    v_count NUMBER;
    cursor v_emp is
    select e.id, 
            e.name|| ' '|| e.surname as fullname,
            e.email,
            em.manager
    from dei_survey_m.employee e
    join dei_survey_m.employment em on e.id = em.id
    join dei_survey_m.division d on em.division_id = d.division_id
    where d.division = 'IT';

begin
   v_count := 0;
   for s_emp in v_emp loop
        v_count := v_count+1;
      dbms_output.put_line(
        'Employee ID: '|| s_emp.id|| 
        ', Employee Name: '|| s_emp.fullname|| 
        ', Email: '|| s_emp.email|| 
        ', Manager: '|| s_emp.manager
        );
   end loop;
   dbms_output.put_line('Total IT Employees: ' || v_count); --For checking the number of rows
end ITemployee;
/


--You can use command below to show the result
EXEC Your_procedure_name;

-- Q2
create or replace procedure avgsurvey as
   cursor q_avg is
   select r.question_id,
          questions,
          count(*) as n_responses,
          sum(r.RESPONSEVALUE) as sum_score,
          avg(r.responsevalue) as avg_score
     from dei_survey_m.response r
     join dei_survey_m.dei_question d
   on r.question_id = d.question_id
    group by r.question_id,
             questions;
begin
   for s_avg in q_avg loop
      dbms_output.put_line(s_avg.question_id
                           || ': '
                           || s_avg.questions
                           || ' Number of Responses: '
                           || s_avg.n_responses
                           || ' Total Score: '
                           || s_avg.sum_score
                           || ' Average score: '
                           || s_avg.avg_score
                           || ' ('
                           ||
         case
            when s_avg.avg_score between -0.5 and 0.5 then
               'Neutral'
            when s_avg.avg_score > 0.5 then
               'Agree'
            when s_avg.avg_score < -0.5 then
               'Disagree'
         end
                           || ')');
   end loop;
end avgsurvey;
/

-- Q3

create or replace procedure avgsurveysave as
   cursor q_avg is
   select r.question_id,
          questions,
          count(*) as n_responses,
          sum(r.RESPONSEVALUE) as sum_score,
          avg(r.responsevalue) as avg_score
     from dei_survey_M.response r
     join dei_survey_M.dei_question d
   on r.question_id = d.question_id
    group by r.question_id,
             questions;
begin
   for s_avg in q_avg loop
      insert into lab11_ans (QuestionID, Question, N_responses, Sum_score, Avg_score, Avg_label)
      values (
        s_avg.question_id,
        s_avg.questions,
        s_avg.n_responses,
        s_avg.sum_score,
        s_avg.avg_score,
      case
            when s_avg.avg_score between - 0.5 and 0.5 then
               'Neutral'
            when s_avg.avg_score > 0.5 then
               'Agree'
            when s_avg.avg_score < -0.5 then
               'Disagree'
         end);
   end loop;
end avgsurveysave;
/

-- Task 3
-- Q4
CREATE TABLE Employee as
SELECT * FROM DEI_SURVEY_M.Employee;

CREATE TABLE Dei_question as
SELECT * FROM DEI_SURVEY_M.Dei_question;

CREATE TABLE Division as
SELECT * FROM DEI_SURVEY_M.Division;

CREATE TABLE Background as
SELECT * FROM DEI_SURVEY_M.Background;

CREATE TABLE Employment as
SELECT * FROM DEI_SURVEY_M.Employment;

CREATE TABLE Response as
SELECT * FROM DEI_SURVEY_M.Response;

-- Q5
CREATE OR REPLACE TRIGGER trg_response_ins
AFTER INSERT ON response
FOR EACH ROW
BEGIN
  UPDATE lab11_ans
     SET n_responses = n_responses + 1,
         sum_score   = sum_score + :NEW.responsevalue,
         avg_score   = (sum_score + :NEW.responsevalue)
                        / (n_responses + 1),
         avg_label   = CASE
                       WHEN ((sum_score + :NEW.responsevalue)
                            /(n_responses + 1)) BETWEEN -0.5 AND 0.5
                           THEN 'Neutral'
                       WHEN ((sum_score + :NEW.responsevalue)
                               / (n_responses + 1)) > 0.5
                           THEN 'Agree'
                       ELSE 'Disagree'
                     END
   WHERE questionid = :NEW.question_id;
END;
/

-- Each time a new record is inserted into the RESPONSE table, the trigger will automatically calculate 
-- the updated average score for that survey question and update the LAB11_ANS table.

-- Q6
insert into employee 
values('201',	'Alessandra',	'Callan', 'Alessandra', to_date('5/1/1990','DD/MM/YY'),32,'Canadian','Alessandra.Callan@mail.ca','243 779 6459');

insert into background
values('201','No','No','No','White','No');

insert into employment
values('201','D4','No');

insert into response
values('201','Aug_D_Q1','Disagree',2);
insert into response
values('201','Aug_D_Q2','Disagree',-1);
insert into response
values('201','Aug_D_Q3','Disagree',1);
insert into response
values('201','Aug_D_Q4','Disagree',1);
insert into response
values('201','Aug_D_Q5','Disagree',2);
insert into response
values('201','Aug_E_Q1','Disagree',-2);
insert into response
values('201','Aug_E_Q2','Disagree',2);
insert into response
values('201','Aug_E_Q3','Disagree',1);
insert into response
values('201','Aug_E_Q4','Disagree',-1);
insert into response
values('201','Aug_E_Q5','Disagree',1);
insert into response
values('201','Aug_I_Q1','Disagree',-2);
insert into response
values('201','Aug_I_Q2','Disagree',2);
insert into response
values('201','Aug_I_Q3','Disagree',1);
insert into response
values('201','Aug_I_Q4','Disagree',0);
insert into response
values('201','Aug_I_Q5','Disagree',2);










