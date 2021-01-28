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

-------------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #71035 - Integração para nota_fiscal_fisco
-------------------------------------------------------------------------------------------------------------------------------------------
   
 declare
  --
  vn_existe number := null;
  --
begin
  --
  begin
    select count(1)
      into vn_existe
      from all_objects a
     where upper(a.owner)       = 'CSF_INT'
       and upper(a.object_name) = 'VW_CSF_NOTA_FISCAL_FISCO';
  exception
    when others then
      vn_existe := 0;
  end;
  --
  if nvl(vn_existe, 0) = 0 then
    --
    begin
      execute immediate 'create table CSF_INT.VW_CSF_NOTA_FISCAL_FISCO ( CPF_CNPJ_EMIT VARCHAR2(14) NOT NULL,
                                                                         DM_IND_EMIT   NUMBER(1) NOT NULL,
                                                                         DM_IND_OPER   NUMBER(1) NOT NULL,
                                                                         COD_PART      VARCHAR2(60),
                                                                         COD_MOD       VARCHAR2(2) NOT NULL,
                                                                         SERIE         VARCHAR2(3) NOT NULL,
                                                                         NRO_NF        NUMBER(9) NOT NULL,
                                                                         DM_COD_MOD_DA NUMBER(1) NOT NULL,
                                                                         ORGAO_EMIT    VARCHAR2(60) NOT NULL,
                                                                         CNPJ          VARCHAR2(14) NOT NULL,
                                                                         MATR_AGENTE   VARCHAR2(60) NOT NULL,
                                                                         NOME_AGENTE   VARCHAR2(60) NOT NULL,
                                                                         FONE          VARCHAR2(14),
                                                                         UF            VARCHAR2(2) NOT NULL,
                                                                         NRO_DAR       VARCHAR2(60),
                                                                         DT_EMISS      DATE,
                                                                         VL_DAR        NUMBER(15,2),
                                                                         REPART_EMIT   VARCHAR2(60) NOT NULL,
                                                                         DT_PAGTO      DATE,
                                                                         COD_AUT_BANC  VARCHAR2(256),
                                                                         DT_VENCTO     DATE 
                                                                        ) tablespace csf_data';
    exception
      when dup_val_on_index then
        raise_application_error(-20001, 'Tabela VW_CSF_NOTA_FISCAL_FISCO ja existe.');
      when others then
        raise_application_error(-20001, 'Erro no script #71035. Criacao da tabela VW_CSF_NOTA_FISCAL_FISCO. Erro: ' || sqlerrm);
    end;
    --
    end if;
    --
    begin
      --
      execute immediate 'comment on table CSF_INT.VW_CSF_NOTA_FISCAL_FISCO is ''Tabela com informacões do documento de arrecadação referenciado''';
      execute immediate 'comment on column CSF_INT.VW_CSF_NOTA_FISCAL_FISCO.DM_COD_MOD_DA  is ''Codigo do modelo do docto de arrecadacão: 0-Documento estadual de arrecadacão / 1-GNRE''';
      execute immediate 'comment on column CSF_INT.VW_CSF_NOTA_FISCAL_FISCO.ORGAO_EMIT is ''Orgão emitente''';
      execute immediate 'comment on column CSF_INT.VW_CSF_NOTA_FISCAL_FISCO.CNPJ is ''CNPJ do orgão emitente''';
      execute immediate 'comment on column CSF_INT.VW_CSF_NOTA_FISCAL_FISCO.MATR_AGENTE is ''Matricula do agente''';
      execute immediate 'comment on column CSF_INT.VW_CSF_NOTA_FISCAL_FISCO.NOME_AGENTE is ''Nome do agente''';
      execute immediate 'comment on column CSF_INT.VW_CSF_NOTA_FISCAL_FISCO.FONE is ''Telefone''';
      execute immediate 'comment on column CSF_INT.VW_CSF_NOTA_FISCAL_FISCO.UF is ''Sigla da UF''';
      execute immediate 'comment on column CSF_INT.VW_CSF_NOTA_FISCAL_FISCO.NRO_DAR is ''Numero do Documento de Arrecadacão de Receita''';
      execute immediate 'comment on column CSF_INT.VW_CSF_NOTA_FISCAL_FISCO.DT_EMISS is ''Data de emissão do Documento de Arrecadacão''';
      execute immediate 'comment on column CSF_INT.VW_CSF_NOTA_FISCAL_FISCO.VL_DAR is ''Valor Total constante no Documento de arrecadacão de Receita''';
      execute immediate 'comment on column CSF_INT.VW_CSF_NOTA_FISCAL_FISCO.REPART_EMIT is ''Reparticão Fiscal emitente''';
      execute immediate 'comment on column CSF_INT.VW_CSF_NOTA_FISCAL_FISCO.DT_PAGTO  is ''Data de pagamento do Documento de Arrecadacão''';
      execute immediate 'comment on column CSF_INT.VW_CSF_NOTA_FISCAL_FISCO.COD_AUT_BANC is ''Codigo completo da autenticacão bancaria''';
      execute immediate 'comment on column CSF_INT.VW_CSF_NOTA_FISCAL_FISCO.DT_VENCTO is ''Data de vencimento do documento de arrecadacão''';
       --
    exception
      when others then
        raise_application_error(-20101, 'Erro no script #71035. Problemas ao criar o comentário da tabela VW_CSF_NOTA_FISCAL_FISCO. ' || sqlerrm);
    end;
    --
    begin
      execute immediate 'grant select, insert, update, delete on CSF_INT.VW_CSF_NOTA_FISCAL_FISCO to csf_own';
      execute immediate 'grant select, insert, update, delete on CSF_INT.VW_CSF_NOTA_FISCAL_FISCO to csf_work';
    exception
      when others then
        raise_application_error(-20101, 'Erro no script #71035. Problemas no grant para a tabela VW_CSF_NOTA_FISCAL_FISCO. ' || sqlerrm);
    end;
    --
    -- Create/Recreate indexes 
    vn_existe := 0;
    --	
    begin
      select count(1) 
        into vn_existe	  
        from all_indexes a
       where a.OWNER = 'CSF_INT'
         and a.table_name = 'VW_CSF_NOTA_FISCAL_FISCO'
         and a.INDEX_NAME = 'VWCSF_NOTAFISCALFISCO_IDX';	
    exception	
       when others then
         vn_existe := 0;
    end;
    --	
	if nvl(vn_existe, 0) = 0 then
       --	
       begin
          execute immediate 'create index CSF_INT.VWCSF_NOTAFISCALFISCO_IDX on CSF_INT.VW_CSF_NOTA_FISCAL_FISCO (CPF_CNPJ_EMIT, DM_IND_EMIT, DM_IND_OPER, COD_PART, COD_MOD, SERIE, NRO_NF) tablespace CSF_DATA';
       exception
          when others then
             RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar indices de VW_CSF_NOTA_FISCAL_FISCO - '||SQLERRM );
       end;	
       --
    end if;
    --	
    vn_existe := 0;
    --	
    begin
      select count(1)
        into vn_existe	  
        from all_indexes a
       where a.OWNER = 'CSF_INT'
         and a.table_name = 'VW_CSF_NOTA_FISCAL_FISCO'
         and a.INDEX_NAME = 'VWCSF_NOTAFISCALFISCO_IDX2';	
    exception	
       when others then
         vn_existe := 0;
    end;
    --	
    if nvl(vn_existe, 0) = 0 then
       --	
       begin
          execute immediate 'create index CSF_INT.VWCSF_NOTAFISCALFISCO_IDX2 on CSF_INT.VW_CSF_NOTA_FISCAL_FISCO (CPF_CNPJ_EMIT, DM_IND_EMIT, DM_IND_OPER, COD_MOD, SERIE, NRO_NF) tablespace CSF_DATA';
       exception
          when others then
             RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar indices de VW_CSF_NOTA_FISCAL_FISCO - '||SQLERRM );
       end;	
       --	
    end if;
    -- 	
    commit;
    --
end;
/

-------------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #71035 - Integração para nota_fiscal_fisco
-------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------
Prompt FIM Patch 2.9.6.1 - Alteracoes no CSF_INT
-------------------------------------------------------------------------------------------


