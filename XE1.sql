delete sample_raw;

insert into sample_raw
    select *   
    from ret;
  

execute dropcpttable();
execute count_topology();
execute reset_parent();
execute compute_probability();
execute reset_pivot();
execute create_dimension();
execute create_cpt();
execute threeway_decisions();

select * from cpt_p;
select * from FREQUENCY_T;