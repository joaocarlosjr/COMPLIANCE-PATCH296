------------------------------------------------------------------------------------------
Prompt INI Patch 2.9.6.1 - Alteracoes no CSF_OWN
------------------------------------------------------------------------------------------

insert into csf_own.versao_sistema ( ID
                                   , VERSAO
                                   , DT_VERSAO
                                   )
                            values ( csf_own.versaosistema_seq.nextval -- ID
                                   , '2.9.6.1'                         -- VERSAO
                                   , sysdate                           -- DT_VERSAO
                                   )
/

commit
/

-------------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #73869 Criação de parâmetro CONTROLA_NRO_RPS
-------------------------------------------------------------------------------------------------------------------------------------------

DECLARE

 V_PARAM            CSF_OWN.PARAM_GERAL_SISTEMA.ID%TYPE;
 VN_MODULOSISTEMA   CSF_OWN.MODULO_SISTEMA.ID%TYPE;
 VN_GRUPOSISTEMA    CSF_OWN.GRUPO_SISTEMA.ID%TYPE;
 VN_USUARIO         CSF_OWN.NEO_USUARIO.ID%TYPE;
 VC_VL_BC_ICMS1     VARCHAR2(50);
 VC_VL_BC_ICMS2     VARCHAR2(50);
 V_COUNT            NUMBER ;
  --
BEGIN 
  -- VERIFICA SE EXISTE MODULO SISTEMA, SENAO CRIA 
  BEGIN
    SELECT MS.ID
      INTO VN_MODULOSISTEMA
      FROM CSF_OWN.MODULO_SISTEMA MS
     WHERE UPPER(MS.COD_MODULO) = UPPER('EMISSAO_DOC');          
  EXCEPTION
     WHEN NO_DATA_FOUND THEN  
         INSERT INTO CSF_OWN.MODULO_SISTEMA (ID, COD_MODULO, DSC_MODULO, OBSERVACAO)
          VALUES (CSF_OWN.MODULOSISTEMA_SEQ.NEXTVAL, 'EMISSAO_DOC', 'Modulo de emissão de documentos fiscais', 'Modulo de emissão de documentos fiscal (NF-e, NFS-e, CT-e, NFC-e)');
          COMMIT;   
     WHEN OTHERS THEN  
           RAISE_APPLICATION_ERROR ( -20101, 'Erro ao localizar modulo sistema EMISSAO_DOC - '||SQLERRM );
  END;    
  -- VERIFICA SE MODELO EXISTE GRUPO SISTEMA, SENAO CRIA 
  BEGIN      
    SELECT GS.ID
      INTO VN_GRUPOSISTEMA
      FROM CSF_OWN.GRUPO_SISTEMA GS
     WHERE GS.MODULO_ID = VN_MODULOSISTEMA
       AND UPPER(GS.COD_GRUPO) =  UPPER('NFSE');
  EXCEPTION
     WHEN NO_DATA_FOUND THEN  
        INSERT INTO CSF_OWN.GRUPO_SISTEMA (ID, MODULO_ID, COD_GRUPO, DSC_GRUPO, OBSERVACAO)
             VALUES (CSF_OWN.GRUPOSISTEMA_SEQ.NEXTVAL, VN_MODULOSISTEMA, 'NFSE', 'Grupo de parametros relacionados a Emiss?o de NFS-E', 'Grupo de parametros relacionados a Emiss?o de NFS-E');
        COMMIT;
     WHEN OTHERS THEN       
       RAISE_APPLICATION_ERROR ( -20101, 'Erro ao localizar grupo sistema NFSE - '||SQLERRM );
  END;  
  -- RECUPERA USUARIO ADMIN 
  BEGIN   
    SELECT NU.ID
      INTO VN_USUARIO
      FROM CSF_OWN.NEO_USUARIO NU
     WHERE UPPER(LOGIN) = UPPER('admin'); --USUÁRIO ADMINISTRADOR DO SISTEMA
  EXCEPTION
     WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR ( -20101, 'Erro ao localizar usuario Admin - '||SQLERRM );   
  END;
  --    
  IF VN_USUARIO IS NOT NULL  
     AND VN_MODULOSISTEMA IS NOT NULL 
     AND VN_GRUPOSISTEMA IS NOT NULL  THEN
    --
    -- VERIFICA SE MODELO PARAMETRO SISTEMA, SENAO CRIA 
    FOR X IN (SELECT E.ID EMPRESA_ID,
                     E.multorg_id
                FROM CSF_OWN.PESSOA P,
                     CSF_OWN.EMPRESA E
               WHERE P.ID = E.PESSOA_ID 
                 AND E.DM_SITUACAO = 1) --EMPRESAS ATIVAS
    loop
        BEGIN
          SELECT pGS.Vlr_Param
            INTO V_PARAM
            FROM CSF_OWN.PARAM_GERAL_SISTEMA PGS
           WHERE 1=1
             AND PGS.GRUPO_ID  = VN_GRUPOSISTEMA
             AND PGS.MODULO_ID = VN_MODULOSISTEMA
             AND UPPER(PGS.PARAM_NAME) = UPPER('CONTROLA_NRO_RPS')
             AND PGS.EMPRESA_ID = X.EMPRESA_ID;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN  
             INSERT INTO CSF_OWN.PARAM_GERAL_SISTEMA (ID, MULTORG_ID, EMPRESA_ID, MODULO_ID, GRUPO_ID, PARAM_NAME, DSC_PARAM, VLR_PARAM, USUARIO_ID_ALT, DT_ALTERACAO)
                  VALUES (CSF_OWN.PARAMGERALSISTEMA_SEQ.NEXTVAL, x.multorg_id, x.empresa_id, VN_MODULOSISTEMA, VN_GRUPOSISTEMA , 'CONTROLA_NRO_RPS', 'Indica se irá haver controle de numeração do RPS feito através pelo Compliance, a troca ocorre no momento da validação do documento. Antes de ativar o parametro, verifique se as Séries que precisarão de controle numérico estão parametrizadas para modelo de documento 99. Esse parametro não funciona para integração open interface. Valores possiveis: 0=Não / 1=Sim.', '0', VN_USUARIO, SYSDATE);
             COMMIT;
           WHEN OTHERS THEN
              NULL;
        END;  
        --
        IF V_PARAM IS NOT NULL THEN
          NULL;
        END IF;
    END LOOP;
    COMMIT;
  END IF;
END;
/

-------------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #73869 Criação de parâmetro CONTROLA_NRO_RPS
-------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - #74696 - CRIAÇÃO DE DOMINIO E CAMPO PARA IDENTIFICAÇÃO DO TIPO DE ARQUIVO A SER REGISTRADO NO COMPLIANCE
--------------------------------------------------------------------------------------------------------------------------------------

DECLARE
 V_COUNT            NUMBER ;
 
-- valida se ja existe a coluna na tabela NOTA_FISCAL_TOTAL, senao existir, cria.
  BEGIN
    SELECT COLUMN_NAME
      INTO V_COUNT
      FROM ALL_TAB_COLUMNS
     WHERE UPPER(OWNER)       = UPPER('CSF_OWN')
       AND UPPER(TABLE_NAME)  = UPPER('NOTA_FISCAL_PDF')
       AND UPPER(COLUMN_NAME) = UPPER('DM_TIPO_ARQ');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      EXECUTE IMMEDIATE 'ALTER TABLE CSF_OWN.NOTA_FISCAL_PDF ADD DM_TIPO_ARQ NUMBER DEFAULT 0';
      EXECUTE IMMEDIATE 'comment on column CSF_OWN.NOTA_FISCAL_PDF.DM_TIPO_ARQ is ''Defini o tipo de arquivo 0-PDF, 1-TIF''';
    WHEN OTHERS THEN
      NULL;
  END;
/
--
DECLARE
 V_COUNT            NUMBER ;
  --
-- VERIFICA SE MODELO EXISTE DOMINIO, SENAO CRIA 
  BEGIN      
    SELECT DM.ID
      INTO V_COUNT
      FROM CSF_OWN.DOMINIO DM
     WHERE DM.DOMINIO = 'NOTA_FISCAL_PDF.DM_TIPO_ARQ'
	   AND DM.VL = 0;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN  
        INSERT INTO CSF_OWN.DOMINIO (DOMINIO, VL, DESCR, ID)
             VALUES ('NOTA_FISCAL_PDF.DM_TIPO_ARQ', 0, ' Arquivo do tipo PDF ', DOMINIO_SEQ.NEXTVAL);
        COMMIT;
     WHEN OTHERS THEN       
       RAISE_APPLICATION_ERROR ( -20101, 'Erro ao localizar DOMINIO NOTA_FISCAL_PDF.DM_TIPO_ARQ - '||SQLERRM );
  END;  
/
--
DECLARE
 V_COUNT            NUMBER ;
-- VERIFICA SE MODELO EXISTE DOMINIO, SENAO CRIA 
  BEGIN      
    SELECT DM.ID
      INTO V_COUNT
      FROM CSF_OWN.DOMINIO DM
     WHERE DM.DOMINIO = 'NOTA_FISCAL_PDF.DM_TIPO_ARQ'
	   AND DM.VL = 1;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN  
        INSERT INTO CSF_OWN.DOMINIO (DOMINIO, VL, DESCR, ID)
             VALUES ('NOTA_FISCAL_PDF.DM_TIPO_ARQ', 1, ' Arquivo do tipo TIF ',DOMINIO_SEQ.NEXTVAL);
        COMMIT;
     WHEN OTHERS THEN       
       RAISE_APPLICATION_ERROR ( -20101, 'Erro ao localizar DOMINIO NOTA_FISCAL_PDF.DM_TIPO_ARQ - '||SQLERRM );
  END;  
/  
--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - #74696 - CRIAÇÃO DE DOMINIO E CAMPO PARA IDENTIFICAÇÃO DO TIPO DE ARQUIVO A SER REGISTRADO NO COMPLIANCE
--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
Prompt Inicio - Redmine #74820 - Parametro geral do sistema TIPO_CRED_GRUPO_CST_60
--------------------------------------------------------------------------------------------------------------------------------------

declare 
   vn_modulo_id   number := 0;
   vn_grupo_id    number := 0;
   vn_param_id    number := 0;
   vn_usuario_id  number := null;
begin
   
   -- MODULO DO SISTEMA --
   begin
      select ms.id
        into vn_modulo_id
        from CSF_OWN.MODULO_SISTEMA ms
       where ms.cod_modulo = 'OBRIG_FEDERAL';
   exception
      when no_data_found then
         vn_modulo_id := 0;
      when others then
         goto SAIR_SCRIPT;   
   end;
   --
   if vn_modulo_id = 0 then
      --
      insert into CSF_OWN.MODULO_SISTEMA
      values(CSF_OWN.MODULOSISTEMA_SEQ.NEXTVAL, 'OBRIG_FEDERAL', 'Obrigações Federais', 'Modulo que agrupa todas as obrigações federais exceto as contabeis ECD e ECF')
      returning id into vn_modulo_id;
      --
   end if;
   --
   -- GRUPO DO SISTEMA --
   begin
      select gs.id
        into vn_grupo_id
        from CSF_OWN.GRUPO_SISTEMA gs
       where gs.modulo_id = vn_modulo_id
         and gs.cod_grupo = 'EFD_CONTRIB';
   exception
      when no_data_found then
         vn_grupo_id := 0;
      when others then
         goto SAIR_SCRIPT;   
   end;
   --
   if vn_grupo_id = 0 then
      --
      insert into CSF_OWN.GRUPO_SISTEMA
      values(CSF_OWN.GRUPOSISTEMA_SEQ.NextVal, vn_modulo_id, 'EFD_CONTRIB', 'Parâmetro relacionados ao EFD Contribuições','Parâmetro relacionados ao EFD Contribuições')
      returning id into vn_grupo_id;
      --
   end if; 
   --  
   -- PARAMETRO DO SISTEMA --
   for x in (select * from mult_org m where m.dm_situacao = 1)
   loop
      begin
         select pgs.id
           into vn_param_id
           from CSF_OWN.PARAM_GERAL_SISTEMA pgs  -- UK: MULTORG_ID, EMPRESA_ID, MODULO_ID, GRUPO_ID, PARAM_NAME
          where pgs.multorg_id = x.id
            and pgs.empresa_id is null
            and pgs.modulo_id  = vn_modulo_id
            and pgs.grupo_id   = vn_grupo_id
            and pgs.param_name = 'TIPO_CRED_GRUPO_CST_60';
      exception
         when no_data_found then
            vn_param_id := 0;
         when others then
            goto SAIR_SCRIPT;   
      end;
      --
      --
      if vn_param_id = 0 then
         --
         -- Busca o usuário respondável pelo Mult_org
         begin
            select id
              into vn_usuario_id
              from CSF_OWN.NEO_USUARIO nu
             where upper(nu.login) = 'ADMIN';
         exception
            when no_data_found then
               begin
                  select min(id)
                    into vn_usuario_id
                    from CSF_OWN.NEO_USUARIO nu
                   where nu.multorg_id = x.id;
               exception
                  when others then
                     goto SAIR_SCRIPT;
               end;
         end;
         --
         insert into CSF_OWN.PARAM_GERAL_SISTEMA
         values( CSF_OWN.PARAMGERALSISTEMA_SEQ.NextVal
               , x.id
               , null
               , vn_modulo_id
               , vn_grupo_id
               , 'TIPO_CRED_GRUPO_CST_60'
               , 'Indica como deve ser montado o registro de tipo de crédito do M100/M500 quando o CST de Pis e Cofins for do grupo 60 (60, 61, 62...). Por padrão, toda vez que for utilizado esse CST será montado tipo de crédito 106, 206 ou 306, porém é possível indicar que esses só devem ser montados se a pessoa da nota for um produtor rural - indicado na PESSOA_TIPO_PARAM. Se o parâmetro for ativado, o tipo de crédito padrão passa a ser 107, 207 e 307 e para que seja montado 106, 206 ou 306 será necessário indicar pessoal da nota como produtor rural = Sim. Valores possíveis: 0 = Monta por padrão 106, 206 e 306 / 1 = Monta por padrão 107, 207 e 307.'
               , '0'
               , vn_usuario_id
               , sysdate);
         --
      end if;   
      --
   end loop;   
   --
   commit;
   --
   <<SAIR_SCRIPT>>
   rollback;
end;
/

--------------------------------------------------------------------------------------------------------------------------------------
Prompt Fim - Redmine #74820 - Parametro geral do sistema TIPO_CRED_GRUPO_CST_60
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Inicio - Redmine #74671  - Inclusão do Flexfield UNID_ORG - VW_CSF_CONHEC_TRANSP_EFD_FF
--------------------------------------------------------------------------------------------------------------------------------------
declare
   --
   cursor c_view is
      select a.id
        from csf_own.obj_util_integr a
       where a.obj_name = 'VW_CSF_CONHEC_TRANSP_EFD_FF';
   --
begin
   --
   for rec_view in c_view loop
      exit when c_view%notfound or (c_view%notfound) is null;
      --
      -- VL_PIS_ST
      begin
         insert into csf_own.ff_obj_util_integr ( id
                                                , objutilintegr_id
                                                , atributo
                                                , descr
                                                , dm_tipo_campo
                                                , tamanho
                                                , qtde_decimal )
              values                            ( csf_own.ffobjutilintegr_seq.nextval -- id
                                                , rec_view.id                         -- objutilintegr_id
                                                , 'CD_UNID_ORG'                       -- atributo
                                                , 'Codigo da Unidade Organizacional'  -- descr
                                                , 2                                   -- dm_tipo_campo (Tipo do campo/atributo (0-data, 1-numerico, 2-caractere)
                                                , 20                                  -- tamanho
                                                , 0                                   -- qtde_decimal
                                                );
         --
      exception
         when dup_val_on_index then
            begin
               update csf_own.ff_obj_util_integr ff
                  set ff.dm_tipo_campo    = 2
                    , ff.tamanho          = 20
                    , ff.qtde_decimal     = 0
                    , ff.descr            = 'Codigo da Unidade Organizacional'
                where ff.atributo         = 'CD_UNID_ORG'
                  and ff.objutilintegr_id = rec_view.id;
            exception
               when others then
                  raise_application_error(-20101, 'Erro no script #74671(CD_UNID_ORG). Erro:' || sqlerrm);
            end;
      end;
      --
      commit;
      --
   end loop;
   --
end;
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Fim - Redmine #74671  - Inclusão do Flexfield UNID_ORG - VW_CSF_CONHEC_TRANSP_EFD_FF
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Inicio - Redmine #74979  - Correção sobre Flexfield - Notas fiscais de servicos
--------------------------------------------------------------------------------------------------------------------------------------
declare
cursor c_ff is
    select ff.id, ff.dm_tipo_campo, ff.atributo ,ou.obj_name
        from csf_own.obj_util_integr    ou
           , csf_own.ff_obj_util_integr ff
       where ou.obj_name         = 'VW_CSF_IMP_ITEMNF_SERV_FF'/*ev_obj_name*/
         and ff.objutilintegr_id = ou.id
         and ff.atributo         = 'CD_TIPO_RET_IMP'
         and ff.dm_tipo_campo = 1 ;
begin
--
for rec in c_ff loop
    update csf_own.ff_obj_util_integr set dm_tipo_campo = 2
           where id =  rec.id;
end loop;
--
commit;
--
exception
  when others then
    null;
end;
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Fim - Redmine #74979  - Correção sobre Flexfield - Notas fiscais de servicos
--------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #75024 Atualização URL ambiente de homologação e Produção - Pouso Alegre - MG
-------------------------------------------------------------------------------------------------------------------------------------------

--CIDADE  : Pouso Alegre - MG
--IBGE    : 3152501 
--PADRAO  : SigCorp
--HABIL   : SIM
--WS_CANC : SIM

declare 
   --   
   -- dm_tp_amb (Tipo de Ambiente 1-Producao; 2-Homologacao)
   cursor c_dados is
      select   ( select id from csf_own.cidade where ibge_cidade = '3152501' ) id, dm_situacao,  versao,  dm_tp_amb,  dm_tp_soap,  dm_tp_serv, descr, url_wsdl, dm_upload, dm_ind_emit 
        from ( --Produção
			   select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  1 dm_tp_serv, 'Geração de NFS-e'                               descr, 'http://abrasfpousoalegre.sigcorp.com.br/servico.asmx' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  2 dm_tp_serv, 'Recepção e Processamento de lote de RPS'        descr, 'http://abrasfpousoalegre.sigcorp.com.br/servico.asmx' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  3 dm_tp_serv, 'Consulta de Situação de lote de RPS'            descr, 'http://abrasfpousoalegre.sigcorp.com.br/servico.asmx' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  4 dm_tp_serv, 'Consulta de NFS-e por RPS'                      descr, 'http://abrasfpousoalegre.sigcorp.com.br/servico.asmx' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  5 dm_tp_serv, 'Consulta de NFS-e'                              descr, 'http://abrasfpousoalegre.sigcorp.com.br/servico.asmx' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  6 dm_tp_serv, 'Cancelamento de NFS-e'                          descr, 'http://abrasfpousoalegre.sigcorp.com.br/servico.asmx' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  7 dm_tp_serv, 'Substituição de NFS-e'                          descr, 'http://abrasfpousoalegre.sigcorp.com.br/servico.asmx' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  8 dm_tp_serv, 'Consulta de Empresas Autorizadas a emitir NFS-e'descr, 'http://abrasfpousoalegre.sigcorp.com.br/servico.asmx' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  9 dm_tp_serv, 'Login'                                          descr, 'http://abrasfpousoalegre.sigcorp.com.br/servico.asmx' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap, 10 dm_tp_serv, 'Consulta de Lote de RPS'                        descr, 'http://abrasfpousoalegre.sigcorp.com.br/servico.asmx' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               --Homologação
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  1 dm_tp_serv, 'Geração de NFS-e'                               descr, 'http://testeabrasfpousoalegre.sigcorp.com.br/servico.asmx' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  2 dm_tp_serv, 'Recepção e Processamento de lote de RPS'        descr, 'http://testeabrasfpousoalegre.sigcorp.com.br/servico.asmx' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  3 dm_tp_serv, 'Consulta de Situação de lote de RPS'            descr, 'http://testeabrasfpousoalegre.sigcorp.com.br/servico.asmx' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  4 dm_tp_serv, 'Consulta de NFS-e por RPS'                      descr, 'http://testeabrasfpousoalegre.sigcorp.com.br/servico.asmx' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  5 dm_tp_serv, 'Consulta de NFS-e'                              descr, 'http://testeabrasfpousoalegre.sigcorp.com.br/servico.asmx' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  6 dm_tp_serv, 'Cancelamento de NFS-e'                          descr, 'http://testeabrasfpousoalegre.sigcorp.com.br/servico.asmx' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  7 dm_tp_serv, 'Substituição de NFS-e'                          descr, 'http://testeabrasfpousoalegre.sigcorp.com.br/servico.asmx' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  8 dm_tp_serv, 'Consulta de Empresas Autorizadas a emitir NFS-e'descr, 'http://testeabrasfpousoalegre.sigcorp.com.br/servico.asmx' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  9 dm_tp_serv, 'Login'                                          descr, 'http://testeabrasfpousoalegre.sigcorp.com.br/servico.asmx' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap, 10 dm_tp_serv, 'Consulta de Lote de RPS'                        descr, 'http://testeabrasfpousoalegre.sigcorp.com.br/servico.asmx' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual
              );
--   
begin   
   --
      for rec_dados in c_dados loop
         exit when c_dados%notfound or (c_dados%notfound) is null;
         --
         begin  
            insert into csf_own.cidade_webserv_nfse (  id
                                                    ,  cidade_id
                                                    ,  dm_situacao
                                                    ,  versao
                                                    ,  dm_tp_amb
                                                    ,  dm_tp_soap
                                                    ,  dm_tp_serv
                                                    ,  descr
                                                    ,  url_wsdl
                                                    ,  dm_upload
                                                    ,  dm_ind_emit  )    
                                             values (  csf_own.cidadewebservnfse_seq.nextval
                                                    ,  rec_dados.id
                                                    ,  rec_dados.dm_situacao
                                                    ,  rec_dados.versao
                                                    ,  rec_dados.dm_tp_amb
                                                    ,  rec_dados.dm_tp_soap
                                                    ,  rec_dados.dm_tp_serv
                                                    ,  rec_dados.descr
                                                    ,  rec_dados.url_wsdl
                                                    ,  rec_dados.dm_upload
                                                    ,  rec_dados.dm_ind_emit  ); 
            --
            commit;        
            --
         exception  
            when dup_val_on_index then 
               begin 
                  update csf_own.cidade_webserv_nfse 
                     set versao      = rec_dados.versao
                       , dm_tp_soap  = rec_dados.dm_tp_soap
                       , descr       = rec_dados.descr
                       , url_wsdl    = rec_dados.url_wsdl
                       , dm_upload   = rec_dados.dm_upload
                   where cidade_id   = rec_dados.id 
                     and dm_tp_amb   = rec_dados.dm_tp_amb 
                     and dm_tp_serv  = rec_dados.dm_tp_serv 
                     and dm_ind_emit = rec_dados.dm_ind_emit; 
                  --
                  commit; 
                  --
               exception when others then 
                  raise_application_error(-20101, 'Erro no script Redmine #75024 Atualização URL ambiente de homologação e Produção Pouso Alegre - MG' || sqlerrm);
               end; 
               --
         end;
         -- 
      --
      end loop;
   --
   commit;
   --
exception
   when others then
      raise_application_error(-20102, 'Erro no script Redmine #75024 Atualização URL ambiente de homologação e Produção Pouso Alegre - MG' || sqlerrm);
end;
/

declare
vn_count integer;
--
begin
  ---
  vn_count:=0;
  ---
  begin
    select count(1) into vn_count
    from  all_constraints 
    where owner = 'CSF_OWN'
      and constraint_name = 'CIDADENFSE_DMPADRAO_CK';
  exception
    when others then
      vn_count:=0;
  end;
  ---
  if vn_count = 1 then 
     execute immediate 'alter table CSF_OWN.CIDADE_NFSE drop constraint CIDADENFSE_DMPADRAO_CK';
     execute immediate 'alter table CSF_OWN.CIDADE_NFSE add constraint CIDADENFSE_DMPADRAO_CK check (dm_padrao in (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44))';
  elsif  vn_count = 0 then    
     execute immediate 'alter table CSF_OWN.CIDADE_NFSE add constraint CIDADENFSE_DMPADRAO_CK check (dm_padrao in (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44))';
  end if;
  ---
  commit;  

  insert into CSF_OWN.DOMINIO (  dominio
                              ,  vl
                              ,  descr
                              ,  id  )    
                       values (  'CIDADE_NFSE.DM_PADRAO'
                              ,  '44'
                              ,  'SigCorp'
                              ,  CSF_OWN.DOMINIO_SEQ.NEXTVAL  ); 
  --
  commit;        
  --
  exception  
      when dup_val_on_index then 
          begin 
              update CSF_OWN.DOMINIO 
                 set vl      = '44'
               where dominio = 'CIDADE_NFSE.DM_PADRAO'
                 and descr   = 'SigCorp'; 
	  	      --
              commit; 
              --
           exception when others then 
                raise_application_error(-20101, 'Erro no script Redmine #75024 Adicionar Padrão para emissão de NFS-e (SigCorp)' || sqlerrm);
             --
          end;
    
end;			
/
 
declare
--
vn_dm_tp_amb1  number  := 0;
vn_dm_tp_amb2  number  := 0;
vv_ibge_cidade cidade.ibge_cidade%type;
vv_padrao      dominio.descr%type;    
vv_habil       dominio.descr%type;
vv_ws_canc     dominio.descr%type;

--
Begin
	-- Popula variáveis
	vv_ibge_cidade := '3152501';
	vv_padrao      := 'SigCorp';     
	vv_habil       := 'SIM';
	vv_ws_canc     := 'SIM';

    begin
      --
      SELECT count(*)
        into vn_dm_tp_amb1
        from csf_own.empresa
       where dm_tp_amb = 1
       group by dm_tp_amb;
      exception when others then
        vn_dm_tp_amb1 := 0; 
      --
    end;
   --
    Begin
      --
      SELECT count(*)
        into vn_dm_tp_amb2
        from csf_own.empresa
       where dm_tp_amb = 2
       group by dm_tp_amb;
      --
	  exception when others then 
        vn_dm_tp_amb2 := 0;
     --
    end;
--
	if vn_dm_tp_amb2 > vn_dm_tp_amb1 then
	  --
	  begin
	    --  
	    update csf_own.cidade_webserv_nfse
		   set url_wsdl = 'DESATIVADO AMBIENTE DE PRODUCAO'
	     where cidade_id in (select id
							   from csf_own.cidade
							  where ibge_cidade in (vv_ibge_cidade))
		   and dm_tp_amb = 1;
	    exception when others then
		  null;
	  end;
	  --  
	  commit;
	  --
	end if;
--
	begin
		--
		update csf_own.cidade_nfse set dm_padrao    = (select distinct vl from csf_own.dominio where upper(dominio) = upper('cidade_nfse.dm_padrao') and upper(descr) = upper(vv_padrao))
								       , dm_habil   = (select distinct vl from csf_own.dominio where upper(dominio) = upper('cidade_nfse.dm_habil') and upper(descr) = upper(vv_habil))
								       , dm_ws_canc = (select distinct vl from csf_own.dominio where upper(dominio) = upper('cidade_nfse.dm_ws_canc') and upper(descr) = upper(vv_ws_canc))
         where cidade_id = (select distinct id from csf_own.cidade where ibge_cidade in (vv_ibge_cidade));
		exception when others then
			raise_application_error(-20103, 'Erro no script Redmine #75024 Atualização do Padrão Pouso Alegre - MG' || sqlerrm);
    end;
	--
	commit;
	--
--
end;
--
/  

-------------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #75024 Atualização URL ambiente de homologação e Produção - Pouso Alegre - MG
-------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - #75020 - Tirar obrigatoriedade de campo IMP_ITEMCF.CODST_ID
--------------------------------------------------------------------------------------------------------------------------------------

DECLARE
 V_COUNT            NUMBER;
 
 BEGIN
	  -- valida se ja existe a coluna CODST_ID na tabela IMP_ITEMCF, se existir altera para null.
	  BEGIN
		SELECT COUNT(COLUMN_NAME)
		  INTO V_COUNT
		  FROM ALL_TAB_COLUMNS
		 WHERE UPPER(OWNER)       = UPPER('CSF_OWN')
		   AND UPPER(TABLE_NAME)  = UPPER('IMP_ITEMCF')
		   AND UPPER(COLUMN_NAME) = UPPER('CODST_ID')
		   AND NULLABLE           = 'Y';
	  EXCEPTION
		WHEN OTHERS THEN
		  V_COUNT := 0;
	  END;
	  
	  IF V_COUNT = 0 THEN
		--
		EXECUTE IMMEDIATE 'ALTER TABLE CSF_OWN.IMP_ITEMCF MODIFY CODST_ID number null';
		--
	  END IF;
END;
/
----------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #75020 Tirar obrigatoriedade de campo IMP_ITEMCF.CODST_ID
----------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine Redmine #73698  - Inclusão de dominio no banco e ajuste em check
-------------------------------------------------------------------------------------------------------------------------------------------
DECLARE
vn_count INTEGER;
--
BEGIN
  ---
  vn_count := 0;
  ---
  BEGIN
    SELECT COUNT(1) 
	  INTO vn_count
      FROM all_constraints 
     WHERE owner = 'CSF_OWN'
       AND constraint_name = 'EVENTOCTE_STINTEGRA_CK';
  EXCEPTION
    WHEN OTHERS THEN
      vn_count := 0;
  END;
  ---
  IF vn_count = 1 THEN 
     EXECUTE IMMEDIATE 'alter table CSF_OWN.EVENTO_CTE drop constraint EVENTOCTE_STINTEGRA_CK';
     EXECUTE IMMEDIATE 'alter table CSF_OWN.EVENTO_CTE add constraint EVENTOCTE_STINTEGRA_CK check (DM_ST_INTEGRA in (0, 5, 7, 8, 9))';
  ELSIF  vn_count = 0 THEN    
     EXECUTE IMMEDIATE 'alter table CSF_OWN.EVENTO_CTE add constraint EVENTOCTE_STINTEGRA_CK check (DM_ST_INTEGRA in (0, 5, 7, 8, 9))';
  END IF;
  --
  COMMIT;  

END;
/

DECLARE
vn_count INTEGER;
--
BEGIN
  ---
  vn_count := 0;
  ---
  BEGIN
    SELECT COUNT(1) 
	  INTO vn_count
      FROM CSF_OWN.DOMINIO
     WHERE DOMINIO = 'EVENTO_CTE.DM_ST_INTEGRA'
	   AND VL = '5';
  EXCEPTION
    WHEN OTHERS THEN
      vn_count := 0;
  END;
  ---
  IF vn_count <> 0 THEN 
	BEGIN
		INSERT INTO CSF_OWN.DOMINIO ( dominio
									, vl
									, descr
									, id )    
                    VALUES ( 'EVENTO_CTE.DM_ST_INTEGRA'
                           , '5'
                           , 'Integrado via digitacão manual pelo portal'
                           , CSF_OWN.DOMINIO_SEQ.NEXTVAL ); 
		--
		COMMIT;
		--
	EXCEPTION
		WHEN OTHERS THEN
			raise_application_error(-20101, 'Erro no script Redmine #73698 Adicionar valor de Dominio para EVENTO_CTE.DM_ST_INTEGRA.' || sqlerrm);
    END;
  ELSIF vn_count = 0 THEN
	BEGIN
		UPDATE CSF_OWN.DOMINIO 
               SET descr   = 'Integrado via digitacão manual pelo portal'
         WHERE dominio = 'EVENTO_CTE.DM_ST_INTEGRA'
		   AND vl = '5'; 
	  	--
        COMMIT; 
        --
	EXCEPTION
		WHEN OTHERS THEN
			raise_application_error(-20102, 'Erro no script Redmine #73698 Alterar valor de Dominio para EVENTO_CTE.DM_ST_INTEGRA.' || sqlerrm);
    END;
  END IF;
END;  
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Fim - Redmine #73698  - Inclusão de dominio no banco e ajuste em check
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - #75086 - Tirar obrigatoriedade de campo nota_fiscal_mde.notafiscal_id
--------------------------------------------------------------------------------------------------------------------------------------

DECLARE
 V_COUNT            NUMBER;
 
 BEGIN
	  -- valida se ja existe a coluna notafiscal_id na tabela nota_fiscal_mde, se existir altera para null.
	  BEGIN
		SELECT COUNT(COLUMN_NAME)
		  INTO V_COUNT
		  FROM ALL_TAB_COLUMNS
		 WHERE UPPER(OWNER)       = UPPER('CSF_OWN')
		   AND UPPER(TABLE_NAME)  = UPPER('NOTA_FISCAL_MDE')
		   AND UPPER(COLUMN_NAME) = UPPER('NOTAFISCAL_ID')
		   AND NULLABLE           = 'Y';
	  EXCEPTION
		WHEN OTHERS THEN
		  V_COUNT := 0;
	  END;
	  
	  IF V_COUNT = 0 THEN
		--
		EXECUTE IMMEDIATE 'ALTER TABLE CSF_OWN.NOTA_FISCAL_MDE MODIFY NOTAFISCAL_ID number null';
		--
	  END IF;
END; 
/
----------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #75086 Tirar obrigatoriedade de campo nota_fiscal_mde.notafiscal_id
----------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #75105: Criar tabela HIST_ST_CONHEC_TRANSP
--------------------------------------------------------------------------------------------------------------------------------------
declare
  --
  vv_sql    long;
  vn_existe number := 0;
  --
begin
   --
   begin
      select distinct 1
        into vn_existe
      from SYS.ALL_TABLES t
      where t.OWNER = 'CSF_OWN'
        and t.TABLE_NAME = 'HIST_ST_CONHEC_TRANSP';
   exception
      when no_data_found then
         vn_existe := 0;
      when others then
         vn_existe := -1;
   end;
   --
   if nvl(vn_existe, 0) = 0 then
      --
      vv_sql := '
         CREATE TABLE CSF_OWN.HIST_ST_CONHEC_TRANSP
         (
           ID                    NUMBER                     NOT NULL,
           CONHECTRANSP_ID       NUMBER                     NOT NULL,
           DM_ST_PROC            NUMBER(2)                  NOT NULL,
           DT_HR                 DATE                       NOT NULL
		   )TABLESPACE CSF_DATA';
      --   
      begin
         execute immediate vv_sql;
      exception
         when others then
            null;
      end;   
      --
   end if;    
   --
   begin
      execute immediate 'comment on table CSF_OWN.HIST_ST_CONHEC_TRANSP is ''Tabela de Historico da Situação do Conhecimento de transporte''';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'comment on column CSF_OWN.HIST_ST_CONHEC_TRANSP.CONHECTRANSP_ID is ''ID que relaciona a tabela do Conhecimento de transporte''';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'comment on column CSF_OWN.HIST_ST_CONHEC_TRANSP.DM_ST_PROC is ''Situação do processo do Conhecimento de transporte''';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'comment on column CSF_OWN.HIST_ST_CONHEC_TRANSP.DT_HR is ''Data e hora do registro de historico''';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'alter table CSF_OWN.HIST_ST_CONHEC_TRANSP add constraint HISTSTCONHECTRANSP_PK primary key (ID)';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'alter table CSF_OWN.HIST_ST_CONHEC_TRANSP add constraint HISTSTCONHECTRANSP_FK foreign key (CONHECTRANSP_ID) references CONHEC_TRANSP (ID)';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'create index HISTSTCONHECTRANSP_FK_I on CSF_OWN.HIST_ST_CONHEC_TRANSP (CONHECTRANSP_ID) TABLESPACE CSF_INDEX';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'create index HISTSTCONHECTRANSP_IDX1 on CSF_OWN.HIST_ST_CONHEC_TRANSP (DM_ST_PROC) TABLESPACE CSF_INDEX';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'create index HISTSTCONHECTRANSP_IDX2 on CSF_OWN.HIST_ST_CONHEC_TRANSP (DT_HR) TABLESPACE CSF_INDEX';
   exception
      when others then
         null;
   end;   
   --
   BEGIN
      EXECUTE IMMEDIATE '
         CREATE SEQUENCE CSF_OWN.HISTSTCONHECTRANSP_SEQ
         INCREMENT BY 1
         START WITH   0
         MINVALUE     0
         MAXVALUE     999999999999999999999999999
         CACHE        100
      ';
   EXCEPTION
     WHEN OTHERS THEN
        IF SQLCODE = -955 THEN
           NULL;
        ELSE
          RAISE;
        END IF;
   END;
   --
   --
   begin
      execute immediate 'grant all on CSF_OWN.HIST_ST_CONHEC_TRANSP to CSF_WORK';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'grant all on CSF_OWN.HIST_ST_CONHEC_TRANSP to CONSULTORIA';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'grant all on CSF_OWN.HIST_ST_CONHEC_TRANSP to DESENV_USER';
   exception
      when others then
         null;
   end;   
   --
end;
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #75105: Criar tabela HIST_ST_CONHEC_TRANSP
--------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #75094 Atualização URL ambiente de homologação e Produção - Pojuca - BA
-------------------------------------------------------------------------------------------------------------------------------------------

--CIDADE  : Pojuca - BA
--IBGE    : 2925204
--PADRAO  : Saatri
--HABIL   : SIM
--WS_CANC : SIM

declare 
   --   
   -- dm_tp_amb (Tipo de Ambiente 1-Producao; 2-Homologacao)
   cursor c_dados is
      select   ( select id from csf_own.cidade where ibge_cidade = '2925204' ) id, dm_situacao,  versao,  dm_tp_amb,  dm_tp_soap,  dm_tp_serv, descr, url_wsdl, dm_upload, dm_ind_emit 
        from ( --Produção
			   select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  1 dm_tp_serv, 'Geração de NFS-e'                               descr, 'https://pojuca.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  2 dm_tp_serv, 'Recepção e Processamento de lote de RPS'        descr, 'https://pojuca.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  3 dm_tp_serv, 'Consulta de Situação de lote de RPS'            descr, 'https://pojuca.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  4 dm_tp_serv, 'Consulta de NFS-e por RPS'                      descr, 'https://pojuca.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  5 dm_tp_serv, 'Consulta de NFS-e'                              descr, 'https://pojuca.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  6 dm_tp_serv, 'Cancelamento de NFS-e'                          descr, 'https://pojuca.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  7 dm_tp_serv, 'Substituição de NFS-e'                          descr, 'https://pojuca.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  8 dm_tp_serv, 'Consulta de Empresas Autorizadas a emitir NFS-e'descr, 'https://pojuca.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  9 dm_tp_serv, 'Login'                                          descr, 'https://pojuca.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap, 10 dm_tp_serv, 'Consulta de Lote de RPS'                        descr, 'https://pojuca.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               --Homologação
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  1 dm_tp_serv, 'Geração de NFS-e'                               descr, 'https://homologa-pojuca.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  2 dm_tp_serv, 'Recepção e Processamento de lote de RPS'        descr, 'https://homologa-pojuca.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  3 dm_tp_serv, 'Consulta de Situação de lote de RPS'            descr, 'https://homologa-pojuca.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  4 dm_tp_serv, 'Consulta de NFS-e por RPS'                      descr, 'https://homologa-pojuca.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  5 dm_tp_serv, 'Consulta de NFS-e'                              descr, 'https://homologa-pojuca.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  6 dm_tp_serv, 'Cancelamento de NFS-e'                          descr, 'https://homologa-pojuca.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  7 dm_tp_serv, 'Substituição de NFS-e'                          descr, 'https://homologa-pojuca.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  8 dm_tp_serv, 'Consulta de Empresas Autorizadas a emitir NFS-e'descr, 'https://homologa-pojuca.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  9 dm_tp_serv, 'Login'                                          descr, 'https://homologa-pojuca.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap, 10 dm_tp_serv, 'Consulta de Lote de RPS'                        descr, 'https://homologa-pojuca.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual
              );
--   
begin   
   --
      for rec_dados in c_dados loop
         exit when c_dados%notfound or (c_dados%notfound) is null;
         --
         begin  
            insert into csf_own.cidade_webserv_nfse (  id
                                                    ,  cidade_id
                                                    ,  dm_situacao
                                                    ,  versao
                                                    ,  dm_tp_amb
                                                    ,  dm_tp_soap
                                                    ,  dm_tp_serv
                                                    ,  descr
                                                    ,  url_wsdl
                                                    ,  dm_upload
                                                    ,  dm_ind_emit  )    
                                             values (  csf_own.cidadewebservnfse_seq.nextval
                                                    ,  rec_dados.id
                                                    ,  rec_dados.dm_situacao
                                                    ,  rec_dados.versao
                                                    ,  rec_dados.dm_tp_amb
                                                    ,  rec_dados.dm_tp_soap
                                                    ,  rec_dados.dm_tp_serv
                                                    ,  rec_dados.descr
                                                    ,  rec_dados.url_wsdl
                                                    ,  rec_dados.dm_upload
                                                    ,  rec_dados.dm_ind_emit  ); 
            --
            commit;        
            --
         exception  
            when dup_val_on_index then 
               begin 
                  update csf_own.cidade_webserv_nfse 
                     set versao      = rec_dados.versao
                       , dm_tp_soap  = rec_dados.dm_tp_soap
                       , descr       = rec_dados.descr
                       , url_wsdl    = rec_dados.url_wsdl
                       , dm_upload   = rec_dados.dm_upload
                   where cidade_id   = rec_dados.id 
                     and dm_tp_amb   = rec_dados.dm_tp_amb 
                     and dm_tp_serv  = rec_dados.dm_tp_serv 
                     and dm_ind_emit = rec_dados.dm_ind_emit; 
                  --
                  commit; 
                  --
               exception when others then 
                  raise_application_error(-20101, 'Erro no script Redmine #75094 Atualização URL ambiente de homologação e Produção Pojuca - BA' || sqlerrm);
               end; 
               --
         end;
         -- 
      --
      end loop;
   --
   commit;
   --
exception
   when others then
      raise_application_error(-20102, 'Erro no script Redmine #75094 Atualização URL ambiente de homologação e Produção Pojuca - BA' || sqlerrm);
end;
/

declare
--
vn_dm_tp_amb1  number  := 0;
vn_dm_tp_amb2  number  := 0;
vv_ibge_cidade cidade.ibge_cidade%type;
vv_padrao      dominio.descr%type;    
vv_habil       dominio.descr%type;
vv_ws_canc     dominio.descr%type;

--
Begin
	-- Popula variáveis
	vv_ibge_cidade := '2925204';
	vv_padrao      := 'Saatri';     
	vv_habil       := 'SIM';
	vv_ws_canc     := 'SIM';

    begin
      --
      SELECT count(*)
        into vn_dm_tp_amb1
        from csf_own.empresa
       where dm_tp_amb = 1
       group by dm_tp_amb;
      exception when others then
        vn_dm_tp_amb1 := 0; 
      --
    end;
   --
    Begin
      --
      SELECT count(*)
        into vn_dm_tp_amb2
        from csf_own.empresa
       where dm_tp_amb = 2
       group by dm_tp_amb;
      --
	  exception when others then 
        vn_dm_tp_amb2 := 0;
     --
    end;
--
	if vn_dm_tp_amb2 > vn_dm_tp_amb1 then
	  --
	  begin
	    --  
	    update csf_own.cidade_webserv_nfse
		   set url_wsdl = 'DESATIVADO AMBIENTE DE PRODUCAO'
	     where cidade_id in (select id
							   from csf_own.cidade
							  where ibge_cidade in (vv_ibge_cidade))
		   and dm_tp_amb = 1;
	    exception when others then
		  null;
	  end;
	  --  
	  commit;
	  --
	end if;
--
	begin
		--
		update csf_own.cidade_nfse set dm_padrao    = (select distinct vl from csf_own.dominio where upper(dominio) = upper('cidade_nfse.dm_padrao') and upper(descr) = upper(vv_padrao))
								       , dm_habil   = (select distinct vl from csf_own.dominio where upper(dominio) = upper('cidade_nfse.dm_habil') and upper(descr) = upper(vv_habil))
								       , dm_ws_canc = (select distinct vl from csf_own.dominio where upper(dominio) = upper('cidade_nfse.dm_ws_canc') and upper(descr) = upper(vv_ws_canc))
         where cidade_id = (select distinct id from csf_own.cidade where ibge_cidade in (vv_ibge_cidade));
		exception when others then
			raise_application_error(-20103, 'Erro no script Redmine #75094 Atualização do Padrão Pojuca - BA' || sqlerrm);
    end;
	--
	commit;
	--
--
end;
--
/  

-------------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #75094 Atualização URL ambiente de homologação e Produção - Pojuca - BA
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #75094 Atualização URL ambiente de homologação e Produção - São Francisco do Conde - BA
-------------------------------------------------------------------------------------------------------------------------------------------

--CIDADE  : São Francisco do Conde - BA
--IBGE    : 2929206
--PADRAO  : Saatri
--HABIL   : SIM
--WS_CANC : SIM

declare 
   --   
   -- dm_tp_amb (Tipo de Ambiente 1-Producao; 2-Homologacao)
   cursor c_dados is
      select   ( select id from csf_own.cidade where ibge_cidade = '2929206' ) id, dm_situacao,  versao,  dm_tp_amb,  dm_tp_soap,  dm_tp_serv, descr, url_wsdl, dm_upload, dm_ind_emit 
        from ( --Produção
			   select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  1 dm_tp_serv, 'Geração de NFS-e'                               descr, 'https://sfconde.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  2 dm_tp_serv, 'Recepção e Processamento de lote de RPS'        descr, 'https://sfconde.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  3 dm_tp_serv, 'Consulta de Situação de lote de RPS'            descr, 'https://sfconde.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  4 dm_tp_serv, 'Consulta de NFS-e por RPS'                      descr, 'https://sfconde.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  5 dm_tp_serv, 'Consulta de NFS-e'                              descr, 'https://sfconde.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  6 dm_tp_serv, 'Cancelamento de NFS-e'                          descr, 'https://sfconde.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  7 dm_tp_serv, 'Substituição de NFS-e'                          descr, 'https://sfconde.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  8 dm_tp_serv, 'Consulta de Empresas Autorizadas a emitir NFS-e'descr, 'https://sfconde.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  9 dm_tp_serv, 'Login'                                          descr, 'https://sfconde.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap, 10 dm_tp_serv, 'Consulta de Lote de RPS'                        descr, 'https://sfconde.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               --Homologação
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  1 dm_tp_serv, 'Geração de NFS-e'                               descr, 'https://homologa-sfconde.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  2 dm_tp_serv, 'Recepção e Processamento de lote de RPS'        descr, 'https://homologa-sfconde.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  3 dm_tp_serv, 'Consulta de Situação de lote de RPS'            descr, 'https://homologa-sfconde.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  4 dm_tp_serv, 'Consulta de NFS-e por RPS'                      descr, 'https://homologa-sfconde.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  5 dm_tp_serv, 'Consulta de NFS-e'                              descr, 'https://homologa-sfconde.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  6 dm_tp_serv, 'Cancelamento de NFS-e'                          descr, 'https://homologa-sfconde.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  7 dm_tp_serv, 'Substituição de NFS-e'                          descr, 'https://homologa-sfconde.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  8 dm_tp_serv, 'Consulta de Empresas Autorizadas a emitir NFS-e'descr, 'https://homologa-sfconde.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  9 dm_tp_serv, 'Login'                                          descr, 'https://homologa-sfconde.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap, 10 dm_tp_serv, 'Consulta de Lote de RPS'                        descr, 'https://homologa-sfconde.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual
              );
--   
begin   
   --
      for rec_dados in c_dados loop
         exit when c_dados%notfound or (c_dados%notfound) is null;
         --
         begin  
            insert into csf_own.cidade_webserv_nfse (  id
                                                    ,  cidade_id
                                                    ,  dm_situacao
                                                    ,  versao
                                                    ,  dm_tp_amb
                                                    ,  dm_tp_soap
                                                    ,  dm_tp_serv
                                                    ,  descr
                                                    ,  url_wsdl
                                                    ,  dm_upload
                                                    ,  dm_ind_emit  )    
                                             values (  csf_own.cidadewebservnfse_seq.nextval
                                                    ,  rec_dados.id
                                                    ,  rec_dados.dm_situacao
                                                    ,  rec_dados.versao
                                                    ,  rec_dados.dm_tp_amb
                                                    ,  rec_dados.dm_tp_soap
                                                    ,  rec_dados.dm_tp_serv
                                                    ,  rec_dados.descr
                                                    ,  rec_dados.url_wsdl
                                                    ,  rec_dados.dm_upload
                                                    ,  rec_dados.dm_ind_emit  ); 
            --
            commit;        
            --
         exception  
            when dup_val_on_index then 
               begin 
                  update csf_own.cidade_webserv_nfse 
                     set versao      = rec_dados.versao
                       , dm_tp_soap  = rec_dados.dm_tp_soap
                       , descr       = rec_dados.descr
                       , url_wsdl    = rec_dados.url_wsdl
                       , dm_upload   = rec_dados.dm_upload
                   where cidade_id   = rec_dados.id 
                     and dm_tp_amb   = rec_dados.dm_tp_amb 
                     and dm_tp_serv  = rec_dados.dm_tp_serv 
                     and dm_ind_emit = rec_dados.dm_ind_emit; 
                  --
                  commit; 
                  --
               exception when others then 
                  raise_application_error(-20101, 'Erro no script Redmine #75094 Atualização URL ambiente de homologação e Produção São Francisco do Conde - BA' || sqlerrm);
               end; 
               --
         end;
         -- 
      --
      end loop;
   --
   commit;
   --
exception
   when others then
      raise_application_error(-20102, 'Erro no script Redmine #75094 Atualização URL ambiente de homologação e Produção São Francisco do Conde - BA' || sqlerrm);
end;
/

declare
--
vn_dm_tp_amb1  number  := 0;
vn_dm_tp_amb2  number  := 0;
vv_ibge_cidade cidade.ibge_cidade%type;
vv_padrao      dominio.descr%type;    
vv_habil       dominio.descr%type;
vv_ws_canc     dominio.descr%type;

--
Begin
	-- Popula variáveis
	vv_ibge_cidade := '2929206';
	vv_padrao      := 'Saatri';     
	vv_habil       := 'SIM';
	vv_ws_canc     := 'SIM';

    begin
      --
      SELECT count(*)
        into vn_dm_tp_amb1
        from csf_own.empresa
       where dm_tp_amb = 1
       group by dm_tp_amb;
      exception when others then
        vn_dm_tp_amb1 := 0; 
      --
    end;
   --
    Begin
      --
      SELECT count(*)
        into vn_dm_tp_amb2
        from csf_own.empresa
       where dm_tp_amb = 2
       group by dm_tp_amb;
      --
	  exception when others then 
        vn_dm_tp_amb2 := 0;
     --
    end;
--
	if vn_dm_tp_amb2 > vn_dm_tp_amb1 then
	  --
	  begin
	    --  
	    update csf_own.cidade_webserv_nfse
		   set url_wsdl = 'DESATIVADO AMBIENTE DE PRODUCAO'
	     where cidade_id in (select id
							   from csf_own.cidade
							  where ibge_cidade in (vv_ibge_cidade))
		   and dm_tp_amb = 1;
	    exception when others then
		  null;
	  end;
	  --  
	  commit;
	  --
	end if;
--
	begin
		--
		update csf_own.cidade_nfse set dm_padrao    = (select distinct vl from csf_own.dominio where upper(dominio) = upper('cidade_nfse.dm_padrao') and upper(descr) = upper(vv_padrao))
								       , dm_habil   = (select distinct vl from csf_own.dominio where upper(dominio) = upper('cidade_nfse.dm_habil') and upper(descr) = upper(vv_habil))
								       , dm_ws_canc = (select distinct vl from csf_own.dominio where upper(dominio) = upper('cidade_nfse.dm_ws_canc') and upper(descr) = upper(vv_ws_canc))
         where cidade_id = (select distinct id from csf_own.cidade where ibge_cidade in (vv_ibge_cidade));
		exception when others then
			raise_application_error(-20103, 'Erro no script Redmine #75094 Atualização do Padrão São Francisco do Conde - BA' || sqlerrm);
    end;
	--
	commit;
	--
--
end;
--
/  

-------------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #75094 Atualização URL ambiente de homologação e Produção - São Francisco do Conde - BA
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #75094 Atualização URL ambiente de homologação e Produção - São Sebastião do Passé - BA
-------------------------------------------------------------------------------------------------------------------------------------------

--CIDADE  : São Sebastião do Passé - BA
--IBGE    : 2929503
--PADRAO  : Saatri
--HABIL   : SIM
--WS_CANC : SIM

declare 
   --   
   -- dm_tp_amb (Tipo de Ambiente 1-Producao; 2-Homologacao)
   cursor c_dados is
      select   ( select id from csf_own.cidade where ibge_cidade = '2929503' ) id, dm_situacao,  versao,  dm_tp_amb,  dm_tp_soap,  dm_tp_serv, descr, url_wsdl, dm_upload, dm_ind_emit 
        from ( --Produção
			   select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  1 dm_tp_serv, 'Geração de NFS-e'                               descr, 'https://saosebastiaodopasse.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  2 dm_tp_serv, 'Recepção e Processamento de lote de RPS'        descr, 'https://saosebastiaodopasse.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  3 dm_tp_serv, 'Consulta de Situação de lote de RPS'            descr, 'https://saosebastiaodopasse.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  4 dm_tp_serv, 'Consulta de NFS-e por RPS'                      descr, 'https://saosebastiaodopasse.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  5 dm_tp_serv, 'Consulta de NFS-e'                              descr, 'https://saosebastiaodopasse.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  6 dm_tp_serv, 'Cancelamento de NFS-e'                          descr, 'https://saosebastiaodopasse.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  7 dm_tp_serv, 'Substituição de NFS-e'                          descr, 'https://saosebastiaodopasse.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  8 dm_tp_serv, 'Consulta de Empresas Autorizadas a emitir NFS-e'descr, 'https://saosebastiaodopasse.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  9 dm_tp_serv, 'Login'                                          descr, 'https://saosebastiaodopasse.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap, 10 dm_tp_serv, 'Consulta de Lote de RPS'                        descr, 'https://saosebastiaodopasse.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               --Homologação
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  1 dm_tp_serv, 'Geração de NFS-e'                               descr, 'https://homologa-saosebastiaodopasse.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  2 dm_tp_serv, 'Recepção e Processamento de lote de RPS'        descr, 'https://homologa-saosebastiaodopasse.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  3 dm_tp_serv, 'Consulta de Situação de lote de RPS'            descr, 'https://homologa-saosebastiaodopasse.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  4 dm_tp_serv, 'Consulta de NFS-e por RPS'                      descr, 'https://homologa-saosebastiaodopasse.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  5 dm_tp_serv, 'Consulta de NFS-e'                              descr, 'https://homologa-saosebastiaodopasse.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  6 dm_tp_serv, 'Cancelamento de NFS-e'                          descr, 'https://homologa-saosebastiaodopasse.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  7 dm_tp_serv, 'Substituição de NFS-e'                          descr, 'https://homologa-saosebastiaodopasse.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  8 dm_tp_serv, 'Consulta de Empresas Autorizadas a emitir NFS-e'descr, 'https://homologa-saosebastiaodopasse.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  9 dm_tp_serv, 'Login'                                          descr, 'https://homologa-saosebastiaodopasse.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap, 10 dm_tp_serv, 'Consulta de Lote de RPS'                        descr, 'https://homologa-saosebastiaodopasse.saatri.com.br/servicos/nfse.svc' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual
              );
--   
begin   
   --
      for rec_dados in c_dados loop
         exit when c_dados%notfound or (c_dados%notfound) is null;
         --
         begin  
            insert into csf_own.cidade_webserv_nfse (  id
                                                    ,  cidade_id
                                                    ,  dm_situacao
                                                    ,  versao
                                                    ,  dm_tp_amb
                                                    ,  dm_tp_soap
                                                    ,  dm_tp_serv
                                                    ,  descr
                                                    ,  url_wsdl
                                                    ,  dm_upload
                                                    ,  dm_ind_emit  )    
                                             values (  csf_own.cidadewebservnfse_seq.nextval
                                                    ,  rec_dados.id
                                                    ,  rec_dados.dm_situacao
                                                    ,  rec_dados.versao
                                                    ,  rec_dados.dm_tp_amb
                                                    ,  rec_dados.dm_tp_soap
                                                    ,  rec_dados.dm_tp_serv
                                                    ,  rec_dados.descr
                                                    ,  rec_dados.url_wsdl
                                                    ,  rec_dados.dm_upload
                                                    ,  rec_dados.dm_ind_emit  ); 
            --
            commit;        
            --
         exception  
            when dup_val_on_index then 
               begin 
                  update csf_own.cidade_webserv_nfse 
                     set versao      = rec_dados.versao
                       , dm_tp_soap  = rec_dados.dm_tp_soap
                       , descr       = rec_dados.descr
                       , url_wsdl    = rec_dados.url_wsdl
                       , dm_upload   = rec_dados.dm_upload
                   where cidade_id   = rec_dados.id 
                     and dm_tp_amb   = rec_dados.dm_tp_amb 
                     and dm_tp_serv  = rec_dados.dm_tp_serv 
                     and dm_ind_emit = rec_dados.dm_ind_emit; 
                  --
                  commit; 
                  --
               exception when others then 
                  raise_application_error(-20101, 'Erro no script Redmine #75094 Atualização URL ambiente de homologação e Produção São Sebastião do Passé - BA' || sqlerrm);
               end; 
               --
         end;
         -- 
      --
      end loop;
   --
   commit;
   --
exception
   when others then
      raise_application_error(-20102, 'Erro no script Redmine #75094 Atualização URL ambiente de homologação e Produção São Sebastião do Passé - BA' || sqlerrm);
end;
/

declare
--
vn_dm_tp_amb1  number  := 0;
vn_dm_tp_amb2  number  := 0;
vv_ibge_cidade cidade.ibge_cidade%type;
vv_padrao      dominio.descr%type;    
vv_habil       dominio.descr%type;
vv_ws_canc     dominio.descr%type;

--
Begin
	-- Popula variáveis
	vv_ibge_cidade := '2929503';
	vv_padrao      := 'Saatri';     
	vv_habil       := 'SIM';
	vv_ws_canc     := 'SIM';

    begin
      --
      SELECT count(*)
        into vn_dm_tp_amb1
        from csf_own.empresa
       where dm_tp_amb = 1
       group by dm_tp_amb;
      exception when others then
        vn_dm_tp_amb1 := 0; 
      --
    end;
   --
    Begin
      --
      SELECT count(*)
        into vn_dm_tp_amb2
        from csf_own.empresa
       where dm_tp_amb = 2
       group by dm_tp_amb;
      --
	  exception when others then 
        vn_dm_tp_amb2 := 0;
     --
    end;
--
	if vn_dm_tp_amb2 > vn_dm_tp_amb1 then
	  --
	  begin
	    --  
	    update csf_own.cidade_webserv_nfse
		   set url_wsdl = 'DESATIVADO AMBIENTE DE PRODUCAO'
	     where cidade_id in (select id
							   from csf_own.cidade
							  where ibge_cidade in (vv_ibge_cidade))
		   and dm_tp_amb = 1;
	    exception when others then
		  null;
	  end;
	  --  
	  commit;
	  --
	end if;
--
	begin
		--
		update csf_own.cidade_nfse set dm_padrao    = (select distinct vl from csf_own.dominio where upper(dominio) = upper('cidade_nfse.dm_padrao') and upper(descr) = upper(vv_padrao))
								       , dm_habil   = (select distinct vl from csf_own.dominio where upper(dominio) = upper('cidade_nfse.dm_habil') and upper(descr) = upper(vv_habil))
								       , dm_ws_canc = (select distinct vl from csf_own.dominio where upper(dominio) = upper('cidade_nfse.dm_ws_canc') and upper(descr) = upper(vv_ws_canc))
         where cidade_id = (select distinct id from csf_own.cidade where ibge_cidade in (vv_ibge_cidade));
		exception when others then
			raise_application_error(-20103, 'Erro no script Redmine #75094 Atualização do Padrão São Sebastião do Passé - BA' || sqlerrm);
    end;
	--
	commit;
	--
--
end;
--
/  
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #75094 Atualização URL ambiente de homologação e Produção - São Sebastião do Passé - BA
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #75122 - Revisão de códigos de ajuste da Dief PA
-------------------------------------------------------------------------------------------------------------------------------

set feedback off
set define off
--
begin
	DELETE FROM CSF_OWN.AJ_OBRIG_REC_ESTADO WHERE CD = '1131' AND TIPOIMP_ID = (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS') AND ESTADO_ID = (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA');
exception
   when others then
      null;
end;
/
commit;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '901', 'OP. INTERESTADUAL/ALGODÃO', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '913', 'OP. INTERESTADUAL/CAFÉ IN NATURA', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '916', 'OP. INTERESTADUAL/CAMARÃO', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '919', 'OP. INTERESTADUAL/CANA-DE-AÇUCAR', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '925', 'OP. INTERESTADUAL/CASTANHA-DO-PARÁ', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '928', 'OP. INTERESTADUAL/CARNE BOVINA', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '934', 'OP. INTERESTADUAL/CRUSTÁCEOS', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '937', 'OP. INTERESTADUAL/DENDÊ', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '949', 'OP. INTERESTADUAL/GADO BUBALINO', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '952', 'OP. INTERESTADUAL/GADO SUINO', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '955', 'OP. INTERESTADUAL/GADO EQUINO', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '958', 'OP. INTERESTADUAL/GADO MUAR', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '961', 'OP. INTERESTADUAL/JUTA/MALVA', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '973', 'OP. INTERESTADUAL/PALMITO IN NATURA', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '982', 'OP. INTERESTADUAL/URUCUM', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '985', 'OP. INTERESTADUAL/MANGANES', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '988', 'OP. INTERESTADUAL/PEDRA PRECIOSA', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '991', 'OP. INTERESTADUAL/OURO', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '994', 'OP. INTERESTADUAL/ALUMINIO', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '997', 'OP. INTERESTADUAL/ESTANHO', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '1000', 'OP. INTERESTADUAL/CALCARIO', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '1003', 'OP. INTERESTADUAL/CAULIM', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '1006', 'OP. INTERESTADUAL/GIPSITA', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '1009', 'OP. INTERESTADUAL/MARMORE', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '1012', 'OP. INTERESTADUAL/BRITA', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '1015', 'OP. INTERESTADUAL/CASSITERITA', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '1018', 'OP. INTERESTADUAL/FERRO', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '1024', 'OP. INTERESTADUAL/QUARTZO', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '1030', 'OP. INTERESTADUAL /AVES VIVAS', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '1033', 'OP. INTERESTADUAL /OVOS', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '1039', 'OP. INTERESTADUAL/CAPRINO', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '1042', 'OP. INTERESTADUAL/HORTIFRUTI', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/
begin
	INSERT INTO CSF_OWN.AJ_OBRIG_REC_ESTADO (ID, CD, DESCR, TIPOIMP_ID, ESTADO_ID) VALUES (CSF_OWN.AJOBRIGRECESTADO_SEQ.NEXTVAL, '1045', 'OP. INTERESTADUAL/OVINO', (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS'), (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA'));
exception
   when others then
      null;
end;
/

commit
/

-------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #75122 - Revisão de códigos de ajuste da Dief PA
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #75088 Criação de parâmetro SOMA_22_EM_31
-------------------------------------------------------------------------------------------------------------------------------------------

DECLARE

 V_PARAM            CSF_OWN.PARAM_GERAL_SISTEMA.ID%TYPE;
 VN_MODULOSISTEMA   CSF_OWN.MODULO_SISTEMA.ID%TYPE;
 VN_GRUPOSISTEMA    CSF_OWN.GRUPO_SISTEMA.ID%TYPE;
 VN_USUARIO         CSF_OWN.NEO_USUARIO.ID%TYPE;
 VC_VL_BC_ICMS1     VARCHAR2(50);
 VC_VL_BC_ICMS2     VARCHAR2(50);
 V_COUNT            NUMBER ;
  --
BEGIN 
  -- VERIFICA SE EXISTE MODULO SISTEMA, SENAO CRIA 
  BEGIN
    SELECT MS.ID
      INTO VN_MODULOSISTEMA
      FROM CSF_OWN.MODULO_SISTEMA MS
     WHERE UPPER(MS.COD_MODULO) = UPPER('OBRIG_ESTADUAL');          
  EXCEPTION
     WHEN NO_DATA_FOUND THEN  
         INSERT INTO CSF_OWN.MODULO_SISTEMA (ID, COD_MODULO, DSC_MODULO, OBSERVACAO)
          VALUES (CSF_OWN.MODULOSISTEMA_SEQ.NEXTVAL, 'OBRIG_ESTADUAL', 'Demais Obrigações Estaduais', 'Demais obrigaçães estaduais que não sejam Sped Fiscal');
          COMMIT;   
     WHEN OTHERS THEN  
           RAISE_APPLICATION_ERROR ( -20101, 'Erro ao localizar modulo sistema OBRIG_ESTADUAL - '||SQLERRM );
  END;    
  -- VERIFICA SE MODELO EXISTE GRUPO SISTEMA, SENAO CRIA 
  BEGIN      
    SELECT GS.ID
      INTO VN_GRUPOSISTEMA
      FROM CSF_OWN.GRUPO_SISTEMA GS
     WHERE GS.MODULO_ID = VN_MODULOSISTEMA
       AND UPPER(GS.COD_GRUPO) =  UPPER('DIPAM');
  EXCEPTION
     WHEN NO_DATA_FOUND THEN  
        INSERT INTO CSF_OWN.GRUPO_SISTEMA (ID, MODULO_ID, COD_GRUPO, DSC_GRUPO, OBSERVACAO)
             VALUES (CSF_OWN.GRUPOSISTEMA_SEQ.NEXTVAL, VN_MODULOSISTEMA, 'DIPAM', 'Grupo de parametros relacionados a obrigação DIPAM - Declarac?o do Indice de Participação dos Municipios que esta contida como registro na GIA', 'Grupo de parametros relacionados a obrigação DIPAM - Declarac?o do Indice de Participação dos Municipios que esta contida como registro na GIA');
        COMMIT;
     WHEN OTHERS THEN       
       RAISE_APPLICATION_ERROR ( -20101, 'Erro ao localizar grupo sistema DIPAM - '||SQLERRM );
  END;  
  -- RECUPERA USUARIO ADMIN 
  BEGIN   
    SELECT NU.ID
      INTO VN_USUARIO
      FROM CSF_OWN.NEO_USUARIO NU
     WHERE UPPER(LOGIN) = UPPER('admin'); --USUÁRIO ADMINISTRADOR DO SISTEMA
  EXCEPTION
     WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR ( -20101, 'Erro ao localizar usuario Admin - '||SQLERRM );   
  END;
  --    
  IF VN_USUARIO IS NOT NULL  
     AND VN_MODULOSISTEMA IS NOT NULL 
     AND VN_GRUPOSISTEMA IS NOT NULL  THEN
    --
    -- VERIFICA SE MODELO PARAMETRO SISTEMA, SENAO CRIA 
    FOR X IN (SELECT E.ID EMPRESA_ID,
                     E.multorg_id
                FROM CSF_OWN.PESSOA P,
                     CSF_OWN.EMPRESA E
               WHERE P.ID = E.PESSOA_ID 
                 AND E.DM_SITUACAO = 1) --EMPRESAS ATIVAS
    loop
        BEGIN
          SELECT pGS.Vlr_Param
            INTO V_PARAM
            FROM CSF_OWN.PARAM_GERAL_SISTEMA PGS
           WHERE 1=1
             AND PGS.GRUPO_ID  = VN_GRUPOSISTEMA
             AND PGS.MODULO_ID = VN_MODULOSISTEMA
             AND UPPER(PGS.PARAM_NAME) = UPPER('SOMA_22_EM_31')
             AND PGS.EMPRESA_ID = X.EMPRESA_ID
			 AND PGS.MULTORG_ID = X.MULTORG_ID;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN  
             INSERT INTO CSF_OWN.PARAM_GERAL_SISTEMA (ID, MULTORG_ID, EMPRESA_ID, MODULO_ID, GRUPO_ID, PARAM_NAME, DSC_PARAM, VLR_PARAM, USUARIO_ID_ALT, DT_ALTERACAO)
                  VALUES (CSF_OWN.PARAMGERALSISTEMA_SEQ.NEXTVAL, x.multorg_id, x.empresa_id, VN_MODULOSISTEMA, VN_GRUPOSISTEMA , 'SOMA_22_EM_31', 'Indica se ao gerar o registro da DIPAM na Gia/SP haver[a demonstração da soma dos registros 2.2 dentro do 3.1. Estando ativo será feita a soma de todos os registros 2.2 e será gerada uma linha do 3.1 com o valor total, caso inativo, o registro 3.1 não será montado. Valores válidos: S= Sim, soma os valores 2.2 em 3.1 / N= Não soma.', 'N', VN_USUARIO, SYSDATE);
             COMMIT;
           WHEN OTHERS THEN
              NULL;
        END;  
        --
        IF V_PARAM IS NOT NULL THEN
          NULL;
        END IF;
    END LOOP;
    COMMIT;
  END IF;
END;
/

-------------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #75088 Criação de parâmetro SOMA_22_EM_31
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #73685 - Alteração do campo param_geral_sistema - vlr_param de 50 para 1000
-------------------------------------------------------------------------------------------------------------------------------------------

DECLARE
vn_count INTEGER;
BEGIN
  ---
  vn_count:=0;
  ---
  BEGIN
    SELECT count(1) 
      INTO vn_count
      FROM USER_TAB_COLS 
     WHERE TABLE_NAME = 'PARAM_GERAL_SISTEMA'
       AND COLUMN_NAME = 'VLR_PARAM'
       AND DATA_TYPE = 'VARCHAR2'
       AND DATA_LENGTH = '50';
  EXCEPTION
    WHEN OTHERS THEN
      vn_count := 0;
  END;
  ---
  IF vn_count <> 0 THEN 
     EXECUTE IMMEDIATE 'ALTER TABLE PARAM_GERAL_SISTEMA MODIFY (VLR_PARAM VARCHAR2(1000))';
  END IF;
  ---
END;
/  
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #73685 - Alteração do campo param_geral_sistema - vlr_param de 50 para 1000
-------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
Prompt FIM Patch 2.9.6.1 - Alteracoes no CSF_OWN
------------------------------------------------------------------------------------------
