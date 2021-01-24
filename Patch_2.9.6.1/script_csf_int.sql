-------------------------------------------------------------------------------------------
Prompt INI Patch 2.9.6.1 - Alteracoes no CSF_INT
-------------------------------------------------------------------------------------------
SET DEFINE OFF
/

--------------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #74874 - Criação de indice para as VW_CSF_CONHEC_TRANSP, VW_CSF_CONHEC_TRANSP_EMIT, VW_CSF_CONHEC_TRANSP_TOMADOR
--------------------------------------------------------------------------------------------------------------------------------------
declare
   --
   procedure pExec_Imed(ev_sql long) is
   begin
      --
      begin
         execute immediate ev_sql;
      exception
         when others then
            null;
      end;      
      --
   end pExec_Imed;
   --
begin
   --VW_CSF_CONHEC_TRANSP
   pExec_Imed('create index CSF_INT.VW_CSF_CONHEC_TRANSP_IDX1 on CSF_INT.VW_CSF_CONHEC_TRANSP (CPF_CNPJ_EMIT) tablespace CSF_INDEX');
   --
   pExec_Imed('create index CSF_INT.VW_CSF_CONHEC_TRANSP_IDX10 on CSF_INT.VW_CSF_CONHEC_TRANSP (CPF_CNPJ_EMIT, DM_IND_EMIT, DT_HR_EMISSAO, DT_SAI_ENT) tablespace CSF_INDEX');
   --
   pExec_Imed('create index CSF_INT.VW_CSF_CONHEC_TRANSP_IDX2 on CSF_INT.VW_CSF_CONHEC_TRANSP (CPF_CNPJ_EMIT, DT_HR_EMISSAO) tablespace CSF_INDEX');
   --
   pExec_Imed('create index CSF_INT.VW_CSF_CONHEC_TRANSP_IDX3 on CSF_INT.VW_CSF_CONHEC_TRANSP (CPF_CNPJ_EMIT, DT_HR_EMISSAO, DM_IND_EMIT, COD_MOD, DM_ST_PROC) tablespace CSF_INDEX');
   --
   pExec_Imed('create index CSF_INT.VW_CSF_CONHEC_TRANSP_IDX4 on CSF_INT.VW_CSF_CONHEC_TRANSP (CPF_CNPJ_EMIT, DM_IND_EMIT, COD_MOD, DM_ST_PROC) tablespace CSF_INDEX');
   --
   pExec_Imed('create index CSF_INT.VW_CSF_CONHEC_TRANSP_IDX5 on CSF_INT.VW_CSF_CONHEC_TRANSP (CPF_CNPJ_EMIT, DM_IND_EMIT, DT_HR_EMISSAO, DT_SAI_ENT, COD_MOD, DM_ST_PROC) tablespace CSF_INDEX');
   --
   pExec_Imed('create index CSF_INT.VW_CSF_CONHEC_TRANSP_IDX6 on CSF_INT.VW_CSF_CONHEC_TRANSP (CPF_CNPJ_EMIT, DM_IND_EMIT, DT_HR_EMISSAO, COD_MOD, DM_ST_PROC) tablespace CSF_INDEX');
   --
   pExec_Imed('create index CSF_INT.VW_CSF_CONHEC_TRANSP_IDX7 on CSF_INT.VW_CSF_CONHEC_TRANSP (CPF_CNPJ_EMIT, DM_IND_EMIT, DT_SAI_ENT, COD_MOD, DM_ST_PROC) tablespace CSF_INDEX');
   --
   pExec_Imed('create index CSF_INT.VW_CSF_CONHEC_TRANSP_IDX8 on CSF_INT.VW_CSF_CONHEC_TRANSP (CPF_CNPJ_EMIT, DM_IND_EMIT, DT_HR_EMISSAO) tablespace CSF_INDEX');
   --
   pExec_Imed('create index CSF_INT.VW_CSF_CONHEC_TRANSP_IDX9 on CSF_INT.VW_CSF_CONHEC_TRANSP (CPF_CNPJ_EMIT, DM_IND_EMIT, DT_SAI_ENT) tablespace CSF_INDEX');
   --VW_CSF_CONHEC_TRANSP_EMIT
   pExec_Imed('create index CSF_INT.VW_CSF_CONHEC_TRANSP_EMIT_IDX1 on CSF_INT.VW_CSF_CONHEC_TRANSP_EMIT (CPF_CNPJ_EMIT, DM_IND_EMIT, DM_IND_OPER, COD_PART, COD_MOD, SERIE, NRO_CT) tablespace CSF_INDEX');
   --
   pExec_Imed('create index CSF_INT.VW_CSF_CONHEC_TRANSP_EMIT_IDX2 on CSF_INT.VW_CSF_CONHEC_TRANSP_EMIT (CPF_CNPJ_EMIT, DM_IND_EMIT, DM_IND_OPER, COD_MOD, SERIE, NRO_CT) tablespace CSF_INDEX');
   --VW_CSF_CONHEC_TRANSP_TOMADOR
   pExec_Imed('create index CSF_INT.VW_CSF_CONHEC_TRANSP_TOMA_IDX1 on CSF_INT.VW_CSF_CONHEC_TRANSP_TOMADOR (CPF_CNPJ_EMIT, DM_IND_EMIT, DM_IND_OPER, COD_PART, COD_MOD, SERIE, NRO_CT) tablespace CSF_INDEX');
   --
   pExec_Imed('create index CSF_INT.VW_CSF_CONHEC_TRANSP_TOMA_IDX2 on CSF_INT.VW_CSF_CONHEC_TRANSP_TOMADOR (CPF_CNPJ_EMIT, DM_IND_EMIT, DM_IND_OPER, COD_MOD, SERIE, NRO_CT) tablespace CSF_INDEX');
   --
exception 
   when others then
      raise_application_error(-20001, 'Erro no script #74874 - Erro: ' || sqlerrm);
end;
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #74874 - Criação de indice para as VW_CSF_CONHEC_TRANSP, VW_CSF_CONHEC_TRANSP_EMIT, VW_CSF_CONHEC_TRANSP_TOMADOR
--------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
Prompt FIM Patch 2.9.6.1 - Alteracoes no CSF_INT
-------------------------------------------------------------------------------------------


