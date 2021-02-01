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
Prompt INI - Redmine #73869 Criação de parâmetro CONTROLA_NRO_RPS - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
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
		BEGIN
         INSERT INTO CSF_OWN.MODULO_SISTEMA (ID, COD_MODULO, DSC_MODULO, OBSERVACAO)
          VALUES (CSF_OWN.MODULOSISTEMA_SEQ.NEXTVAL, 'EMISSAO_DOC', 'Modulo de emissão de documentos fiscais', 'Modulo de emissão de documentos fiscal (NF-e, NFS-e, CT-e, NFC-e)');
          COMMIT;   
		EXCEPTION 
		 WHEN OTHERS THEN
		  NULL;
		END;
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
	    BEGIN
         INSERT INTO CSF_OWN.GRUPO_SISTEMA (ID, MODULO_ID, COD_GRUPO, DSC_GRUPO, OBSERVACAO)
              VALUES (CSF_OWN.GRUPOSISTEMA_SEQ.NEXTVAL, VN_MODULOSISTEMA, 'NFSE', 'Grupo de parametros relacionados a Emissão de NFS-E', 'Grupo de parametros relacionados a Emissão de NFS-E');
         COMMIT;
	    EXCEPTION 
		 WHEN OTHERS THEN
		  NULL;
		END;
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
			BEGIN
             INSERT INTO CSF_OWN.PARAM_GERAL_SISTEMA (ID, MULTORG_ID, EMPRESA_ID, MODULO_ID, GRUPO_ID, PARAM_NAME, DSC_PARAM, VLR_PARAM, USUARIO_ID_ALT, DT_ALTERACAO)
                  VALUES (CSF_OWN.PARAMGERALSISTEMA_SEQ.NEXTVAL, x.multorg_id, x.empresa_id, VN_MODULOSISTEMA, VN_GRUPOSISTEMA , 'CONTROLA_NRO_RPS', 'Indica se irá haver controle de numeração do RPS feito através pelo Compliance, a troca ocorre no momento da validação do documento. Antes de ativar o parametro, verifique se as Séries que precisarão de controle numérico estão parametrizadas para modelo de documento 99. Esse parametro não funciona para integração open interface. Valores possiveis: 0=Não / 1=Sim.', '0', VN_USUARIO, SYSDATE);
             COMMIT;
			EXCEPTION 
		      WHEN OTHERS THEN
		        NULL;
		    END;
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
Prompt FIM - Redmine #73869 Criação de parâmetro CONTROLA_NRO_RPS - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
-------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - #74696 - CRIAÇÃO DE DOMINIO E CAMPO PARA IDENTIFICAÇÃO DO TIPO DE ARQUIVO A SER REGISTRADO NO COMPLIANCE - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
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
	  BEGIN
		EXECUTE IMMEDIATE 'ALTER TABLE CSF_OWN.NOTA_FISCAL_PDF ADD DM_TIPO_ARQ NUMBER DEFAULT 0';
		EXECUTE IMMEDIATE 'comment on column CSF_OWN.NOTA_FISCAL_PDF.DM_TIPO_ARQ is ''Defini o tipo de arquivo 0-PDF, 1-TIF''';
	  EXCEPTION 
		 WHEN OTHERS THEN
		  NULL;
		END;
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
		BEGIN
			INSERT INTO CSF_OWN.DOMINIO (DOMINIO, VL, DESCR, ID)
				 VALUES ('NOTA_FISCAL_PDF.DM_TIPO_ARQ', 0, ' Arquivo do tipo PDF ', DOMINIO_SEQ.NEXTVAL);
			COMMIT;
		EXCEPTION 
		 WHEN OTHERS THEN
		  NULL;
		END;
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
		BEGIN
          INSERT INTO CSF_OWN.DOMINIO (DOMINIO, VL, DESCR, ID)
             VALUES ('NOTA_FISCAL_PDF.DM_TIPO_ARQ', 1, ' Arquivo do tipo TIF ',DOMINIO_SEQ.NEXTVAL);
          COMMIT;
		EXCEPTION 
		 WHEN OTHERS THEN
		  NULL;
		END;
     WHEN OTHERS THEN       
       RAISE_APPLICATION_ERROR ( -20101, 'Erro ao localizar DOMINIO NOTA_FISCAL_PDF.DM_TIPO_ARQ - '||SQLERRM );
  END;  
/  
--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - #74696 - CRIAÇÃO DE DOMINIO E CAMPO PARA IDENTIFICAÇÃO DO TIPO DE ARQUIVO A SER REGISTRADO NO COMPLIANCE - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
Prompt Inicio - Redmine #74820 - Parametro geral do sistema TIPO_CRED_GRUPO_CST_60 - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
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
         null;
         goto SAIR_SCRIPT;   
   end;
   --
   if vn_modulo_id = 0 then
      --
      begin	  
         insert into CSF_OWN.MODULO_SISTEMA
         values(CSF_OWN.MODULOSISTEMA_SEQ.NEXTVAL, 'OBRIG_FEDERAL', 'Obrigações Federais', 'Modulo que agrupa todas as obrigações federais exceto as contabeis ECD e ECF')
         returning id into vn_modulo_id;
      exception
         when others then
            null;
      end;			
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
         null;
         goto SAIR_SCRIPT;   
   end;
   --
   if vn_grupo_id = 0 then
      --
      begin	  
         insert into CSF_OWN.GRUPO_SISTEMA
         values(CSF_OWN.GRUPOSISTEMA_SEQ.NextVal, vn_modulo_id, 'EFD_CONTRIB', 'Parâmetro relacionados ao EFD Contribuições','Parâmetro relacionados ao EFD Contribuições')
         returning id into vn_grupo_id;
      exception
         when others then
            null;
      end;			
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
            null;
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
                     null;
                     goto SAIR_SCRIPT;
               end;
         end;
         --
         begin		 
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
         exception
            when others then
               null;
         end; 			
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
Prompt Fim - Redmine #74820 - Parametro geral do sistema TIPO_CRED_GRUPO_CST_60 - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
Prompt Inicio - Redmine #74671  - Inclusão do Flexfield UNID_ORG - VW_CSF_CONHEC_TRANSP_EFD_FF - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
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
Prompt Fim - Redmine #74671  - Inclusão do Flexfield UNID_ORG - VW_CSF_CONHEC_TRANSP_EFD_FF - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Inicio - Redmine #74979  - Correção sobre Flexfield - Notas fiscais de servicos - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
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
Prompt Fim - Redmine #74979  - Correção sobre Flexfield - Notas fiscais de servicos - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
--------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #75024 Atualização URL ambiente de homologação e Produção - Pouso Alegre - MG - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
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
     begin  
		execute immediate 'alter table CSF_OWN.CIDADE_NFSE drop constraint CIDADENFSE_DMPADRAO_CK';
		execute immediate 'alter table CSF_OWN.CIDADE_NFSE add constraint CIDADENFSE_DMPADRAO_CK check (dm_padrao in (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44))';
	 exception 
		when others then
			null;
	 end;
  elsif  vn_count = 0 then    
     begin
		execute immediate 'alter table CSF_OWN.CIDADE_NFSE add constraint CIDADENFSE_DMPADRAO_CK check (dm_padrao in (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44))';
	 exception 
		when others then
			null;
	 end;
  end if;
  --
  commit;  
  --
  begin
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
end;			
/
 
declare
--
vn_dm_tp_amb1  number  := 0;
vn_dm_tp_amb2  number  := 0;
vv_ibge_cidade csf_own.cidade.ibge_cidade%type;
vv_padrao      csf_own.dominio.descr%type;    
vv_habil       csf_own.dominio.descr%type;
vv_ws_canc     csf_own.dominio.descr%type;

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
	  exception 
		 when others then
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
Prompt FIM - Redmine #75024 Atualização URL ambiente de homologação e Produção - Pouso Alegre - MG - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
-------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - #75020 - Tirar obrigatoriedade de campo IMP_ITEMCF.CODST_ID - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
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
		   AND UPPER(COLUMN_NAME) = UPPER('CODST_ID');
	  EXCEPTION
		WHEN OTHERS THEN
		  V_COUNT := 0;
	  END;
	  
	  IF V_COUNT = 0 THEN
	  --
	    BEGIN
			EXECUTE IMMEDIATE 'ALTER TABLE CSF_OWN.IMP_ITEMCF ADD CODST_ID NUMBER NULL';
			EXECUTE IMMEDIATE 'comment on column CSF_OWN.IMP_ITEMCF.CODST_ID is ''Identificador do CST - Código da Situação Tributária''';
		EXCEPTION
		  WHEN OTHERS THEN
		    NULL;
		END;
	  --
	  END IF;
	  --
	  V_COUNT := 0;
	  --
	  BEGIN
		SELECT COUNT(COLUMN_NAME)
		  INTO V_COUNT
		  FROM ALL_TAB_COLUMNS
		 WHERE UPPER(OWNER)       = UPPER('CSF_OWN')
		   AND UPPER(TABLE_NAME)  = UPPER('IMP_ITEMCF')
		   AND UPPER(COLUMN_NAME) = UPPER('CODST_ID')
		   AND UPPER(NULLABLE)     = UPPER('N');
	  EXCEPTION
		WHEN OTHERS THEN
		  V_COUNT := 0;
	  END;
	  
	  IF V_COUNT <> 0 THEN
	  --
		BEGIN
			EXECUTE IMMEDIATE 'ALTER TABLE CSF_OWN.IMP_ITEMCF MODIFY CODST_ID NUMBER NULL';
		EXCEPTION
		  WHEN OTHERS THEN
		    NULL;
		END;
	  --
	  END IF;
END;
/
----------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #75020 Tirar obrigatoriedade de campo IMP_ITEMCF.CODST_ID - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
----------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine Redmine #73698  - Inclusão de dominio no banco e ajuste em check - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
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
	BEGIN
		EXECUTE IMMEDIATE 'alter table CSF_OWN.EVENTO_CTE drop constraint EVENTOCTE_STINTEGRA_CK';
		EXECUTE IMMEDIATE 'alter table CSF_OWN.EVENTO_CTE add constraint EVENTOCTE_STINTEGRA_CK check (DM_ST_INTEGRA in (0, 5, 7, 8, 9))';
	EXCEPTION
		WHEN OTHERS THEN
		   NULL;
    END;
  ELSIF  vn_count = 0 THEN    
	BEGIN
		EXECUTE IMMEDIATE 'alter table CSF_OWN.EVENTO_CTE add constraint EVENTOCTE_STINTEGRA_CK check (DM_ST_INTEGRA in (0, 5, 7, 8, 9))';
	EXCEPTION
		WHEN OTHERS THEN
		  NULL;
    END;
  END IF;  
--
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
  IF vn_count = 0 THEN 
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
  ELSIF vn_count <> 0 THEN
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
Prompt Fim - Redmine #73698  - Inclusão de dominio no banco e ajuste em check - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - #75086 - Tirar obrigatoriedade de campo nota_fiscal_mde.notafiscal_id - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
--------------------------------------------------------------------------------------------------------------------------------------
DECLARE
 V_COUNT            NUMBER;
 
 BEGIN
	  -- valida se ja existe a coluna NOTAFISCAL_ID na tabela NOTA_FISCAL_MDE, se existir altera para null.
	  BEGIN
		SELECT COUNT(COLUMN_NAME)
		  INTO V_COUNT
		  FROM ALL_TAB_COLUMNS
		 WHERE UPPER(OWNER)       = UPPER('CSF_OWN')
		   AND UPPER(TABLE_NAME)  = UPPER('NOTA_FISCAL_MDE')
		   AND UPPER(COLUMN_NAME) = UPPER('NOTAFISCAL_ID');
	  EXCEPTION
		WHEN OTHERS THEN
		  V_COUNT := 0;
	  END;
	  
	  IF V_COUNT = 0 THEN
	  --
		BEGIN
			EXECUTE IMMEDIATE 'ALTER TABLE CSF_OWN.NOTA_FISCAL_MDE ADD NOTAFISCAL_ID NUMBER NULL';
			EXECUTE IMMEDIATE 'comment on column CSF_OWN.NOTA_FISCAL_MDE.NOTAFISCAL_ID is ''Indentificador que relaciona com a tabela NOTA_FISCAL''';
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
	  --
	  END IF;
	  --
	  V_COUNT := 0;
	  --
	  BEGIN
		SELECT COUNT(COLUMN_NAME)
		  INTO V_COUNT
		  FROM ALL_TAB_COLUMNS
		 WHERE UPPER(OWNER)       = UPPER('CSF_OWN')
		   AND UPPER(TABLE_NAME)  = UPPER('NOTA_FISCAL_MDE')
		   AND UPPER(COLUMN_NAME) = UPPER('NOTAFISCAL_ID')
		   AND UPPER(NULLABLE)     = UPPER('N');
	  EXCEPTION
		WHEN OTHERS THEN
		  V_COUNT := 0;
	  END;
	  
	  IF V_COUNT <> 0 THEN
	  --
		BEGIN
			EXECUTE IMMEDIATE 'ALTER TABLE CSF_OWN.NOTA_FISCAL_MDE MODIFY NOTAFISCAL_ID NUMBER NULL';
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
	  --
	  END IF;
END;
/
----------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #75086 Tirar obrigatoriedade de campo nota_fiscal_mde.notafiscal_id - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
----------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #75105 Criar tabela HIST_ST_CONHEC_TRANSP - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
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
      execute immediate 'alter table CSF_OWN.HIST_ST_CONHEC_TRANSP add constraint HISTSTCONHECTRANSP_FK foreign key (CONHECTRANSP_ID) references CSF_OWN.CONHEC_TRANSP (ID)';
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
   BEGIN
		SELECT COUNT(1)
	      INTO vn_existe
		  FROM CSF_OWN.SEQ_TAB
		 WHERE UPPER(SEQUENCE_NAME) = UPPER('HISTSTCONHECTRANSP_SEQ');
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			vn_existe := 0;
		WHEN OTHERS THEN
			vn_existe := -1;
	END;
	--
	IF NVL(vn_existe, 0) = 0 THEN
		BEGIN
         INSERT INTO CSF_OWN.SEQ_TAB (ID, SEQUENCE_NAME, TABLE_NAME)
          VALUES (CSF_OWN.SEQTAB_SEQ.NEXTVAL, 'HISTSTCONHECTRANSP_SEQ', 'HIST_ST_CONHEC_TRANSP');
          COMMIT;   
		EXCEPTION 
		 WHEN OTHERS THEN
		  NULL;
		END;
	END IF;
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
Prompt FIM Redmine #75105 Criar tabela HIST_ST_CONHEC_TRANSP - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
--------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #75094 Atualização URL ambiente de homologação e Produção - Pojuca - BA - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
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
vv_ibge_cidade csf_own.cidade.ibge_cidade%type;
vv_padrao      csf_own.dominio.descr%type;    
vv_habil       csf_own.dominio.descr%type;
vv_ws_canc     csf_own.dominio.descr%type;

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
	exception 
		when others then
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
Prompt FIM - Redmine #75094 Atualização URL ambiente de homologação e Produção - Pojuca - BA - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #75094 Atualização URL ambiente de homologação e Produção - São Francisco do Conde - BA - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
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
vv_ibge_cidade csf_own.cidade.ibge_cidade%type;
vv_padrao      csf_own.dominio.descr%type;    
vv_habil       csf_own.dominio.descr%type;
vv_ws_canc     csf_own.dominio.descr%type;

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
Prompt FIM - Redmine #75094 Atualização URL ambiente de homologação e Produção - São Francisco do Conde - BA - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #75094 Atualização URL ambiente de homologação e Produção - São Sebastião do Passé - BA - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
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
vv_ibge_cidade csf_own.cidade.ibge_cidade%type;
vv_padrao      csf_own.dominio.descr%type;    
vv_habil       csf_own.dominio.descr%type;
vv_ws_canc     csf_own.dominio.descr%type;

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
Prompt FIM - Redmine #75094 Atualização URL ambiente de homologação e Produção - São Sebastião do Passé - BA - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #75122 - Revisão de códigos de ajuste da Dief PA - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
-------------------------------------------------------------------------------------------------------------------------------
--
begin
	DELETE FROM CSF_OWN.AJ_OBRIG_REC_ESTADO WHERE CD = '1131' AND TIPOIMP_ID = (SELECT ID FROM CSF_OWN.TIPO_IMPOSTO WHERE SIGLA = 'ICMS') AND ESTADO_ID = (SELECT ID FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'PA');
exception
   when others then
      null;
end;
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
commit;
/
-------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #75122 - Revisão de códigos de ajuste da Dief PA - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #75088 Criação de parâmetro SOMA_22_EM_31 - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
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
		BEGIN
         INSERT INTO CSF_OWN.MODULO_SISTEMA (ID, COD_MODULO, DSC_MODULO, OBSERVACAO)
          VALUES (CSF_OWN.MODULOSISTEMA_SEQ.NEXTVAL, 'OBRIG_ESTADUAL', 'Demais Obrigações Estaduais', 'Demais obrigaçães estaduais que não sejam Sped Fiscal');
          COMMIT;   
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
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
		BEGIN
			INSERT INTO CSF_OWN.GRUPO_SISTEMA (ID, MODULO_ID, COD_GRUPO, DSC_GRUPO, OBSERVACAO)
				 VALUES (CSF_OWN.GRUPOSISTEMA_SEQ.NEXTVAL, VN_MODULOSISTEMA, 'DIPAM', 'Grupo de parametros relacionados a obrigação DIPAM - Declaração do Indice de Participação dos Municipios que esta contida como registro na GIA', 'Grupo de parametros relacionados a obrigação DIPAM - Declaração do Indice de Participação dos Municipios que esta contida como registro na GIA');
			COMMIT;
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
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
		    BEGIN
             INSERT INTO CSF_OWN.PARAM_GERAL_SISTEMA (ID, MULTORG_ID, EMPRESA_ID, MODULO_ID, GRUPO_ID, PARAM_NAME, DSC_PARAM, VLR_PARAM, USUARIO_ID_ALT, DT_ALTERACAO)
                  VALUES (CSF_OWN.PARAMGERALSISTEMA_SEQ.NEXTVAL, x.multorg_id, x.empresa_id, VN_MODULOSISTEMA, VN_GRUPOSISTEMA , 'SOMA_22_EM_31', 'Indica se ao gerar o registro da DIPAM na Gia/SP haver[a demonstração da soma dos registros 2.2 dentro do 3.1. Estando ativo será feita a soma de todos os registros 2.2 e será gerada uma linha do 3.1 com o valor total, caso inativo, o registro 3.1 não será montado. Valores válidos: S= Sim, soma os valores 2.2 em 3.1 / N= Não soma.', 'N', VN_USUARIO, SYSDATE);
             COMMIT;
			EXCEPTION
			  WHEN OTHERS THEN
				NULL;
			END;
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
Prompt FIM - Redmine #75088 Criação de parâmetro SOMA_22_EM_31 - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #73685 - Alteração do campo param_geral_sistema - vlr_param de 50 para 1000 - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
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
	BEGIN
		EXECUTE IMMEDIATE 'ALTER TABLE CSF_OWN.PARAM_GERAL_SISTEMA MODIFY (VLR_PARAM VARCHAR2(1000))';
	EXCEPTION
		WHEN OTHERS THEN
		   NULL;
	END;
  END IF;
  ---
END;
/  
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #73685 - Alteração do campo param_geral_sistema - vlr_param de 50 para 1000 - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #75441 Atualização de Check Constrain MSGWEBSERVNFSE_PADRAO_CK - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
-------------------------------------------------------------------------------------------------------------------------------------------

declare
vn_count integer;
--
begin
  --
  vn_count:=0;
  --
  begin
    select count(1) into vn_count
    from  all_constraints 
    where owner = 'CSF_OWN'
      and constraint_name = 'MSGWEBSERVNFSE_PADRAO_CK';
  exception
    when others then
      vn_count:=0;
  end;
  --
  if vn_count = 1 then 
	begin
     execute immediate 'alter table CSF_OWN.MSG_WEBSERV_NFSE drop constraint MSGWEBSERVNFSE_PADRAO_CK';
     execute immediate 'alter table CSF_OWN.MSG_WEBSERV_NFSE add constraint MSGWEBSERVNFSE_PADRAO_CK check (dm_padrao in (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44))';
	exception
		when others then
			null;
	end;
  elsif  vn_count = 0 then 
	begin
     execute immediate 'alter table CSF_OWN.MSG_WEBSERV_NFSE add constraint MSGWEBSERVNFSE_PADRAO_CK check (dm_padrao in (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44))';
	exception
		when others then
			null;
	end;
  end if;
  --
end;
/  
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #75441 Atualização de Check Constrain MSGWEBSERVNFSE_PADRAO_CK - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #73025 - Incluir parâmetro para valor de COFINS Majorado - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
-------------------------------------------------------------------------------------------------------------------------------
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
		BEGIN
         INSERT INTO CSF_OWN.MODULO_SISTEMA (ID, COD_MODULO, DSC_MODULO, OBSERVACAO)
          VALUES (CSF_OWN.MODULOSISTEMA_SEQ.NEXTVAL, 'EMISSAO_DOC', 'Modulo de emissão de documentos fiscais', 'Modulo de emissão de documentos fiscal (NF-e, NFS-e, CT-e, NFC-e)');
          COMMIT;   
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
     WHEN OTHERS THEN  
           RAISE_APPLICATION_ERROR ( -20101, 'Erro ao localizar modulo sistema EMISSAO_DOC - '||SQLERRM );
  END;    
  -- VERIFICA SE MODELO EXISTE GRUPO SISTEMA, SENAO CRIA 
  BEGIN      
    SELECT GS.ID
      INTO VN_GRUPOSISTEMA
      FROM CSF_OWN.GRUPO_SISTEMA GS
     WHERE GS.MODULO_ID = VN_MODULOSISTEMA
       AND UPPER(GS.COD_GRUPO) =  UPPER('NF_IMPORTACAO');
  EXCEPTION
     WHEN NO_DATA_FOUND THEN  
		BEGIN
			INSERT INTO CSF_OWN.GRUPO_SISTEMA (ID, MODULO_ID, COD_GRUPO, DSC_GRUPO, OBSERVACAO)
				 VALUES (CSF_OWN.GRUPOSISTEMA_SEQ.NEXTVAL, VN_MODULOSISTEMA, 'NF_IMPORTACAO', 'Grupo de parametros relacionados à documento fiscal de importação', 'Grupo de parametros relacionados à documento fiscal de importação');
			COMMIT;
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
     WHEN OTHERS THEN       
       RAISE_APPLICATION_ERROR ( -20101, 'Erro ao localizar grupo sistema NF_IMPORTACAO - '||SQLERRM );
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
             AND UPPER(PGS.PARAM_NAME) = UPPER('GERA_COFINS_MAJORADO')
             AND PGS.EMPRESA_ID = X.EMPRESA_ID;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN  
			BEGIN
             INSERT INTO CSF_OWN.PARAM_GERAL_SISTEMA (ID, MULTORG_ID, EMPRESA_ID, MODULO_ID, GRUPO_ID, PARAM_NAME, DSC_PARAM, VLR_PARAM, USUARIO_ID_ALT, DT_ALTERACAO)
                  VALUES (CSF_OWN.PARAMGERALSISTEMA_SEQ.NEXTVAL, x.multorg_id, x.empresa_id, VN_MODULOSISTEMA, VN_GRUPOSISTEMA , 'GERA_COFINS_MAJORADO', 'Indica se irá gerar valor de Cofins Majorada em notas de importação a partir de valores de impostos na nota. Para chegar ao valor será feita subtração da soma da Cofins Importação pela soma da Cofins imposto e resultado gravado no campo VL_COFINS_MAJORADA da NOTA_FISCAL_TOTAL. Valores possíveis: 0=Não calcula Cofins Majorada / 1=Sim, calcula Cofins majorada.', '0', VN_USUARIO, SYSDATE);
             COMMIT;
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
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
-------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #73025 - Incluir parâmetro para valor de COFINS Majorado - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
-------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #73026 - Indica se o valor de Cofins Majorada em notas de importação deve ser somado ao total na nota - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
------------------------------------------------------------------------------------------------------------------------------------------------------------
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
		BEGIN
         INSERT INTO CSF_OWN.MODULO_SISTEMA (ID, COD_MODULO, DSC_MODULO, OBSERVACAO)
          VALUES (CSF_OWN.MODULOSISTEMA_SEQ.NEXTVAL, 'EMISSAO_DOC', 'Modulo de emissão de documentos fiscais', 'Modulo de emissão de documentos fiscal (NF-e, NFS-e, CT-e, NFC-e)');
          COMMIT;   
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
     WHEN OTHERS THEN  
           RAISE_APPLICATION_ERROR ( -20101, 'Erro ao localizar modulo sistema EMISSAO_DOC - '||SQLERRM );
  END;    
  -- VERIFICA SE MODELO EXISTE GRUPO SISTEMA, SENAO CRIA 
  BEGIN      
    SELECT GS.ID
      INTO VN_GRUPOSISTEMA
      FROM CSF_OWN.GRUPO_SISTEMA GS
     WHERE GS.MODULO_ID = VN_MODULOSISTEMA
       AND UPPER(GS.COD_GRUPO) =  UPPER('NF_IMPORTACAO');
  EXCEPTION
     WHEN NO_DATA_FOUND THEN  
		BEGIN
			INSERT INTO CSF_OWN.GRUPO_SISTEMA (ID, MODULO_ID, COD_GRUPO, DSC_GRUPO, OBSERVACAO)
				 VALUES (CSF_OWN.GRUPOSISTEMA_SEQ.NEXTVAL, VN_MODULOSISTEMA, 'NF_IMPORTACAO', 'Grupo de parametros relacionados à documento fiscal de importação', 'Grupo de parametros relacionados à documento fiscal de importação');
			COMMIT;
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
     WHEN OTHERS THEN       
       RAISE_APPLICATION_ERROR ( -20101, 'Erro ao localizar grupo sistema NF_IMPORTACAO - '||SQLERRM );
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
             AND UPPER(PGS.PARAM_NAME) = UPPER('SOMA_COFINS_MAJOR_TOT_NF')
             AND PGS.EMPRESA_ID = X.EMPRESA_ID;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN  
			BEGIN
             INSERT INTO CSF_OWN.PARAM_GERAL_SISTEMA (ID, MULTORG_ID, EMPRESA_ID, MODULO_ID, GRUPO_ID, PARAM_NAME, DSC_PARAM, VLR_PARAM, USUARIO_ID_ALT, DT_ALTERACAO)
                  VALUES (CSF_OWN.PARAMGERALSISTEMA_SEQ.NEXTVAL, x.multorg_id, x.empresa_id, VN_MODULOSISTEMA, VN_GRUPOSISTEMA , 'SOMA_COFINS_MAJOR_TOT_NF', 'Indica se o valor de Cofins Majorada em notas de importação deve ser somado ao total na nota (VL_COFINS_MAJORADA somado ao VL_TOTAL_NF, ambos na NOTA_FISCAL_TOTAL). Valores possíveis: 0=Não soma / 1=Sim, soma.', '0', VN_USUARIO, SYSDATE);
             COMMIT;
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
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
------------------------------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #73026 - Indica se o valor de Cofins Majorada em notas de importação deve ser somado ao total na nota - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #73024 - Criação de novos Campos para a Tabela NOTA_FISCAL_TOTAL - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
-------------------------------------------------------------------------------------------------------------------------------

DECLARE
  --
  VC_REL_NF_CONSOL   ALL_TAB_COLUMNS.COLUMN_NAME%TYPE;

BEGIN
-- valida se ja existe a coluna na tabela NOTA_FISCAL_TOTAL, senao existir, cria.
  BEGIN
    SELECT COLUMN_NAME
      INTO VC_REL_NF_CONSOL
      FROM ALL_TAB_COLUMNS
     WHERE UPPER(OWNER)       = UPPER('CSF_OWN')
       AND UPPER(TABLE_NAME)  = UPPER('NOTA_FISCAL_TOTAL')
       AND UPPER(COLUMN_NAME) = UPPER('VL_PIS_IMP');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
		BEGIN
		  EXECUTE IMMEDIATE 'ALTER TABLE CSF_OWN.NOTA_FISCAL_TOTAL ADD VL_PIS_IMP NUMBER(15, 2) ';
		  EXECUTE IMMEDIATE 'comment on column CSF_OWN.NOTA_FISCAL_TOTAL.VL_PIS_IMP  is ''Valor PIS Importação ''';
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
    WHEN OTHERS THEN
      NULL;
  END;
  --
  -- valida se ja existe a coluna na tabela NOTA_FISCAL_TOTAL, senao existir, cria.
  BEGIN
    SELECT COLUMN_NAME
      INTO VC_REL_NF_CONSOL
      FROM ALL_TAB_COLUMNS
     WHERE UPPER(OWNER)       = UPPER('CSF_OWN')
       AND UPPER(TABLE_NAME)  = UPPER('NOTA_FISCAL_TOTAL')
       AND UPPER(COLUMN_NAME) = UPPER('VL_COFINS_IMP');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
		BEGIN
		  EXECUTE IMMEDIATE 'ALTER TABLE CSF_OWN.NOTA_FISCAL_TOTAL ADD VL_COFINS_IMP  NUMBER(15, 2) ';
		  EXECUTE IMMEDIATE 'comment on column CSF_OWN.NOTA_FISCAL_TOTAL.VL_COFINS_IMP   is ''Valor COFINS Importação ''';
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
    WHEN OTHERS THEN
      NULL;
  END;
  --
  -- valida se ja existe a coluna na tabela NOTA_FISCAL_TOTAL, senao existir, cria.
  BEGIN
    SELECT COLUMN_NAME
      INTO VC_REL_NF_CONSOL
      FROM ALL_TAB_COLUMNS
     WHERE UPPER(OWNER)       = UPPER('CSF_OWN')
       AND UPPER(TABLE_NAME)  = UPPER('NOTA_FISCAL_TOTAL')
       AND UPPER(COLUMN_NAME) = UPPER('VL_COFINS_MAJORADA');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
		BEGIN
		  EXECUTE IMMEDIATE 'ALTER TABLE CSF_OWN.NOTA_FISCAL_TOTAL ADD VL_COFINS_MAJORADA  NUMBER(15, 2) ';
		  EXECUTE IMMEDIATE 'comment on column CSF_OWN.NOTA_FISCAL_TOTAL.VL_COFINS_MAJORADA is ''Valor total da majoração da COFINS de importação ''';
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
    WHEN OTHERS THEN
      NULL;
  END;
END;
/
-------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #73024 - Criação de novos Campos para a Tabela NOTA_FISCAL_TOTAL - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #73024 - Criação de novos Campos para a Tabela TMP_NOTA_FISCAL_TOTAL - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
-------------------------------------------------------------------------------------------------------------------------------

DECLARE
  --
  VC_REL_NF_CONSOL   ALL_TAB_COLUMNS.COLUMN_NAME%TYPE;

BEGIN
-- valida se ja existe a coluna na tabela TMP_NOTA_FISCAL_TOTAL, senao existir, cria.
  BEGIN
    SELECT COLUMN_NAME
      INTO VC_REL_NF_CONSOL
      FROM ALL_TAB_COLUMNS
     WHERE UPPER(OWNER)       = UPPER('CSF_OWN')
       AND UPPER(TABLE_NAME)  = UPPER('TMP_NOTA_FISCAL_TOTAL')
       AND UPPER(COLUMN_NAME) = UPPER('VL_PIS_IMP');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
		BEGIN
		  EXECUTE IMMEDIATE 'ALTER TABLE CSF_OWN.TMP_NOTA_FISCAL_TOTAL ADD VL_PIS_IMP NUMBER(15, 2) ';
		  EXECUTE IMMEDIATE 'comment on column CSF_OWN.TMP_NOTA_FISCAL_TOTAL.VL_PIS_IMP  is ''Valor PIS Importação ''';
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
    WHEN OTHERS THEN
      NULL;
  END;
  --
  -- valida se ja existe a coluna na tabela TMP_NOTA_FISCAL_TOTAL, senao existir, cria.
  BEGIN
    SELECT COLUMN_NAME
      INTO VC_REL_NF_CONSOL
      FROM ALL_TAB_COLUMNS
     WHERE UPPER(OWNER)       = UPPER('CSF_OWN')
       AND UPPER(TABLE_NAME)  = UPPER('TMP_NOTA_FISCAL_TOTAL')
       AND UPPER(COLUMN_NAME) = UPPER('VL_COFINS_IMP');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
		BEGIN
		  EXECUTE IMMEDIATE 'ALTER TABLE CSF_OWN.TMP_NOTA_FISCAL_TOTAL ADD VL_COFINS_IMP  NUMBER(15, 2) ';
		  EXECUTE IMMEDIATE 'comment on column CSF_OWN.TMP_NOTA_FISCAL_TOTAL.VL_COFINS_IMP   is ''Valor COFINS Importação ''';
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
    WHEN OTHERS THEN
      NULL;
  END;
  --
  -- valida se ja existe a coluna na tabela TMP_NOTA_FISCAL_TOTAL, senao existir, cria.
  BEGIN
    SELECT COLUMN_NAME
      INTO VC_REL_NF_CONSOL
      FROM ALL_TAB_COLUMNS
     WHERE UPPER(OWNER)       = UPPER('CSF_OWN')
       AND UPPER(TABLE_NAME)  = UPPER('TMP_NOTA_FISCAL_TOTAL')
       AND UPPER(COLUMN_NAME) = UPPER('VL_COFINS_MAJORADA');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
		BEGIN
		  EXECUTE IMMEDIATE 'ALTER TABLE CSF_OWN.TMP_NOTA_FISCAL_TOTAL ADD VL_COFINS_MAJORADA  NUMBER(15, 2) ';
		  EXECUTE IMMEDIATE 'comment on column CSF_OWN.TMP_NOTA_FISCAL_TOTAL.VL_COFINS_MAJORADA is ''Valor total da majoração da COFINS de importação ''';
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
    WHEN OTHERS THEN
      NULL;
  END;
END;
/
-------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #73024 - Criação de novos Campos para a Tabela TMP_NOTA_FISCAL_TOTAL - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #75312 - Atualização tabela param_ipm - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
-------------------------------------------------------------------------------------------------------------------------------

@@75312_01_ipm_RS.sql
/

@@75312_02_ipm_MA.sql
/

@@75312_03_ipm_MG.sql
/

@@75312_04_ipm_PE.sql
/

@@75312_05_ipm_RN.sql
/

@@75312_06_ipm_SP.sql
/

@@75312_07_ipm_SC.sql
/

@@75312_08_ipm_AC.sql
/

@@75312_09_ipm_ES.sql
/

@@75312_10_ipm_TO.sql
/

@@75312_11_ipm_BA.sql
/

@@75312_12_ipm_RJ.sql
/
 
--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #75312 - Atualização tabela param_ipm - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
--------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
Prompt Inicio Redmine #75390 Não está montando 0200 para o item usado no 1400 - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
---------------------------------------------------------------------------------------------------------
 begin
     
  begin
    insert into csf_own.dominio
      (dominio,
       vl,
       descr,
       id)
    values
      ('PARAM_EFD_ICMS_IPI.DM_COD_ITEM_IPM_UF',
       'AL',
       'UF que tem código IPM',
       csf_own.dominio_seq.nextval);
  exception
    when others then
      null;
  end;
  --
  
 
  begin
    insert into csf_own.dominio
      (dominio,
       vl,
       descr,
       id)
    values
      ('PARAM_EFD_ICMS_IPI.DM_COD_ITEM_IPM_UF',
       'BA',
       'UF que tem código IPM',
       csf_own.dominio_seq.nextval);
  exception
    when others then
      null;
  end;
  --

 
  begin
    insert into csf_own.dominio
      (dominio,
       vl,
       descr,
       id)
    values
      ('PARAM_EFD_ICMS_IPI.DM_COD_ITEM_IPM_UF',
       'ES',
       'UF que tem código IPM',
       csf_own.dominio_seq.nextval);
  exception
    when others then
      null;
  end;
  --

 
  begin
    insert into csf_own.dominio
      (dominio,
       vl,
       descr,
       id)
    values
      ('PARAM_EFD_ICMS_IPI.DM_COD_ITEM_IPM_UF',
       'MA',
       'UF que tem código IPM',
       csf_own.dominio_seq.nextval);
  exception
    when others then
      null;
  end;
  --

 
  begin
    insert into csf_own.dominio
      (dominio,
       vl,
       descr,
       id)
    values
      ('PARAM_EFD_ICMS_IPI.DM_COD_ITEM_IPM_UF',
       'MG',
       'UF que tem código IPM',
       csf_own.dominio_seq.nextval);
  exception
    when others then
      null;
  end;
  --

 
  begin
    insert into csf_own.dominio
      (dominio,
       vl,
       descr,
       id)
    values
      ('PARAM_EFD_ICMS_IPI.DM_COD_ITEM_IPM_UF',
       'PE',
       'UF que tem código IPM',
       csf_own.dominio_seq.nextval);
  exception
    when others then
      null;
  end;
  --

 
  begin
    insert into csf_own.dominio
      (dominio,
       vl,
       descr,
       id)
    values
      ('PARAM_EFD_ICMS_IPI.DM_COD_ITEM_IPM_UF',
       'RJ',
       'UF que tem código IPM',
       csf_own.dominio_seq.nextval);
  exception
    when others then
      null;
  end;
  --

 
  begin
    insert into csf_own.dominio
      (dominio,
       vl,
       descr,
       id)
    values
      ('PARAM_EFD_ICMS_IPI.DM_COD_ITEM_IPM_UF',
       'RN',
       'UF que tem código IPM',
       csf_own.dominio_seq.nextval);
  exception
    when others then
      null;
  end;
  --

 
  begin
    insert into csf_own.dominio
      (dominio,
       vl,
       descr,
       id)
    values
      ('PARAM_EFD_ICMS_IPI.DM_COD_ITEM_IPM_UF',
       'RS',
       'UF que tem código IPM',
       csf_own.dominio_seq.nextval);
  exception
    when others then
      null;
  end;
  --

 
  begin
    insert into csf_own.dominio
      (dominio,
       vl,
       descr,
       id)
    values
      ('PARAM_EFD_ICMS_IPI.DM_COD_ITEM_IPM_UF',
       'SC',
       'UF que tem código IPM',
       csf_own.dominio_seq.nextval);
  exception
    when others then
      null;
  end;
  --

 
  begin
    insert into csf_own.dominio
      (dominio,
       vl,
       descr,
       id)
    values
      ('PARAM_EFD_ICMS_IPI.DM_COD_ITEM_IPM_UF',
       'SP',
       'UF que tem código IPM',
       csf_own.dominio_seq.nextval);
  exception
    when others then
      null;
  end;
  --

 
  begin
    insert into csf_own.dominio
      (dominio,
       vl,
       descr,
       id)
    values
      ('PARAM_EFD_ICMS_IPI.DM_COD_ITEM_IPM_UF',
       'TO',
       'UF que tem código IPM',
       csf_own.dominio_seq.nextval);
  exception
    when others then
      null;
  end;
  --
  commit;
  --
end;
--
/


---------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #75390 Não está montando 0200 para o item usado no 1400 - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
---------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #75477 Ajuste para vincular pessoa de documentos fiscais Criar tabela NOTA_FISCAL_RELAC - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
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
        and t.TABLE_NAME = 'NOTA_FISCAL_RELAC';
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
         CREATE TABLE CSF_OWN.NOTA_FISCAL_RELAC
         (
		   ID            		 NUMBER 					NOT NULL,
		   NOTAFISCAL_ID 		 NUMBER 					NOT NULL,
		   ATRIBUTO      		 VARCHAR2(30) 				NOT NULL,
		   VALOR         		 VARCHAR2(500)
  
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
      execute immediate 'comment on table CSF_OWN.NOTA_FISCAL_RELAC is ''Tabelas de NOTA_FISCAL_RELAC''';
   exception
      when others then
         null;
   end;   
   --
    begin
      execute immediate 'comment on column CSF_OWN.NOTA_FISCAL_RELAC.ID is ''ID, número sequencia unico para identificação do registro''';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'comment on column CSF_OWN.NOTA_FISCAL_RELAC.NOTAFISCAL_ID is ''Faz referência a um registro da tabela nota fiscal''';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'comment on column CSF_OWN.NOTA_FISCAL_RELAC.ATRIBUTO is ''Nome do atributo que será armazenado, ou seja, ? o rótulo do dado''';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'comment on column CSF_OWN.NOTA_FISCAL_RELAC.VALOR is ''Dado que precisa ser vinculado ao documento''';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'alter table CSF_OWN.NOTA_FISCAL_RELAC add constraint NOTAFISCALRELAC_PK primary key (ID)';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'alter table CSF_OWN.NOTA_FISCAL_RELAC add constraint NOTAFISCALRELAC_UK UNIQUE (NOTAFISCAL_ID, ATRIBUTO)';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'alter table CSF_OWN.NOTA_FISCAL_RELAC add constraint NOTAFISCAL_ID_FK FOREIGN KEY (NOTAFISCAL_ID) REFERENCES CSF_OWN.NOTA_FISCAL (ID)';
   exception
      when others then
         null;
   end;   
   --
   BEGIN
      EXECUTE IMMEDIATE '
         CREATE SEQUENCE CSF_OWN.NOTAFISCALRELAC_SEQ
         INCREMENT BY 1
         START WITH   1
         MINVALUE     -1
         MAXVALUE     999999999999999999999999999
         NOCACHE
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
   BEGIN
		SELECT COUNT(1)
	      INTO vn_existe
		  FROM CSF_OWN.SEQ_TAB
		 WHERE UPPER(SEQUENCE_NAME) = UPPER('NOTAFISCALRELAC_SEQ');
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			vn_existe := 0;
		WHEN OTHERS THEN
			vn_existe := -1;
	END;
	--
	IF NVL(vn_existe, 0) = 0 THEN
		BEGIN
         INSERT INTO CSF_OWN.SEQ_TAB (ID, SEQUENCE_NAME, TABLE_NAME)
          VALUES (CSF_OWN.SEQTAB_SEQ.NEXTVAL, 'NOTAFISCALRELAC_SEQ', 'NOTA_FISCAL_RELAC');
          COMMIT;   
		EXCEPTION 
		 WHEN OTHERS THEN
		  NULL;
		END;
	END IF;
   --
   begin
      execute immediate 'grant all on CSF_OWN.NOTAFISCALRELAC_SEQ to CSF_WORK';
   exception
      when others then
         null;
   end;
   --     
   begin
      execute immediate 'grant all on CSF_OWN.NOTA_FISCAL_RELAC to CSF_WORK';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'grant all on CSF_OWN.NOTA_FISCAL_RELAC to CONSULTORIA';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'grant all on CSF_OWN.NOTA_FISCAL_RELAC to DESENV_USER';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'CREATE OR REPLACE SYNONYM DESENV_USER.NOTA_FISCAL_RELAC for CSF_OWN.NOTA_FISCAL_RELAC';
   exception
      when others then
         null;
   end;
   --
end;
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #75477 Ajuste para vincular pessoa de documentos fiscais Criar tabela NOTA_FISCAL_RELAC - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #75477 Ajuste para vincular pessoa de documentos fiscais Criar tabela CONHEC_TRANSP_RELAC - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
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
        and t.TABLE_NAME = 'CONHEC_TRANSP_RELAC';
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
         CREATE TABLE CSF_OWN.CONHEC_TRANSP_RELAC
         (
		   ID            		 NUMBER 					NOT NULL,
		   CONHECTRANSP_ID 		 NUMBER 					NOT NULL,
		   ATRIBUTO      		 VARCHAR2(30) 				NOT NULL,
		   VALOR         		 VARCHAR2(500)
  
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
      execute immediate 'comment on table CSF_OWN.CONHEC_TRANSP_RELAC is ''Tabelas de CONHEC_TRANSP_RELAC''';
   exception
      when others then
         null;
   end;   
   --
    begin
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_RELAC.ID is ''ID, número sequencia unico para identificação do registro''';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_RELAC.CONHECTRANSP_ID is ''Faz referência a um registro da tabela nota fiscal''';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_RELAC.ATRIBUTO is ''Nome do atributo que será armazenado, ou seja, o rótulo do dado''';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_RELAC.VALOR is ''Dado que precisa ser vinculado ao documento''';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'alter table CSF_OWN.CONHEC_TRANSP_RELAC add constraint CONHECTRANSPRELAC_PK primary key (ID)';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'alter table CSF_OWN.CONHEC_TRANSP_RELAC add constraint CONHECTRANSPRELAC_UK UNIQUE (CONHECTRANSP_ID, ATRIBUTO)';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'alter table CSF_OWN.CONHEC_TRANSP_RELAC add constraint CONHECTRANSPID_FK FOREIGN KEY (CONHECTRANSP_ID) REFERENCES CSF_OWN.CONHEC_TRANSP (ID)';
   exception
      when others then
         null;
   end;   
   --
   BEGIN
      EXECUTE IMMEDIATE '
         CREATE SEQUENCE CSF_OWN.CONHECTRANSPRELAC_SEQ
         INCREMENT BY 1
         START WITH   1
         MINVALUE     -1
         MAXVALUE     999999999999999999999999999
         NOCACHE
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
   BEGIN
		SELECT COUNT(1)
	      INTO vn_existe
		  FROM CSF_OWN.SEQ_TAB
		 WHERE UPPER(SEQUENCE_NAME) = UPPER('CONHECTRANSPRELAC_SEQ');
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			vn_existe := 0;
		WHEN OTHERS THEN
			vn_existe := -1;
	END;
	--
	IF NVL(vn_existe, 0) = 0 THEN
		BEGIN
         INSERT INTO CSF_OWN.SEQ_TAB (ID, SEQUENCE_NAME, TABLE_NAME)
          VALUES (CSF_OWN.SEQTAB_SEQ.NEXTVAL, 'CONHECTRANSPRELAC_SEQ', 'CONHEC_TRANSP_RELAC');
          COMMIT;   
		EXCEPTION 
		 WHEN OTHERS THEN
		  NULL;
		END;
	END IF;
   --
   begin
      execute immediate 'grant all on CSF_OWN.CONHEC_TRANSP_RELAC to CSF_WORK';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'grant all on CSF_OWN.CONHEC_TRANSP_RELAC to CONSULTORIA';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'grant all on CSF_OWN.CONHEC_TRANSP_RELAC to DESENV_USER';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'CREATE OR REPLACE SYNONYM DESENV_USER.CONHEC_TRANSP_RELAC for CSF_OWN.CONHEC_TRANSP_RELAC';
   exception
      when others then
         null;
   end;   
   --
end;
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #75477 Ajuste para vincular pessoa de documentos fiscais Criar tabela CONHEC_TRANSP_RELAC - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine #70422: Criar tabela de apuração de ISS Geral - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
--------------------------------------------------------------------------------------------------------------------------------------
-- APUR_ISS_SIMPLIFICADA --
declare
   vn_existe_tab number := null;
begin
   select count(*)
     into vn_existe_tab
     from SYS.ALL_TABLES a
    where upper(a.OWNER)       = upper('CSF_OWN')
      and upper(a.TABLE_NAME)  = upper('APUR_ISS_SIMPLIFICADA');
   --
   if nvl(vn_existe_tab,0) = 0 then
      --
      execute immediate 'CREATE TABLE CSF_OWN.APUR_ISS_SIMPLIFICADA
                           ( ID                    NUMBER                     NOT NULL,
                             EMPRESA_ID            NUMBER                     NOT NULL,
                             DT_INICIO             DATE                       NOT NULL,
                             DT_FIM                DATE,
                             DM_SITUACAO           NUMBER(1)        DEFAULT 0 NOT NULL,
                             VL_ISS_PROPRIO        NUMBER(15,2),
                             VL_ISS_RETIDO         NUMBER(15,2),
                             VL_ISS_TOTAL          NUMBER(15,2),
                             GUIAPGTOIMP_ID_PROP   NUMBER,
                             GUIAPGTOIMP_ID_RET    NUMBER,
                             DM_SITUACAO_GUIA      NUMBER(1)        DEFAULT 0 NOT NULL,
                             CONSTRAINT APURISSSIMPLIFICADA_PK PRIMARY KEY(ID) USING INDEX TABLESPACE CSF_INDEX
                           )TABLESPACE CSF_DATA';
      --
   end if;
   --
   -- COMMENTS --
   begin
      execute immediate 'comment on table CSF_OWN.APUR_ISS_SIMPLIFICADA                        is ''Tabela de Apuração de ISS Geral (todos municipios, exceto Brasilia)''';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.ID                    is ''Sequencial da tabela APURISSSIMPLIFICADA_SEQ''';
   exception
      when others then
         null;
   end;   
   --   
   begin
      execute immediate 'comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.DT_INICIO             is ''Identificador da empresa''';
   exception
      when others then
         null;
   end;   
   --   
   begin
      execute immediate 'comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.EMPRESA_ID            is ''Data inicial da apuracão do iss''';
   exception
      when others then
         null;
   end;   
   --   
   begin
      execute immediate 'comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.DT_FIM                is ''Data final da apuracão do iss''';
   exception
      when others then
         null;
   end;   
   --   
   begin
      execute immediate 'comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.DM_SITUACAO           is ''Situacão: 0-aberta; 1-Calculada; 2-Erro de calculo; 3-Validada; 4-Erro de validação''';
   exception
      when others then
         null;
   end;   
   --  
   begin
      execute immediate 'comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.VL_ISS_PROPRIO        is ''Valor do ISS próprio sobre serviços prestados''';
   exception
      when others then
         null;
   end;   
   --   
   begin
      execute immediate 'comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.VL_ISS_RETIDO         is ''Valor do ISS retido sobre serviços tomados''';
   exception
      when others then
         null;
   end;   
   --   
   begin
      execute immediate 'comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.VL_ISS_TOTAL          is ''Valor Total do ISS  - soma de Proprio + Retido''';
   exception
      when others then
         null;
   end;   
   --   
   begin
      execute immediate 'comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.GUIAPGTOIMP_ID_PROP   is ''Identificador da guia de ISS Proprio''';
   exception
      when others then
         null;
   end;   
   --   
   begin
      execute immediate 'comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.GUIAPGTOIMP_ID_RET    is ''Identificador da guia de ISS Retido''';
   exception
      when others then
         null;
   end;   
   --   
   begin
      execute immediate 'comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.DM_SITUACAO_GUIA      is ''Situacao da Guia de Pagamento: 0:Nao gerada / 1:Guia Gerada / 2:Erro na Geracao da Guia''';
   exception
      when others then
         null;
   end;   
   --   
   -- CONTRAINTS --  
   begin
      execute immediate 'alter table CSF_OWN.APUR_ISS_SIMPLIFICADA  add constraint APURISSSIMP_EMPRESA_FK         foreign key (EMPRESA_ID)          references CSF_OWN.EMPRESA (ID)';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'alter table CSF_OWN.APUR_ISS_SIMPLIFICADA  add constraint APURISSSIMP_GUIAPGTOIMP01_FK   foreign key (GUIAPGTOIMP_ID_PROP) references CSF_OWN.GUIA_PGTO_IMP (ID)';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'alter table CSF_OWN.APUR_ISS_SIMPLIFICADA  add constraint APURISSSIMP_GUIAPGTOIMP02_FK   foreign key (GUIAPGTOIMP_ID_RET)  references CSF_OWN.GUIA_PGTO_IMP (ID)';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'alter table CSF_OWN.APUR_ISS_SIMPLIFICADA  add constraint APURISSSIMP_DMSITUACAO_CK      check (DM_SITUACAO IN (0,1,2,3,4))';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'alter table CSF_OWN.APUR_ISS_SIMPLIFICADA add constraint APURISSSIMP_DMSITUACAOGUIA_CK   check (DM_SITUACAO_GUIA in (0,1,2))';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'alter table CSF_OWN.APUR_ISS_SIMPLIFICADA add constraint APURISSSIMPLIFICADA_UK unique (EMPRESA_ID, DT_INICIO, DT_FIM)   using index TABLESPACE CSF_INDEX';
   exception
      when others then
         null;
   end;   
   --
   -- INDEX --
   begin
      execute immediate 'create index APURISSSIMP_EMPRESA_IX        on CSF_OWN.APUR_ISS_SIMPLIFICADA (EMPRESA_ID)           TABLESPACE CSF_INDEX';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'create index APURISSSIMP_GUIAPGTOIMP01_IX  on CSF_OWN.APUR_ISS_SIMPLIFICADA (GUIAPGTOIMP_ID_PROP)  TABLESPACE CSF_INDEX';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'create index APURISSSIMP_GUIAPGTOIMP02_IX  on CSF_OWN.APUR_ISS_SIMPLIFICADA (GUIAPGTOIMP_ID_RET)   TABLESPACE CSF_INDEX';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'create index APURISSSIMP_DMSITUACAOGUIA_IX on CSF_OWN.APUR_ISS_SIMPLIFICADA (DM_SITUACAO_GUIA)     TABLESPACE CSF_INDEX';
   exception
      when others then
         null;
   end;   
   --   
   -- SEQUENCE --
   begin
      execute immediate '
         CREATE SEQUENCE CSF_OWN.APURISSSIMPLIFICADA_SEQ
         INCREMENT BY 1
         START WITH   1
         NOMINVALUE
         NOMAXVALUE
         NOCYCLE
         NOCACHE';
   exception
     when others then
        if sqlcode = -955 then
           null;
        else
          raise;
        end if;
   end;
   --   
   begin
      INSERT INTO CSF_OWN.SEQ_TAB ( id
                                  , sequence_name
                                  , table_name
                                  )
                           values ( CSF_OWN.seqtab_seq.nextval
                                  , 'APURISSSIMPLIFICADA_SEQ'
                                  , 'APUR_ISS_SIMPLIFICADA'
                                  );
   exception
      when dup_val_on_index then
         null;
   end;
   --
   -- DOMINIO: APUR_ISS_SIMPLIFICADA.DM_SITUACAO -------------------------------------------------------------
   --'Situacão: 0-aberta; 1-Calculada; 2-Erro de calculo; 3-Validada; 4-Erro de validação'
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('APUR_ISS_SIMPLIFICADA.DM_SITUACAO',
                                  '0',
                                  'Aberta',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('APUR_ISS_SIMPLIFICADA.DM_SITUACAO',
                                  '1',
                                  'Calculada',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('APUR_ISS_SIMPLIFICADA.DM_SITUACAO',
                                  '2',
                                  'Erro',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('APUR_ISS_SIMPLIFICADA.DM_SITUACAO',
                                  '3',
                                  'Validada',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('APUR_ISS_SIMPLIFICADA.DM_SITUACAO',
                                  '4',
                                  'Erro de Validação',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;
   --
   -- DOMINIO: APUR_ISS_SIMPLIFICADA.DM_SITUACAO_GUIA ------------------------------------------------------------- 
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('APUR_ISS_SIMPLIFICADA.DM_SITUACAO_GUIA',
                                  '0',
                                  'Não Gerada',
                                  DOMINIO_SEQ.NEXTVAL);
      --
      COMMIT;
      --   
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('APUR_ISS_SIMPLIFICADA.DM_SITUACAO_GUIA',
                                  '1',
                                  'Guia Gerada',
                                  DOMINIO_SEQ.NEXTVAL);
      --
      COMMIT;
      --   
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('APUR_ISS_SIMPLIFICADA.DM_SITUACAO_GUIA',
                                  '2',
                                  'Erro na Geração da Guia',
                                  DOMINIO_SEQ.NEXTVAL);
      --
      COMMIT;
      --   
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --   
   commit;
   --
exception
   when others then
      raise_application_error(-20001, 'Erro no script 73052S. Criacao da tabela APUR_ISS_SIMPLIFICADA. Erro: ' || sqlerrm);
end;
/

grant select, insert, update, delete   on CSF_OWN.APUR_ISS_SIMPLIFICADA     to CSF_WORK
/

grant select                           on CSF_OWN.APURISSSIMPLIFICADA_SEQ   to CSF_WORK
/

COMMIT
/

-- LOG_GENERICO_APUR_ISS --
declare
   vn_existe_tab number := null;
begin
   select count(*)
     into vn_existe_tab
     from SYS.ALL_TABLES a
    where upper(a.OWNER)       = upper('CSF_OWN')
      and upper(a.TABLE_NAME)  = upper('LOG_GENERICO_APUR_ISS');
   --
   if nvl(vn_existe_tab,0) = 0 then
      --
      execute immediate 'CREATE TABLE CSF_OWN.LOG_GENERICO_APUR_ISS(   
         id             NUMBER not null,
         empresa_id     NUMBER,
         processo_id    NUMBER not null,
         dt_hr_log      DATE not null,
         referencia_id  NUMBER,
         obj_referencia VARCHAR2(30),
         resumo         VARCHAR2(4000),
         mensagem       VARCHAR2(4000) not null,
         dm_impressa    NUMBER(1) not null,
         dm_env_email   NUMBER(1) not null,
         csftipolog_id  NUMBER not null,
         CONSTRAINT LOGGENERICOAPURISS_PK PRIMARY KEY(ID) USING INDEX TABLESPACE CSF_INDEX
       )TABLESPACE CSF_DATA';
      --
   end if;
   --
   -- COMMENTS --
   begin
      execute immediate 'comment on table CSF_OWN.LOG_GENERICO_APUR_ISS  is ''Tabela de Log Genérico da apuração do ISS''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.LOG_GENERICO_APUR_ISS.id             is ''Identificador do registro - LOGGENERICOAPURISS_SEQ''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.LOG_GENERICO_APUR_ISS.empresa_id     is ''ID relacionado a tabela EMPRESA''' ;
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.LOG_GENERICO_APUR_ISS.processo_id    is ''Id do processo''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.LOG_GENERICO_APUR_ISS.dt_hr_log      is ''Data de geração do log''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.LOG_GENERICO_APUR_ISS.referencia_id  is ''ID de referencia do registro''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.LOG_GENERICO_APUR_ISS.obj_referencia is ''Nome do objeto de referencia''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.LOG_GENERICO_APUR_ISS.resumo         is ''Resumo do log''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.LOG_GENERICO_APUR_ISS.mensagem       is ''Mensagem detalhada''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.LOG_GENERICO_APUR_ISS.dm_impressa    is ''Valores válidos: 0-Não; 1-Sim''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.LOG_GENERICO_APUR_ISS.dm_env_email   is ''Valores válidos: 0-Não; 1-Sim''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.LOG_GENERICO_APUR_ISS.csftipolog_id  is ''ID relacionado a tabela CSF_TIPO_LOG''';
   exception
      when others then
         null;
   end;
   --
   -- INDEX --
   begin
      execute immediate 'create index LOGGENAPURISS_CSFTIPOLOG_IX on CSF_OWN.LOG_GENERICO_APUR_ISS (CSFTIPOLOG_ID) tablespace CSF_INDEX';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'create index LOGGENAPURISS_EMPRESA_IX    on CSF_OWN.LOG_GENERICO_APUR_ISS (EMPRESA_ID)    tablespace CSF_INDEX';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'create index LOGGENAPURISS_IX01          on CSF_OWN.LOG_GENERICO_APUR_ISS (OBJ_REFERENCIA, REFERENCIA_ID, DT_HR_LOG)  tablespace CSF_INDEX';
   exception
      when others then
         null;
   end;
   --
   -- CONSTRAINTS --
   begin
      execute immediate 'alter table CSF_OWN.LOG_GENERICO_APUR_ISS add constraint LOGGENAPURISS_CSFTIPOLOG_FK   foreign key (CSFTIPOLOG_ID) references CSF_OWN.CSF_TIPO_LOG (ID)';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'alter table CSF_OWN.LOG_GENERICO_APUR_ISS add constraint LOGGENAPURISS_EMPRESA_FK      foreign key (EMPRESA_ID)    references CSF_OWN.EMPRESA (ID)';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'alter table CSF_OWN.LOG_GENERICO_APUR_ISS  add constraint LOGGENAPURISS_DMENVEMAIL_CK  check (DM_ENV_EMAIL IN (0,1))';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'alter table CSF_OWN.LOG_GENERICO_APUR_ISS  add constraint LOGGENAPURISS_DMIMPRESSA_CK  check (DM_IMPRESSA IN(0,1))';
   exception
      when others then
         null;
   end;
   --
   -- SEQUENCE --
   BEGIN
      EXECUTE IMMEDIATE '
         CREATE SEQUENCE CSF_OWN.LOGGENERICOAPURISS_SEQ
         INCREMENT BY 1
         START WITH   1
         NOMINVALUE
         NOMAXVALUE
         NOCYCLE
         NOCACHE
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
   BEGIN
      INSERT INTO CSF_OWN.SEQ_TAB ( id
                                  , sequence_name
                                  , table_name
                                  )
                           values ( CSF_OWN.seqtab_seq.nextval
                                  , 'LOGGENERICOAPURISS_SEQ'
                                  , 'LOG_GENERICO_APUR_ISS'
                                  );
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;
   --
   -- DOMINIO: LOG_GENERICO_APUR_ISS.DM_ENV_EMAIL -------------------------------------------------------------
   --'Valores válidos: 0-Não; 1-Sim'
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('LOG_GENERICO_APUR_ISS.DM_ENV_EMAIL',
                                  '0',
                                  'Não',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('LOG_GENERICO_APUR_ISS.DM_ENV_EMAIL',
                                  '1',
                                  'Sim',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;
   --
   -- DOMINIO: LOG_GENERICO_APUR_ISS.DM_IMPRESSA -------------------------------------------------------------
   --'Valores válidos: 0-Não; 1-Sim'
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('LOG_GENERICO_APUR_ISS.DM_IMPRESSA',
                                  '0',
                                  'Não',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('LOG_GENERICO_APUR_ISS.DM_IMPRESSA',
                                  '1',
                                  'Sim',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;
   --
   commit;
   --
exception
   when others then
      raise_application_error(-20001, 'Erro no script 70422. Criacao da tabela LOG_GENERICO_APUR_ISS. Erro: ' || sqlerrm);
end;
/

grant select, insert, update, delete   on CSF_OWN.LOG_GENERICO_APUR_ISS     to CSF_WORK
/

grant select                           on CSF_OWN.LOGGENERICOAPURISS_SEQ    to CSF_WORK
/

COMMIT
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Fim Redmine #70422: Criar tabela de apuração de ISS Geral - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine #65266: Especificacao funcional - Tabela PARAM_GUIA_PGTO - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
--------------------------------------------------------------------------------------------------------------------------------------
-- PARAM_DET_GUIA_IMP --
declare
   vn_existe_tab number := null;
begin
   select count(*)
     into vn_existe_tab
     from SYS.ALL_TABLES a
    where upper(a.OWNER)       = upper('CSF_OWN')
      and upper(a.TABLE_NAME)  = upper('PARAM_GUIA_PGTO');
   --
   if nvl(vn_existe_tab,0) = 0 then
      --
      execute immediate '
         CREATE TABLE CSF_OWN.PARAM_GUIA_PGTO(
            ID                 NUMBER not null,
            EMPRESA_ID         NUMBER not null,
            DM_UTIL_RET_ERP    NUMBER(1) not null,
            DM_GERA_NRO_TIT    NUMBER(1) not null,
            NRO_ULT_TIT_FIN    NUMBER,
            DT_ALTERACAO       DATE default (SYSDATE) not null,
            CONSTRAINT PARAMGUIAPGTO_PK PRIMARY KEY(ID) USING INDEX TABLESPACE CSF_INDEX
         )TABLESPACE CSF_DATA';
      --   
   end if;
   --
   -- COMMENTS --
   begin
      execute immediate 'comment on table CSF_OWN.PARAM_GUIA_PGTO                   is ''Parametro de guias de pagamentos''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_GUIA_PGTO.id               is ''Sequencial da tabela PARAMGUIAPGTO_SEQ''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_GUIA_PGTO.empresa_id       is ''ID relacionado a tabela EMPRESA''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_GUIA_PGTO.dm_util_ret_erp  is ''Utiliza retorno com ERP: 0=Não / 1=Sim''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_GUIA_PGTO.dm_gera_nro_tit  is ''Indica se deve haver controle numérico sequencial nas guias de pagamento - isso será retornado ao ERP: 0=Não / 1 = Sim''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_GUIA_PGTO.nro_ult_tit_fin  is ''Numero do ultimo titulo. Só deve ser preenchido quando sistema controlar numeração de titulos''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_GUIA_PGTO.dt_alteracao     is ''Data da ultima alteração''';
   exception
      when others then
         null;
   end;
   --
   -- CONSTRAINTS --
   begin
      execute immediate 'alter table CSF_OWN.PARAM_GUIA_PGTO  add constraint PARAMGUIAPGTO_EMPRESA_FK foreign key (EMPRESA_ID)  references CSF_OWN.EMPRESA (ID)';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'alter table CSF_OWN.PARAM_GUIA_PGTO  add constraint PARAMGUIAPGTO_DMGERANROTIT_CK  check (DM_GERA_NRO_TIT IN (0, 1))';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'alter table CSF_OWN.PARAM_GUIA_PGTO  add constraint PARAMGUIAPGTO_DMUTILRETERP_CK  check (DM_UTIL_RET_ERP IN (0, 1))';
   exception
      when others then
         null;
   end;
   --
   -- INDEXES --
   begin
      execute immediate 'create index PARAMGUIAPGTO_DMGERANROTIT_IX on CSF_OWN.PARAM_GUIA_PGTO (DM_GERA_NRO_TIT)  tablespace CSF_INDEX';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'create index PARAMGUIAPGTO_DMUTILRETERP_IX on CSF_OWN.PARAM_GUIA_PGTO (DM_UTIL_RET_ERP)  tablespace CSF_INDEX';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'create index PARAMGUIAPGTO_EMPRESAID_IX on CSF_OWN.PARAM_GUIA_PGTO (EMPRESA_ID)          tablespace CSF_INDEX';
   exception
      when others then
         null;
   end;
   --
   -- SEQUENCE --
   BEGIN
      EXECUTE IMMEDIATE '
         CREATE SEQUENCE CSF_OWN.PARAMGUIAPGTO_SEQ
         INCREMENT BY 1
         START WITH   1
         NOMINVALUE
         NOMAXVALUE
         NOCYCLE
         NOCACHE
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
   BEGIN
      INSERT INTO CSF_OWN.SEQ_TAB ( id
                                  , sequence_name
                                  , table_name
                                  )
                           values ( CSF_OWN.seqtab_seq.nextval
                                  , 'PARAMGUIAPGTO_SEQ'
                                  , 'PARAM_GUIA_PGTO'
                                  );
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                                
   --
   -- DOMINIO: PARAM_GUIA_PGTO.DM_GERA_NRO_TIT ------------------------------------------------------------- 
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_GUIA_PGTO.DM_GERA_NRO_TIT',
                                  '0',
                                  'Não',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_GUIA_PGTO.DM_GERA_NRO_TIT',
                                  '1',
                                  'Sim',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   commit;
   --
exception
   when others then
      raise_application_error(-20001, 'Erro no script #65266. Criacao da tabela PARAM_GUIA_PGTO. Erro: ' || sqlerrm);
end;
/

-- GRANTS --
grant select, insert, update, delete   on CSF_OWN.PARAM_GUIA_PGTO     to CSF_WORK
/

grant select                           on CSF_OWN.PARAMGUIAPGTO_SEQ   to CSF_WORK
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Término Redmine #65266: Especificacao funcional - Tabela PARAM_GUIA_PGTO - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine #65266: Especificacao funcional - Tabela PARAM_DET_GUIA_IMP - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
--------------------------------------------------------------------------------------------------------------------------------------
-- PARAM_DET_GUIA_IMP --
declare
   vn_existe_tab number := null;
begin
   select count(*)
     into vn_existe_tab
     from SYS.ALL_TABLES a
    where upper(a.OWNER)       = upper('CSF_OWN')
      and upper(a.TABLE_NAME)  = upper('PARAM_DET_GUIA_IMP');
   --
   if nvl(vn_existe_tab,0) = 0 then
      --
      execute immediate '
         CREATE TABLE CSF_OWN.PARAM_DET_GUIA_IMP
         (
           ID                    NUMBER          NOT NULL,
           PARAMGUIAPGTO_ID      NUMBER          NOT NULL,
           TIPOIMP_ID            NUMBER          NOT NULL,
           DM_TIPO               NUMBER(1)       NOT NULL,
           DM_ORIGEM             NUMBER(2)       NOT NULL,
           NRO_VIA_IMPRESSA      NUMBER(3)           NULL,
           EMPRESA_ID_GUIA       NUMBER              NULL,
           OBS                   VARCHAR2(500)       NULL,
           PESSOA_ID_SEFAZ       NUMBER              NULL,
           TIPORETIMP_ID         NUMBER              NULL,
           TIPORETIMPRECEITA_ID  NUMBER              NULL,
           DIA_VCTO              NUMBER(2)           NULL,
           CONSTRAINT PARAMDETGUIAIMP_PK PRIMARY KEY(ID) USING INDEX TABLESPACE CSF_INDEX
         ) TABLESPACE CSF_DATA';
      --   
   end if;
   -- COMMENTS --
   begin
      execute immediate 'comment on table CSF_OWN.PARAM_DET_GUIA_IMP                     is ''Detalhamento por impostos de parametros da guia de pagamento''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_DET_GUIA_IMP.ID                 is ''Sequencial da tabela PARAMDETGUIAIMP_SEQ''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_DET_GUIA_IMP.PARAMGUIAPGTO_ID   is ''ID relacionado a tabela PARAM_GUIA_PGTO''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_DET_GUIA_IMP.TIPOIMP_ID         is ''ID relacionado a tabela TIPO_IMPOSTO''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_DET_GUIA_IMP.DM_TIPO            is ''Tipo da Guia: 1-GPS; 2-DARF; 3-GARE; 4-GNRE; 5-OUTROS''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_DET_GUIA_IMP.DM_ORIGEM          is ''Origem dos dados: 1-Imposto Retido; 2-Apuração IPI; 3-Apuração ICMS; 4-Apuracao ICMS-ST; 5-Sub-Apuração ICMS; 6-Apuração ICMS-DIFAL; 7-Apuração PIS; 8-Apuração COFINS; 9-Apuração de ISS; 10-INSS Retido em Nota Serviço; 11-Apuração IRPJ; 12-Apuração CSLL''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_DET_GUIA_IMP.NRO_VIA_IMPRESSA   is ''Numero de vias que serão impressas caso recurso esteja em uso''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_DET_GUIA_IMP.EMPRESA_ID_GUIA    is ''ID relacionado a tabela EMPRESA na qual deve ser criada a guia, por exemplo ID da matriz. Se tiver vazio pegará do parametro principal''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_DET_GUIA_IMP.OBS                is ''Observação que deve sair descrita na guia''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_DET_GUIA_IMP.PESSOA_ID_SEFAZ    is ''ID relacionado a tabela PESSOA que possui o direito de receber o valor do titulo financeiro ou guia, no caso sera a Receita Federal, Estadual ou Municipal''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_DET_GUIA_IMP.tiporetimp_id      is ''Código de recolhimento principal''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_DET_GUIA_IMP.tiporetimpreceita_id is ''Complemento do códIgo de recolhimento - no caso de Darf onde esses 2 dígitos indica o período''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_DET_GUIA_IMP.dia_vcto is ''Dia de vencimento do pagamento da guia''';
   exception
      when others then
         null;
   end;   
   --
   -- CONSTRAINTS --
   begin
      execute immediate 'alter table CSF_OWN.PARAM_DET_GUIA_IMP  add constraint PDETGUIAIMP_PARAMGUIAPGTO_FK  foreign key (PARAMGUIAPGTO_ID) references CSF_OWN.PARAM_GUIA_PGTO (ID)';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'alter table CSF_OWN.PARAM_DET_GUIA_IMP  add constraint PDETGUIAIMP_TIPOIMPID_FK      foreign key (TIPOIMP_ID)       references CSF_OWN.TIPO_IMPOSTO (ID)';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'alter table CSF_OWN.PARAM_DET_GUIA_IMP  add constraint PDETGUIAIMP_EMPRESAIDGUIA_FK  foreign key (EMPRESA_ID_GUIA)  references CSF_OWN.EMPRESA (ID)';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'alter table CSF_OWN.PARAM_DET_GUIA_IMP  add constraint PDETGUIAIMP_PESSOAIDSEFAZ_FK  foreign key (PESSOA_ID_SEFAZ)  references CSF_OWN.PESSOA (ID)';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'alter table CSF_OWN.PARAM_DET_GUIA_IMP  add constraint PDETGUIAIMP_DMTIPO_CK         check (DM_TIPO IN (1,2,3,4,5))';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'alter table CSF_OWN.PARAM_DET_GUIA_IMP  add constraint PDETGUIAIMP_DMORIGEM_CK       check (DM_ORIGEM IN (1,2,3,4,5,6,7,8,9,10,11,12))';
   exception
      when others then
         null;
   end;
   --
   -- INDEXES --
   begin
      execute immediate 'create index PDETGUIAIMP_PARAMGUIAPGTO_IX  on CSF_OWN.PARAM_DET_GUIA_IMP (PARAMGUIAPGTO_ID)  TABLESPACE CSF_INDEX';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'create index PDETGUIAIMP_TIPOIMPID_IX      on CSF_OWN.PARAM_DET_GUIA_IMP (TIPOIMP_ID)        TABLESPACE CSF_INDEX';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'create index PDETGUIAIMP_EMPRESAIDGUIA_IX  on CSF_OWN.PARAM_DET_GUIA_IMP (EMPRESA_ID_GUIA)   TABLESPACE CSF_INDEX';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'create index PDETGUIAIMP_PESSOAIDSEFAZ_IX  on CSF_OWN.PARAM_DET_GUIA_IMP (PESSOA_ID_SEFAZ)   TABLESPACE CSF_INDEX';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'create index PDETGUIAIMP_DMTIPO_IX         on CSF_OWN.PARAM_DET_GUIA_IMP (DM_TIPO)           TABLESPACE CSF_INDEX';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'create index PDETGUIAIMP_DMORIGEM_IX       on CSF_OWN.PARAM_DET_GUIA_IMP (DM_ORIGEM)         TABLESPACE CSF_INDEX';
   exception
      when others then
         null;
   end;
   --
   -- SEQUENCE --
   BEGIN
      EXECUTE IMMEDIATE '
         CREATE SEQUENCE CSF_OWN.PARAMDETGUIAIMP_SEQ
         INCREMENT BY 1
         START WITH   1
         NOMINVALUE
         NOMAXVALUE
         NOCYCLE
         NOCACHE
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
   BEGIN
      INSERT INTO CSF_OWN.SEQ_TAB ( id
                                  , sequence_name
                                  , table_name
                                  )
                           values ( CSF_OWN.seqtab_seq.nextval
                                  , 'PARAMDETGUIAIMP_SEQ'
                                  , 'PARAM_DET_GUIA_IMP'
                                  );
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                                
   --
   -- DOMINIO: PARAM_DET_GUIA_IMP.DM_TIPO ------------------------------------------------------------- 
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_TIPO',
                                  '1',
                                  'GPS',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_TIPO',
                                  '2',
                                  'DARF',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_TIPO',
                                  '3',
                                  'GARE',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_TIPO',
                                  '4',
                                  'GNRE',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_TIPO',
                                  '5',
                                  'OUTROS',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   -- DOMINIO: PARAM_DET_GUIA_IMP.DM_ORIGEM ------------------------------------------------------------- 
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_ORIGEM',
                                  '1',
                                  'Imposto Retido',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_ORIGEM',
                                  '2',
                                  'Apuração IPI',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_ORIGEM',
                                  '3',
                                  'Apuração ICMS',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_ORIGEM',
                                  '4',
                                  'Apuracao ICMS-ST',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_ORIGEM',
                                  '5',
                                  'Sub-Apuração ICMS',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_ORIGEM',
                                  '6',
                                  'Apuração ICMS-DIFAL',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_ORIGEM',
                                  '7',
                                  'Apuração PIS',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_ORIGEM',
                                  '8',
                                  'Apuração COFINS',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_ORIGEM',
                                  '9',
                                  'Apuração de ISS',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_ORIGEM',
                                  '10',
                                  'INSS Retido em Nota Serviço',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_ORIGEM',
                                  '11',
                                  'Apuração IRPJ',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_ORIGEM',
                                  '12',
                                  'Apuração CSLL',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;
   --
   COMMIT;
   --
exception
   when others then
      raise_application_error(-20001, 'Erro no script #65266. Criacao da tabela PARAM_DET_GUIA_IMP. Erro: ' || sqlerrm);
end;
/
--
grant select, insert, update, delete   on CSF_OWN.PARAM_DET_GUIA_IMP     to CSF_WORK
/

grant select                           on CSF_OWN.PARAMDETGUIAIMP_SEQ    to CSF_WORK
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Término Redmine #65266: Especificacao funcional - Tabela PARAM_DET_GUIA_IMP - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine #70422: Criar tabela de apuração de ISS Geral - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
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
   --
   pExec_Imed('alter table CSF_OWN.PARAM_DET_GUIA_IMP add cidade_id NUMBER');
   --
   pExec_Imed('alter table CSF_OWN.PARAM_DET_GUIA_IMP add planoconta_id NUMBER');
   --
   pExec_Imed('comment on column CSF_OWN.PARAM_DET_GUIA_IMP.cidade_id  is ''ID relacionado com a tabela CIDADE''');
   --
   pExec_Imed('comment on column CSF_OWN.PARAM_DET_GUIA_IMP.planoconta_id  is ''ID relacionado com a tabela PLANO_CONTA''');
   --
   pExec_Imed('create index PDETGUIAIMP_CIDADE_IX on CSF_OWN.PARAM_DET_GUIA_IMP (CIDADE_ID) tablespace CSF_INDEX');
   --
   pExec_Imed('create index PDETGUIAIMP_PLANOCONTA_IX on CSF_OWN.PARAM_DET_GUIA_IMP (PLANOCONTA_ID) tablespace CSF_INDEX');
   --
   pExec_Imed('alter table CSF_OWN.PARAM_DET_GUIA_IMP add constraint PDETGUIAIMP_CIDADE_FK foreign key (CIDADE_ID) references CIDADE (ID)');
   --
   pExec_Imed('alter table CSF_OWN.PARAM_DET_GUIA_IMP add constraint PDETGUIAIMP_PLANOCONTA_FK foreign key (PLANOCONTA_ID)  references PLANO_CONTA (ID)');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add nro_tit_financ NUMBER(15)');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add dt_alteracao DATE default sysdate not null');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add dm_ret_erp NUMBER(1) default 0 not null');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add id_erp NUMBER(15)');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.dm_situacao       is ''Situacao: 0-Nao Validado; 1-Validado; 2-Erro de Validacao; 3-Cancelado''');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.pessoa_id         is ''ID relacionado a tabela PESSOA devedora do titulo''');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.dm_tipo           is ''Tipo da Guia: 1-GPS; 2-DARF; 3-GARE; 4-GNRE; 5-OUTROS''');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.dm_origem         is ''Origem dos dados: 0-Manual; 1-Imposto Retido; 2-Apuração IPI; 3-Apuração ICMS; 4-Apuracao ICMS-ST; 5-Sub-Apuração ICMS; 6-Apuração ICMS-DIFAL; 7-Apuração PIS; 8-Apuração COFINS; 9-Apuração de ISS; 10-INSS Retido em Nota Serviço; 11-Apuração IRPJ; 12-Apuração CSLL''');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.nro_via_impressa  is ''Número de vias impressas''');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.dt_ref            is ''Data de Referencia ou Periodo de Apuracao''');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.obs               is ''Observação qualquer sobre a guia''');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.pessoa_id_sefaz   is ''ID relacionado a tabela PESSOA que possui o direito de receber o valor do titulo financeiro ou guia, no caso sera a Receita Federal, Estadual ou Municipal''');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.nro_tit_financ    is ''Numero do titulo financeiro que sera gerado no ERP caso o mesmo permita''');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.dm_ret_erp        is ''Indicador de retorno de registro para o ERP: 0-Nao retornado; 1-Retornado ao ERP; 2-Gerado titulo ERP; 3-Falha ao gerar titulo ERP; 4-Titulo cancelado ERP; 5-Erro ao cancelar titulo ERP''');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.id_erp            is ''Identificador numerico do registro financeiro no ERP''');
   --
   pExec_Imed('create index GUIAPGTOIMP_PESSOAIDSEFAZ_FK_I on CSF_OWN.GUIA_PGTO_IMP (PESSOA_ID_SEFAZ) tablespace CSF_INDEX');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP  add constraint GUIAPGTOIMP_PESSOAID_SEFAZ_FK foreign key (PESSOA_ID_SEFAZ) references PESSOA (ID)');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP  drop constraint GUIAPGTOIMP_ORIGEM_CK');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP  add constraint  GUIAPGTOIMP_ORIGEM_CK    check (DM_ORIGEM in (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12))');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP  drop constraint GUIAPGTOIMP_SITUACAO_CK');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP  add constraint  GUIAPGTOIMP_SITUACAO_CK  check (DM_SITUACAO in (0, 1, 2, 3))');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP  drop constraint GUIAPGTOIMP_TIPO_CK');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP  add constraint  GUIAPGTOIMP_TIPO_CK      check (DM_TIPO in (1, 2, 3, 4, 5))');
   --
   pExec_Imed('alter table CSF_OWN.APUR_IRPJ_CSLL_PARCIAL add dm_situacao_guia NUMBER(1) default 0');
   --
   pExec_Imed('comment on column CSF_OWN.APUR_IRPJ_CSLL_PARCIAL.dm_situacao_guia  is ''Situacao da Guia de Pagamento: 0:Nao gerada / 1:Guia Gerada / 2:Erro na Geracao da Guia''');
   --
   pExec_Imed('alter table CSF_OWN.APUR_IRPJ_CSLL_PARCIAL  add constraint APURIRPJCSLLP_DMSITUACAOG_CK check (DM_SITUACAO_GUIA in (0,1,2))');
   --
   pExec_Imed('create index APURIRPJCSLLP_DMSITUACAOG_IX on APUR_IRPJ_CSLL_PARCIAL (DM_SITUACAO_GUIA) tablespace CSF_INDEX');
   --
   pExec_Imed('alter table CSF_OWN.PGTO_IMP_RET add guiapgtoimp_id NUMBER');
   --
   pExec_Imed('comment on column CSF_OWN.PGTO_IMP_RET.guiapgtoimp_id is ''ID que relaciona a tabela GUIA_PGTO_IMP''');
   --
   pExec_Imed('alter table CSF_OWN.PGTO_IMP_RET add constraint PGTOIMPRET_GUIAPGTOIMP_FK foreign key (GUIAPGTOIMP_ID) references GUIA_PGTO_IMP (ID)');
   --
   pExec_Imed('create index PGTOIMPRET_GUIAPGTOIMP_IX on CSF_OWN.PGTO_IMP_RET (GUIAPGTOIMP_ID) tablespace CSF_INDEX');
   --
   pExec_Imed('alter table CSF_OWN.APURACAO_ICMS_ST add dm_situacao_guia NUMBER default 0');
   --
   pExec_Imed('comment on column APURACAO_ICMS_ST.dm_situacao_guia is ''Situação de geração da guia de pagamento" e com as opções : "0=Não Gerada / 1=Guia Gerada / 2=Erro na Geração da Guia''');
   --
   pExec_Imed('alter table CSF_OWN.APURACAO_ICMS add constraint APURACAOICMS_DMSITUACAOGUIA_CK check (DM_SITUACAO_GUIA IN (0,1,2))');
   --
   pExec_Imed('create index APURICMSST_DMSITUACAOGUIA_IX on CSF_OWN.APURACAO_ICMS_ST (DM_SITUACAO_GUIA) tablespace CSF_INDEX');
   --
   pExec_Imed('alter table CSF_OWN.OBRIG_REC_APUR_ICMS_ST add guiapgtoimp_id NUMBER');
   --
   pExec_Imed('comment on column CSF_OWN.OBRIG_REC_APUR_ICMS_ST.guiapgtoimp_id  is ''Relacionamento com a tabela GUIA_PGTO_IMP''');
   --
   pExec_Imed('alter table CSF_OWN.OBRIG_REC_APUR_ICMS_ST add constraint OBRECAPICMSST_GUIAPGTOIMP_FK foreign key (GUIAPGTOIMP_ID)  references GUIA_PGTO_IMP (ID)');
   --
   pExec_Imed('create index CSF_OWN.OBRECAPICMSST_GUIAPGTOIMP_IX on OBRIG_REC_APUR_ICMS_ST (GUIAPGTOIMP_ID) tablespace CSF_INDEX');
   --
   commit;
   --
exception
   when others then
      raise_application_error(-20001, 'Erro no script 70422 - Erro: ' || sqlerrm);
end;
/

-- APUR_ISS_SIMPLIFICADA --
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
   --
   pExec_Imed('CREATE TABLE CSF_OWN.APUR_ISS_SIMPLIFICADA
                           ( ID                    NUMBER                     NOT NULL,
                             EMPRESA_ID            NUMBER                     NOT NULL,
                             DT_INICIO             DATE                       NOT NULL,
                             DT_FIM                DATE,
                             DM_SITUACAO           NUMBER(1)        DEFAULT 0 NOT NULL,
                             VL_ISS_PROPRIO        NUMBER(15,2),
                             VL_ISS_RETIDO         NUMBER(15,2),
                             VL_ISS_TOTAL          NUMBER(15,2),
                             GUIAPGTOIMP_ID_PROP   NUMBER,
                             GUIAPGTOIMP_ID_RET    NUMBER,
                             DM_SITUACAO_GUIA      NUMBER(1)        DEFAULT 0 NOT NULL,
                             CONSTRAINT APURISSSIMPLIFICADA_PK PRIMARY KEY(ID) USING INDEX TABLESPACE CSF_INDEX
                           )TABLESPACE CSF_DATA');
   -- COMMENTS --
   --
   pExec_Imed('comment on table CSF_OWN.APUR_ISS_SIMPLIFICADA                        is ''Tabela de Apuração de ISS Geral (todos municipios, exceto Brasilia)''');
   --   
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.ID                    is ''Sequencial da tabela APURISSSIMPLIFICADA_SEQ''');
   --   
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.DT_INICIO             is ''Identificador da empresa''');
   --   
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.EMPRESA_ID            is ''Data inicial da apuracão do iss''');
   --   
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.DT_FIM                is ''Data final da apuracão do iss''');
   --   
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.DM_SITUACAO           is ''Situacão: 0-aberta; 1-Calculada; 2-Erro de calculo; 3-Validada; 4-Erro de validação''');
   --   
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.VL_ISS_PROPRIO        is ''Valor do ISS próprio sobre serviços prestados''');
   --   
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.VL_ISS_RETIDO         is ''Valor do ISS retido sobre serviços tomados''');
   --   
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.VL_ISS_TOTAL          is ''Valor Total do ISS  - soma de Proprio + Retido''');
   --   
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.GUIAPGTOIMP_ID_PROP   is ''Identificador da guia de ISS Proprio''');
   --   
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.GUIAPGTOIMP_ID_RET    is ''Identificador da guia de ISS Retido''');
   --   
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.DM_SITUACAO_GUIA      is ''Situacao da Guia de Pagamento: 0:Nao gerada / 1:Guia Gerada / 2:Erro na Geracao da Guia''');
   --   
   -- CONTRAINTS --  
   pExec_Imed('alter table CSF_OWN.APUR_ISS_SIMPLIFICADA  add constraint APURISSSIMP_EMPRESA_FK         foreign key (EMPRESA_ID)          references CSF_OWN.EMPRESA (ID)');
   --   
   pExec_Imed('alter table CSF_OWN.APUR_ISS_SIMPLIFICADA  add constraint APURISSSIMP_GUIAPGTOIMP01_FK   foreign key (GUIAPGTOIMP_ID_PROP) references CSF_OWN.GUIA_PGTO_IMP (ID)');
   --   
   pExec_Imed('alter table CSF_OWN.APUR_ISS_SIMPLIFICADA  add constraint APURISSSIMP_GUIAPGTOIMP02_FK   foreign key (GUIAPGTOIMP_ID_RET)  references CSF_OWN.GUIA_PGTO_IMP (ID)');
   --   
   pExec_Imed('alter table CSF_OWN.APUR_ISS_SIMPLIFICADA  add constraint APURISSSIMP_DMSITUACAO_CK      check (DM_SITUACAO IN (0,1,2,3,4))');
   --   
   pExec_Imed('alter table CSF_OWN.APUR_ISS_SIMPLIFICADA add constraint APURISSSIMP_DMSITUACAOGUIA_CK   check (DM_SITUACAO_GUIA in (0,1,2))');
   --   
   pExec_Imed('alter table CSF_OWN.APUR_ISS_SIMPLIFICADA add constraint APURISSSIMPLIFICADA_UK unique (EMPRESA_ID, DT_INICIO, DT_FIM)   using index TABLESPACE CSF_INDEX');
   --   
   -- INDEX --
   pExec_Imed('create index APURISSSIMP_EMPRESA_IX        on CSF_OWN.APUR_ISS_SIMPLIFICADA (EMPRESA_ID)           TABLESPACE CSF_INDEX');
   --   
   pExec_Imed('create index APURISSSIMP_GUIAPGTOIMP01_IX  on CSF_OWN.APUR_ISS_SIMPLIFICADA (GUIAPGTOIMP_ID_PROP)  TABLESPACE CSF_INDEX');
   --   
   pExec_Imed('create index APURISSSIMP_GUIAPGTOIMP02_IX  on CSF_OWN.APUR_ISS_SIMPLIFICADA (GUIAPGTOIMP_ID_RET)   TABLESPACE CSF_INDEX');
   --   
   pExec_Imed('create index APURISSSIMP_DMSITUACAOGUIA_IX on CSF_OWN.APUR_ISS_SIMPLIFICADA (DM_SITUACAO_GUIA)     TABLESPACE CSF_INDEX');
   --
   -- SEQUENCE --
   pExec_Imed('
       CREATE SEQUENCE CSF_OWN.APURISSSIMPLIFICADA_SEQ
         INCREMENT BY 1
         START WITH   1
         NOMINVALUE
         NOMAXVALUE
         NOCYCLE
         NOCACHE');
   --   
   pExec_Imed('
      INSERT INTO CSF_OWN.SEQ_TAB ( id
                                  , sequence_name
                                  , table_name
                                  )
                           values ( CSF_OWN.seqtab_seq.nextval
                                  , ''APURISSSIMPLIFICADA_SEQ''
                                  , ''APUR_ISS_SIMPLIFICADA''
                                  )');

   --
   -- DOMINIO: APUR_ISS_SIMPLIFICADA.DM_SITUACAO -------------------------------------------------------------
   --'Situacão: 0-aberta; 1-Calculada; 2-Erro de calculo; 3-Validada; 4-Erro de validação'
   pExec_Imed('
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
               VL,
              DESCR,
              ID)
      VALUES (''APUR_ISS_SIMPLIFICADA.DM_SITUACAO'',
              ''0'',
              ''Aberta'',
              DOMINIO_SEQ.NEXTVAL)');
   --   
   pExec_Imed('
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                     VL,
                                     DESCR,
                                     ID)
                             VALUES (''APUR_ISS_SIMPLIFICADA.DM_SITUACAO'',
                                     ''1'',
                                     ''Calculada'',
                                     DOMINIO_SEQ.NEXTVAL)');
   --   
   pExec_Imed('
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                     VL,
                                     DESCR,
                                     ID)
                             VALUES (''APUR_ISS_SIMPLIFICADA.DM_SITUACAO'',
                                     ''2'',
                                     ''Erro'',
                                     DOMINIO_SEQ.NEXTVAL)');
   --   
   pExec_Imed('
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                     VL,
                                     DESCR,
                                     ID)
                             VALUES (''APUR_ISS_SIMPLIFICADA.DM_SITUACAO'',
                                     ''3'',
                                     ''Validada'',
                                     DOMINIO_SEQ.NEXTVAL)');
   --   
   pExec_Imed('
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                     VL,
                                     DESCR,
                                     ID)
                             VALUES (''APUR_ISS_SIMPLIFICADA.DM_SITUACAO'',
                                     ''4'',
                                     ''Erro de Validação'',
                                     DOMINIO_SEQ.NEXTVAL)');
   --
   -- DOMINIO: APUR_ISS_SIMPLIFICADA.DM_SITUACAO_GUIA ------------------------------------------------------------- 
   pExec_Imed('
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                     VL,
                                     DESCR,
                                     ID)
                             VALUES (''APUR_ISS_SIMPLIFICADA.DM_SITUACAO_GUIA'',
                                     ''0'',
                                     ''Não Gerada'',
                                     DOMINIO_SEQ.NEXTVAL)');
   --   
   pExec_Imed('
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                     VL,
                                     DESCR,
                                     ID)
                             VALUES (''APUR_ISS_SIMPLIFICADA.DM_SITUACAO_GUIA'',
                                     ''1'',
                                     ''Guia Gerada'',
                                     DOMINIO_SEQ.NEXTVAL)');
   --   
   pExec_Imed('
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                     VL,
                                     DESCR,
                                     ID)
                             VALUES (''APUR_ISS_SIMPLIFICADA.DM_SITUACAO_GUIA'',
                                     ''2'',
                                     ''Erro na Geração da Guia'',
                                     DOMINIO_SEQ.NEXTVAL)');
   --
   -- GRANTS --
   pExec_Imed('grant select, insert, update, delete   on CSF_OWN.APUR_ISS_SIMPLIFICADA     to CSF_WORK');
   --   
   pExec_Imed('grant select                           on CSF_OWN.APURISSSIMPLIFICADA_SEQ   to CSF_WORK');
   --   
   commit;
   --
exception
   when others then
      raise_application_error(-20001, 'Erro no script 70422 - Erro: ' || sqlerrm);
end;
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Término Redmine #70422: Criar tabela de apuração de ISS Geral - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine #70422: Criar tabela de apuração de ISS Geral - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
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
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add pessoa_id_sefaz number');
   --
   pExec_Imed('comment on column CSF_OWN.PARAM_DET_GUIA_IMP.PESSOA_ID_SEFAZ    is ''ID relacionado a tabela PESSOA que possui o direito de receber o valor do titulo financeiro ou guia, no caso sera a Receita Federal, Estadual ou Municipal''');
   --
   pExec_Imed('alter table CSF_OWN.PARAM_DET_GUIA_IMP  add constraint PDETGUIAIMP_PESSOAIDSEFAZ_FK  foreign key (PESSOA_ID_SEFAZ)  references CSF_OWN.PESSOA (ID)');
   --
   pExec_Imed('create index PDETGUIAIMP_PESSOAIDSEFAZ_IX  on CSF_OWN.PARAM_DET_GUIA_IMP (PESSOA_ID_SEFAZ)   TABLESPACE CSF_INDEX');
   --
exception 
   when others then
      raise_application_error(-20001, 'Erro no script #65266 - Erro: ' || sqlerrm);
end;
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Término Redmine #65266: Especificacao funcional - Tabela PARAM_DET_GUIA_IMP - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine #68773: Estrutura de tabelas e procedures - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
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
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add aberturaefdpc_id number');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.aberturaefdpc_id is ''ID da abertura_efd_pc caso seja gerado pela tela de Geração do EFD Pis/Cofins''');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP  add constraint GUIAPGTOIMP_ABERTURAEFDPC_FK foreign key (ABERTURAEFDPC_ID) references CSF_OWN.ABERTURA_EFD_PC (ID)');
   --
   pExec_Imed('create index GUIAPGTOIMP_ABERTURAEFDPC_IX on CSF_OWN.GUIA_PGTO_IMP (aberturaefdpc_id) tablespace CSF_INDEX');
   --
exception 
   when others then
      raise_application_error(-20001, 'Erro no script #68773 - Erro: ' || sqlerrm);
end;
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Término Redmine #68773: Estrutura de tabelas e procedures - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine #70669: Ajuste em tabelas de apuração - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
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
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add apuracaoicmsst_id number');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.apuracaoicmsst_id  is ''ID da tabela APURACAO_ICMS_ST gerada pela tela de Apuração do ICMS''');
   --
   pExec_Imed('create index GUIAPGTOIMP_APURACAOICMSST_IX on CSF_OWN.GUIA_PGTO_IMP (apuracaoicmsst_id) tablespace CSF_INDEX');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add constraint GUIAPGTOIMP_APURACAOICMSST_FK foreign key (APURACAOICMSST_ID) references CSF_OWN.APURACAO_ICMS_ST (ID)');
   --
exception 
   when others then
      raise_application_error(-20001, 'Erro no script #70669 - Erro: ' || sqlerrm);
end;
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Término Redmine #70669: Ajuste em tabelas de apuração - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine #70902: Geração de guia pela apuração de ICMS-DIFAL - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
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
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add apuricmsdifal_id number');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.apuricmsdifal_id is ''ID da tabela APUR_ICMS_DIFAL gerada pela tela de Apuração do ICMS DIFAL''');
   --
   pExec_Imed('create index GUIAPGTOIMP_APURICMSDIFAL_IX on CSF_OWN.GUIA_PGTO_IMP (apuricmsdifal_id) tablespace CSF_INDEX');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add constraint GUIAPGTOIMP_APURICMSDIFAL_FK foreign key (APURICMSDIFAL_ID)  references CSF_OWN.APUR_ICMS_DIFAL (ID)');
   --
exception 
   when others then
      raise_application_error(-20001, 'Erro no script #70902 - Erro: ' || sqlerrm);
end;
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Término Redmine #70902: Geração de guia pela apuração de ICMS-DIFAL - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine #72646: Geração de guia a partir de apuração de IR e CSLL - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
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
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add aberturaecf_id number');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.aberturaecf_id is ''ID da tabela ABERTURA_ECF caso seja gerado pela tela de Geração do ECF''');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP  add constraint GUIAPGTOIMP_ABERTURAECF_FK foreign key (ABERTURAECF_ID) references CSF_OWN.ABERTURA_ECF (ID)');
   --
   pExec_Imed('create index GUIAPGTOIMP_ABERTURAECF_IX on CSF_OWN.GUIA_PGTO_IMP (aberturaecf_id) tablespace CSF_INDEX');
   --
exception 
   when others then
      raise_application_error(-20001, 'Erro no script #72646 - Erro: ' || sqlerrm);
end;
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Término Redmine #72646: Geração de guia a partir de apuração de IR e CSLL - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine Melhoria #73443: Inclusão de colunas cidade_id e planoconta_id nas tabelas de guia - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
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
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add planoconta_id number');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.planoconta_id is ''ID relacionado com a tabela PLANO_CONTA''');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add constraint GUIAPGTOIMP_PLANOCONTA_FK foreign key (PLANOCONTA_ID) references CSF_OWN.PLANO_CONTA (id)');
   --
   pExec_Imed('create index GUIAPGTOIMP_PLANOCONTA_IX on CSF_OWN.GUIA_PGTO_IMP (PLANOCONTA_ID) tablespace CSF_INDEX');
   --
exception 
   when others then
      raise_application_error(-20001, 'Erro no script #73443 - Erro: ' || sqlerrm);
end;
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Término Redmine Melhoria #73443: Inclusão de colunas cidade_id e planoconta_id nas tabelas de guia - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine #72795: Geração de guia a partir de retenção de INSS em documento fiscal - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
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
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add gerguiapgtoimp_id number');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.gerguiapgtoimp_id is ''ID relacionado com a tabela GER_GUIA_PGTO_IMP''');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add constraint GUIAPGTOIMP_GERGUIAPGTOIMP_FK foreign key (gerguiapgtoimp_id) references CSF_OWN.GER_GUIA_PGTO_IMP (id)');
   --
   pExec_Imed('create index GUIAPGTOIMP_GERGUIAPGTOIMP_IX on CSF_OWN.GUIA_PGTO_IMP (gerguiapgtoimp_id) tablespace CSF_INDEX');
   --
   --
exception 
   when others then
      raise_application_error(-20001, 'Erro no script #72795 - Erro: ' || sqlerrm);
end;
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Término Redmine #72795: Geração de guia a partir de retenção de INSS em documento fiscal - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine #73506: Detalhamento de ISS por municipio - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
--------------------------------------------------------------------------------------------------------------------------------------
declare
   vn_existe_tab number := null;
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
   select count(*)
     into vn_existe_tab
     from SYS.ALL_TABLES a
    where upper(a.OWNER)       = upper('CSF_OWN')
      and upper(a.TABLE_NAME)  = upper('APUR_ISS_OUT_MUN ');
   --
   if nvl(vn_existe_tab,0) = 0 then
      --
      pExec_Imed('CREATE TABLE CSF_OWN.APUR_ISS_OUT_MUN (
         ID                      NUMBER        NOT NULL,
         APURISSSIMPLIFICADA_ID  NUMBER        NOT NULL,
         CIDADE_ID               NUMBER        NOT NULL,
         VL_ISS_RETIDO           NUMBER(15,2)      NULL,
         GUIAPGTOIMP_ID          NUMBER            NULL,
         CONSTRAINT APURISSOUTMUN_PK PRIMARY KEY(ID) USING INDEX TABLESPACE CSF_INDEX
         ) TABLESPACE CSF_DATA');
      --
   end if;
   --
   -- COMMENTS --
   pExec_Imed('comment on table CSF_OWN.APUR_ISS_OUT_MUN                         is ''Apuração de ISS devido a outros municipios''');
   --
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_OUT_MUN.id                     is ''Sequencial da tabela APURISSOUTMUN_SEQ''');
   --
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_OUT_MUN.apurisssimplificada_id is ''Id relacionado a tabela APUR_ISS_SIMPLIFICADA - Relacionado a apuração de ISS simplificada''');
   --
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_OUT_MUN.cidade_id              is ''Id relacionado a tabela CIDADE - Cidade onde o ISS é devido''');
   --
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_OUT_MUN.vl_iss_retido          is ''Valor do ISS Retido''');
   --
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_OUT_MUN.guiapgtoimp_id         is ''Id Relacionado a tabela GUIA_PGTO_IMP - Identificador da guia de ISS Proprio e relacionado a guia de pagamento''');
   --
   -- CONTRAINTS --
   pExec_Imed('alter table CSF_OWN.APUR_ISS_OUT_MUN add constraint APURISSOUTMUN_APURISSSIMPL_FK foreign key (APURISSSIMPLIFICADA_ID) references CSF_OWN.APUR_ISS_SIMPLIFICADA (ID)');
   --
   pExec_Imed('alter table CSF_OWN.APUR_ISS_OUT_MUN add constraint APURISSOUTMUN_CIDADE_FK       foreign key (CIDADE_ID)              references CSF_OWN.CIDADE (ID)');   
   --
   pExec_Imed('alter table CSF_OWN.APUR_ISS_OUT_MUN add constraint APURISSOUTMUN_GUIAPGTOIMP_FK  foreign key (GUIAPGTOIMP_ID)         references CSF_OWN.GUIA_PGTO_IMP (ID)');
   --
   pExec_Imed('alter table CSF_OWN.APUR_ISS_OUT_MUN add constraint APURISSOUTMUN_UK unique (APURISSSIMPLIFICADA_ID, CIDADE_ID)');
   --
   -- INDEX --
   pExec_Imed('create index APURISSOUTMUN_APURISSSIMPL_IX on CSF_OWN.APUR_ISS_OUT_MUN (APURISSSIMPLIFICADA_ID) tablespace CSF_INDEX');
   --
   pExec_Imed('create index APURISSOUTMUN_CIDADE_IX       on CSF_OWN.APUR_ISS_OUT_MUN (CIDADE_ID)              tablespace CSF_INDEX');
   --
   pExec_Imed('create index APURISSOUTMUN_GUIAPGTOIMP_IX  on CSF_OWN.APUR_ISS_OUT_MUN (GUIAPGTOIMP_ID)         tablespace CSF_INDEX');
   --
   -- SEQUENCE --
   pExec_Imed('
      CREATE SEQUENCE CSF_OWN.APURISSOUTMUN_SEQ
      INCREMENT BY 1
      START WITH   1
      NOMINVALUE
      NOMAXVALUE
      NOCYCLE
      NOCACHE');
   --
   pExec_Imed('
      INSERT INTO CSF_OWN.SEQ_TAB ( id
                                  , sequence_name
                                  , table_name
                                  )
                           values ( CSF_OWN.seqtab_seq.nextval
                                  , ''APURISSOUTMUN_SEQ''
                                  , ''APUR_ISS_OUT_MUN''
                                  )');   
   --
   commit;
   --
   --GRANTS --
   pExec_Imed('grant select, insert, update, delete on CSF_OWN.APUR_ISS_OUT_MUN to CSF_WORK');
   --
   pExec_Imed('grant select on CSF_OWN.APURISSOUTMUN_SEQ to CSF_WORK');
   --
   -- Criar coluna VL_ISS_RET_OUT_MUN na tabela APUR_ISS_SIMPLIFICADA com a descrição "Valor Total de ISS Retido devido a outros municipios".
   pExec_Imed('alter table CSF_OWN.APUR_ISS_SIMPLIFICADA add vl_iss_ret_out_mun number(15,2)');
   --
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.vl_iss_ret_out_mun  is ''Valor Total de ISS Retido devido a outros municipios''');
   --
   -- Criação de coluna de relacionamento com a GUIA_PGTO_IMP
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add apurissoutmun_id number');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.apurissoutmun_id  is ''ID relacionado com a tabela APUR_ISS_OUT_MUN''');
   --
   pExec_Imed('create index GUIAPGTOIMP_APURISSOUTMUN_IX on CSF_OWN.GUIA_PGTO_IMP (apurissoutmun_id) tablespace CSF_INDEX');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add constraint GUIAPGTOIMP_APURISSOUTMUN_FK foreign key (apurissoutmun_id)  references CSF_OWN.APUR_ISS_OUT_MUN (id)');
   --
exception 
   when others then
      raise_application_error(-20001, 'Erro no script #73506. Criacao da tabela APUR_ISS_OUT_MUN. Erro: ' || sqlerrm);
end;
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Término Redmine #73506: Detalhamento de ISS por municipio - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine #73509: Parametro LIBERA_AUTOM_GUIA_ERP - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
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
      where ms.cod_modulo = 'GUIA_PGTO';
   exception
      when no_data_found then
         vn_modulo_id := 0;
      when others then
         null;
         goto SAIR_SCRIPT;   
   end;
   --
   if vn_modulo_id = 0 then
      --
      begin
         insert into CSF_OWN.MODULO_SISTEMA
         values(CSF_OWN.MODULOSISTEMA_SEQ.NEXTVAL, 'GUIA_PGTO', 'Módulo de gestão de Guias de Pagamentos', 'Módulo que será responsável por gerenciar e retornar ao ERP guias de pagamentos de tributos após apuração ou digitação')
         returning id into vn_modulo_id;
      exception
         when others then
            null;
      end;            
      --
   end if;
   --
   -- GRUPO DO SISTEMA --
   begin
      select gs.id
        into vn_grupo_id
      from CSF_OWN.GRUPO_SISTEMA gs
      where gs.modulo_id = vn_modulo_id
        and gs.cod_grupo = 'RET_ERP';
   exception
      when no_data_found then
         vn_grupo_id := 0;
      when others then
         null;
         goto SAIR_SCRIPT;   
   end;
   --
   if vn_grupo_id = 0 then
      --
      begin
         insert into CSF_OWN.GRUPO_SISTEMA
         values(CSF_OWN.GRUPOSISTEMA_SEQ.NextVal, vn_modulo_id, 'RET_ERP', 'Grupo de parametros relacionados ao retorno que guia para ERP', 'Grupo de parametros relacionados ao retorno que guia para ERP')
         returning id into vn_grupo_id;
      exception
         when others then
            null;
      end;          
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
           and pgs.param_name = 'LIBERA_AUTOM_GUIA_ERP';
      exception
         when no_data_found then
            vn_param_id := 0;
         when others then
            null;
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
                     null;
                     goto SAIR_SCRIPT;
               end;
         end;
         --
         begin
            insert into CSF_OWN.PARAM_GERAL_SISTEMA(id, 
                                                    multorg_id, 
                                                    empresa_id, 
                                                    modulo_id, 
                                                    grupo_id, 
                                                    param_name, 
                                                    dsc_param, 
                                                    vlr_param, 
                                                    usuario_id_alt, 
                                                    dt_alteracao
                                                 )
            values( CSF_OWN.PARAMGERALSISTEMA_SEQ.NextVal
                  , x.id
                  , null
                  , vn_modulo_id
                  , vn_grupo_id
                  , 'LIBERA_AUTOM_GUIA_ERP'
                  , 'Indica se irá haver liberação automatica de retorno ao ERP assim que a guia for criada. Ao ativar o parametro, o campo GUIA_PGTO_IMP.DM_RET_ERP é criado com valor 0-Nao retornado, caso esteja desativado, o campo citado é criado como 6-Aguardando liberação e só será alterado com ação do usuário. Valores possiveis: 0=Não / 1=Sim.'
                  , '1'
                  , vn_usuario_id
                  , sysdate);
         exception
            when others then
         end;   
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
   -- Dominio GUIA_PGTO_IMP.DM_RET_ERP
   pk_csf.pkb_cria_dominio('GUIA_PGTO_IMP.DM_RET_ERP','0','Nao retornado');
   pk_csf.pkb_cria_dominio('GUIA_PGTO_IMP.DM_RET_ERP','1','Retornado ao ERP');
   pk_csf.pkb_cria_dominio('GUIA_PGTO_IMP.DM_RET_ERP','2','Gerado titulo ERP');
   pk_csf.pkb_cria_dominio('GUIA_PGTO_IMP.DM_RET_ERP','3','Falha ao gerar titulo ERP');
   pk_csf.pkb_cria_dominio('GUIA_PGTO_IMP.DM_RET_ERP','4','Titulo cancelado ERP');
   pk_csf.pkb_cria_dominio('GUIA_PGTO_IMP.DM_RET_ERP','5','Erro ao cancelar titulo ERP');
   pk_csf.pkb_cria_dominio('GUIA_PGTO_IMP.DM_RET_ERP','6','Aguardando liberação');   
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.dm_ret_erp is ''Indicador de retorno de registro para o ERP: 0-Nao retornado; 1-Retornado ao ERP; 2-Gerado titulo ERP; 3-Falha ao gerar titulo ERP; 4-Titulo cancelado ERP; 5-Erro ao cancelar titulo ERP; 6-Aguardando liberação''');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP drop constraint GUIAPGTOIMP_DMRETERP_CK');
   --   
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add constraint GUIAPGTOIMP_DMRETERP_CK check (DM_RET_ERP in (1,2,3,4,5,6))');
   --
   commit;
   --
end;   
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Término Redmine #73509: Parametro LIBERA_AUTOM_GUIA_ERP - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
--------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #71565  - Inclusão de registros C180, C185, H030, 1250 e 1255 na geração do Sped Fiscal estado MG - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
-------------------------------------------------------------------------------------------------------------------------------------------
--                       
declare
  --
  vn_existe number := null;
  vn_fase number := 0;
  --
begin
  --
  begin
    select count(0)
      into vn_existe
      from all_objects a
     where upper(a.owner)       = 'CSF_OWN'
       and upper(a.object_name) = 'COD_MOT_REST_COMPL_ST';
  exception
    when others then
      vn_existe := 0;
  end;
  --
  if nvl(vn_existe, 0) = 0 then
    --
    begin
      execute immediate 'create table CSF_OWN.COD_MOT_REST_COMPL_ST(ID               NUMBER          not null,
                                                                    ESTADO_ID        NUMBER          not null,
                                                                    COD_AJUR         VARCHAR2(5)     not null,
                                                                    DESCR            VARCHAR2(1000)  not null,
                                                                    DT_INI           DATE,
                                                                    DT_FIM           DATE,
                                                                    VERSAO           NUMBER(4)) tablespace csf_data';
    exception
      when dup_val_on_index then
        raise_application_error(-20001, 'Tabela COD_MOT_REST_COMPL_ST ja existe.');
      when others then
        raise_application_error(-20001, 'Erro no script #70824. Criacao da tabela COD_MOT_REST_COMPL_ST. Erro: ' || sqlerrm);
    end;
    --
    end if;
    --
    begin
      --
      execute immediate 'comment on table CSF_OWN.COD_MOT_REST_COMPL_ST is ''Código de Motivos de Restituição e Complementação ICMS ST (tabela 5.7 do Sped)'' ';
      execute immediate 'comment on column CSF_OWN.COD_MOT_REST_COMPL_ST.ESTADO_ID is ''Relacionado ao ID da tabela ESTADO'' ';
      execute immediate 'comment on column CSF_OWN.COD_MOT_REST_COMPL_ST.COD_AJUR is ''Código do Motivos de Restituição e Complementação ICMS ST, conforme disponibilizado pela UF'' ';
      execute immediate 'comment on column CSF_OWN.COD_MOT_REST_COMPL_ST.DESCR is ''Descrição do Motivo de Restituição e Complementação ICMS ST, conforme disponibilizado pela UF'' ';
      execute immediate 'comment on column CSF_OWN.COD_MOT_REST_COMPL_ST.DT_INI is ''Data de inicio vigência inicial'' ';
      execute immediate 'comment on column CSF_OWN.COD_MOT_REST_COMPL_ST.DT_FIM is ''Data de fim vigência final'' ';
      execute immediate 'comment on column CSF_OWN.COD_MOT_REST_COMPL_ST.VERSAO is ''Versão da tabela do Sped em que codigo foi publicado'' ';
    --
    exception
      when others then
        raise_application_error(-20101, 'Erro no script #70824. Problemas ao criar o comentário da tabela COD_MOT_REST_COMPL_ST. ' || sqlerrm);
    end;
    --    
  -- Create/Recreate primary, unique and foreign key constraints    
  vn_existe := NULL;
   --
   begin
   select count(*)
       into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('COD_MOT_REST_COMPL_ST')
      and upper(ac.CONSTRAINT_NAME)      = upper('CODMOTRESTCSCOMPLST_PK');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   --
   begin 
    execute immediate 'alter table CSF_OWN.COD_MOT_REST_COMPL_ST  add constraint CODMOTRESTCSCOMPLST_PK primary key (ID)';
   exception 
      when others then
        null;
    end; 
   --
   end if;
    --   
    
    
    
   vn_existe := NULL;
   --
   begin
   select count(*)
       into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('COD_MOT_REST_COMPL_ST')
      and upper(ac.INDEX_NAME)      = upper('CODMOTRESTCS_IDX1');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   --
    begin 
    execute immediate 'create index CODMOTRESTCS_IDX1 on CSF_OWN.COD_MOT_REST_COMPL_ST (ESTADO_ID, COD_AJUR, DT_INI, DT_FIM, VERSAO)
  tablespace CSF_INDEX';
   exception 
      when others then
        null;
    end; 
   --
   end if;
    --
   vn_existe := null;
   --
   begin
   select count(*)
       into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('COD_MOT_REST_COMPL_ST')
      and upper(ac.CONSTRAINT_NAME) = upper('CODMOTRESTCS_UK1');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   -- 
     begin
    execute immediate 'alter table CSF_OWN.COD_MOT_REST_COMPL_ST
  add constraint CODMOTRESTCS_UK1 unique (ESTADO_ID, COD_AJUR, DT_INI, DT_FIM, VERSAO)';
   exception 
      when others then
        null;
    end; 
   --
   end if;
   --  
   
   
     --
   vn_existe := null;
   --
   begin
   select count(*)
       into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('COD_MOT_REST_COMPL_ST')
      and upper(ac.CONSTRAINT_NAME) = upper('CODMOTRESTCS_ESTADO_FK');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   -- 
     begin
    execute immediate 'alter table CSF_OWN.COD_MOT_REST_COMPL_ST
  add constraint CODMOTRESTCS_ESTADO_FK foreign key (ESTADO_ID)
  references CSF_OWN.ESTADO(ID)';
   exception 
      when others then
        null;
    end; 
   --
   end if;
   -- 
   --   
  vn_existe := null;
  --
   vn_fase := 14;
   -- Verifica se o sequencial ja¡ existe na tabela
    begin
      select count(*)
         into vn_existe
        from sys.all_sequences sq
    where upper(sq.sequence_owner) = upper('CSF_OWN')
      and upper(sq.sequence_name)  = upper('CODMOTRESTCOMPLST_SEQ');
    exception
      when others then
        vn_existe := 0;
    end;
    --
    vn_fase := 15;
    --
    if nvl(vn_existe,0) = 0 then
      --
      execute immediate 'create sequence CSF_OWN.CODMOTRESTCOMPLST_SEQ minvalue 1 maxvalue 999999999999999999999999999 start with 1 increment by 1 nocache';
      -- 
    vn_fase := 16;
    --
    execute immediate 'GRANT SELECT ON CSF_OWN.CODMOTRESTCOMPLST_SEQ TO CSF_WORK';
    --
        --
    BEGIN
      INSERT INTO CSF_OWN.SEQ_TAB ( id
                                  , sequence_name
                                  , table_name
                                  )
                           values ( CSF_OWN.seqtab_seq.nextval
                                  , 'CODMOTRESTCOMPLST_SEQ'
                                  , 'COD_MOT_REST_COMPL_ST'
                                  );
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX then
         NULL;
   END;
    
  end if;
  
  
     
     
    begin
      execute immediate 'grant select, insert, update, delete on CSF_OWN.COD_MOT_REST_COMPL_ST to csf_work';
    exception
      when others then
        raise_application_error(-20101, 'Erro no script #70824. Problemas no grant para a tabela COD_MOT_REST_COMPL_ST. ' || sqlerrm);
    end;
    --
    commit;
    --
 
  --
end;
/



                                            
declare
  --
  vn_existe number := null;
  vn_fase number := 0;
  --
begin
  --
  begin
    select count(0)
      into vn_existe
      from all_objects a
     where upper(a.owner)       = 'CSF_OWN'
       and upper(a.object_name) = 'NF_INF_COMPL_OPER_ENT_ST';
  exception
    when others then
      vn_existe := 0;
  end;
  --
  if nvl(vn_existe, 0) = 0 then
    --
    begin
      execute immediate 'create table CSF_OWN.NF_INF_COMPL_OPER_ENT_ST(  ID                        NUMBER          not null,
                                                                        ITEMNF_ID                  NUMBER          not null,
                                                                        DM_COD_RESP_RET            NUMBER(1)       not null,
                                                                        QTDE_CONV                  NUMBER(19,6)    not null,
                                                                        UNIDADE_ID                NUMBER          not null,
                                                                        VL_UNIT_CONV              NUMBER(19,6)    not null,
                                                                        VL_UNIT_ICMS_OP_CONV      NUMBER(19,6)    not null,
                                                                        VL_UNIT_BC_ICMS_ST_CONV    NUMBER(19,6)    not null,
                                                                        VL_UNIT_ICMS_ST_CONV      NUMBER(19,6)    not null,
                                                                        VL_UNIT_FCP_ST_CONV        NUMBER(19,6),
                                                                        DM_COD_DA                  VARCHAR2(1),
                                                                        NUM_DA                    VARCHAR2(255)
                                                 ) tablespace csf_data ';
    exception
      when dup_val_on_index then
        raise_application_error(-20001, 'Tabela NF_INF_COMPL_OPER_ENT_ST ja existe.');
      when others then
        raise_application_error(-20001, 'Erro no script #70824. Criacao da tabela NF_INF_COMPL_OPER_ENT_ST. Erro: ' || sqlerrm);
    end;
    --
    end if;
    --
    begin
      --
      execute immediate 'comment on table CSF_OWN.NF_INF_COMPL_OPER_ENT_ST is ''Informações Complementares das Operações de Entrada de Mercadorias Sujeitas à Substituição Tributária - Registro C180'' ';
      execute immediate 'comment on column CSF_OWN.NF_INF_COMPL_OPER_ENT_ST.ITEMNF_ID is ''Relacionado ao ID da tabela ITEM_NOTA_FISCAL'' ';
      execute immediate 'comment on column CSF_OWN.NF_INF_COMPL_OPER_ENT_ST.DM_COD_RESP_RET is ''Código que indica o responsável pela retenção do ICMS ST: 1-Remetente Direto / 2-Remetente Indireto / 3-Próprio declarante'' ';
      execute immediate 'comment on column CSF_OWN.NF_INF_COMPL_OPER_ENT_ST.QTDE_CONV is ''Quantidade do item convertida na unidade de controle de estoque'' ';
      execute immediate 'comment on column CSF_OWN.NF_INF_COMPL_OPER_ENT_ST.UNIDADE_ID is ''ID Relacionado a unidade adotada para informar o campo "QUANT_CONV"'' ';
      execute immediate 'comment on column CSF_OWN.NF_INF_COMPL_OPER_ENT_ST.VL_UNIT_CONV is ''Valor unitário da mercadoria, considerando a unidade utilizada para informar o campo "QUANT_CONV"'' ';
      execute immediate 'comment on column CSF_OWN.NF_INF_COMPL_OPER_ENT_ST.VL_UNIT_ICMS_OP_CONV is ''Valor unitário do ICMS operação própria que o informante teria direito ao crédito caso a mercadoria estivesse sob o regime comum de tributação, considerando unidade utilizada para informar o campo "QUANT_CONV"'' ';
      execute immediate 'comment on column CSF_OWN.NF_INF_COMPL_OPER_ENT_ST.VL_UNIT_BC_ICMS_ST_CONV is ''Valor unitário da base de cálculo do imposto pago ou retido anteriormente por substituição, considerando a unidade utilizada para informar o campo "QUANT_CONV", aplicando-se redução, se houver'' ';
      execute immediate 'comment on column CSF_OWN.NF_INF_COMPL_OPER_ENT_ST.VL_UNIT_ICMS_ST_CONV is ''Valor unitário do imposto pago ou retido anteriormente por substituição, inclusive FCP se devido, considerando a unidade utilizada para informar o campo "QUANT_CONV"'' ';
      execute immediate 'comment on column CSF_OWN.NF_INF_COMPL_OPER_ENT_ST.VL_UNIT_FCP_ST_CONV is ''Valor unitário do FCP_ST agregado ao valor informado no campo VL_UNIT_ICMS_ST_CONV '' ';
      execute immediate 'comment on column CSF_OWN.NF_INF_COMPL_OPER_ENT_ST.DM_COD_DA is ''Código do modelo do documento de arrecadação: 0-Documento estadual de arrecadação / 1-GNRE'' ';
      execute immediate 'comment on column CSF_OWN.NF_INF_COMPL_OPER_ENT_ST.NUM_DA is ''Número do documento de arrecadação estadual, se houver'' ';
      
    --
    exception
      when others then
        raise_application_error(-20101, 'Erro no script #70824. Problemas ao criar o comentário da tabela NF_INF_COMPL_OPER_ENT_ST. ' || sqlerrm);
    end;
    --
    
        -- Create/Recreate primary, unique and foreign key constraints    
  vn_existe := NULL;
   --
   begin
   select count(*)
       into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('NF_INF_COMPL_OPER_ENT_ST')
      and upper(ac.CONSTRAINT_NAME)      = upper('NFINFCOMPLOPERENTST_PK');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   --
    begin 
    execute immediate 'alter table CSF_OWN.NF_INF_COMPL_OPER_ENT_ST
  add constraint NFINFCOMPLOPERENTST_PK primary key (ID)';
   exception 
      when others then
        null;
    end; 
   --
   end if;
    --   
    
    
    
   vn_existe := NULL;
   --
   begin
   select count(*)
       into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('NF_INF_COMPL_OPER_ENT_ST')
      and upper(ac.INDEX_NAME)      = upper('NFINFCOMPLOES_IDX1');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   --
    begin 
    execute immediate 'create index NFINFCOMPLOES_IDX1 on CSF_OWN.NF_INF_COMPL_OPER_ENT_ST (ITEMNF_ID, COD_AJUR, DT_INI, DT_FIM, VERSAO)
  tablespace CSF_INDEX';
   exception 
      when others then
        null;
    end; 
   --
   end if;
    --
   vn_existe := null;
   --
   begin
   select count(*)
       into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('NF_INF_COMPL_OPER_ENT_ST')
      and upper(ac.CONSTRAINT_NAME) = upper('NFINFCOMPLOES_UK1');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   -- 
     begin
    execute immediate 'alter table CSF_OWN.NF_INF_COMPL_OPER_ENT_ST
  add constraint NFINFCOMPLOES_UK1 unique (ITEMNF_ID)';
   exception 
      when others then
        null;
    end; 
   --
   end if;
   --  
   
   
     --
   vn_existe := null;
   --
   begin
   select count(*)
       into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('NF_INF_COMPL_OPER_ENT_ST')
      and upper(ac.CONSTRAINT_NAME) = upper('NFINFCOMPLOES_ITEMNF_FK');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   -- 
     begin
    execute immediate 'alter table CSF_OWN.NF_INF_COMPL_OPER_ENT_ST
  add constraint NFINFCOMPLOES_ITEMNF_FK foreign key (ITEMNF_ID)
  references CSF_OWN.ITEM_NOTA_FISCAL(ID)';
   exception 
      when others then
        null;
    end; 
   --
   end if;
   -- 
  --
   
     vn_existe := NULL;
   --
   begin
   select count(*)
        into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('NF_INF_COMPL_OPER_ENT_ST')
      and upper(ac.CONSTRAINT_NAME)      = upper('NFINFCOMPLOES_CK1');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   --
    begin 
    execute immediate 'alter table CSF_OWN.NF_INF_COMPL_OPER_ENT_ST
  add constraint NFINFCOMPLOES_CK1 check (DM_COD_RESP_RET in ( 1, 2, 3))';
   exception 
      when others then
        null;
    end; 
   --
      begin
         insert into csf_own.dominio ( dominio
                                     , vl
                                     , descr
                                     , id
                                     )
                              values ( 'NF_INF_COMPL_OPER_ENT_ST.DM_COD_RESP_RET'
                                     , '1'
                                     , 'Remetente Direto'
                                     , csf_own.dominio_seq.nextval);
      exception
         when others then
            update csf_own.dominio
               set descr = 'Remetente Direto'
             where dominio = 'NF_INF_COMPL_OPER_ENT_ST.DM_COD_DA'
               and vl = '1';
      end;
      --
      begin
         insert into csf_own.dominio ( dominio
                                     , vl
                                     , descr
                                     , id
                                     )
                              values ( 'NF_INF_COMPL_OPER_ENT_ST.DM_COD_RESP_RET'
                                     , '2'
                                     , 'Remetente Indireto'
                                     , csf_own.dominio_seq.nextval);
      exception
         when others then
            update csf_own.dominio
               set descr = 'Remetente Indireto'
             where dominio = 'NF_INF_COMPL_OPER_ENT_ST.DM_COD_DA'
               and vl = '2';
      end;
      --
      begin
         insert into csf_own.dominio ( dominio
                                     , vl
                                     , descr
                                     , id
                                     )
                              values ( 'NF_INF_COMPL_OPER_ENT_ST.DM_COD_RESP_RET'
                                     , '3'
                                     , 'Próprio declarante'
                                     , csf_own.dominio_seq.nextval);
      exception
         when others then
            update csf_own.dominio
               set descr = 'Próprio declarante'
             where dominio = 'NF_INF_COMPL_OPER_ENT_ST.DM_COD_DA'
               and vl = '3';
      end;
      --
      commit; 
   --
   end if;
   -- 
  --
   
     vn_existe := NULL;
   --
   begin
   select count(*)
        into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('NF_INF_COMPL_OPER_ENT_ST')
      and upper(ac.CONSTRAINT_NAME)      = upper('NFINFCOMPLOES_CK2');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   --
    begin 
    execute immediate 'alter table CSF_OWN.NF_INF_COMPL_OPER_ENT_ST
  add constraint NFINFCOMPLOES_CK2 check (DM_COD_DA in (0, 1))';
   exception 
      when others then
        null;
    end;
   --
     begin
         insert into csf_own.dominio ( dominio
                                     , vl
                                     , descr
                                     , id
                                     )
                              values ( 'NF_INF_COMPL_OPER_ENT_ST.DM_COD_DA'
                                     , '0'
                                     , 'Documento estadual de arrecadação'
                                     , csf_own.dominio_seq.nextval);
      exception
         when others then
            update csf_own.dominio
               set descr = 'Documento estadual de arrecadação'
             where dominio = 'NF_INF_COMPL_OPER_ENT_ST.DM_COD_DA'
               and vl = '0';
      end;
      --
      begin
         insert into csf_own.dominio ( dominio
                                     , vl
                                     , descr
                                     , id
                                     )
                              values ( 'NF_INF_COMPL_OPER_ENT_ST.DM_COD_DA'
                                     , '1'
                                     , 'GNRE'
                                     , csf_own.dominio_seq.nextval);
      exception
         when others then
            update csf_own.dominio
               set descr = 'GNRE'
             where dominio = 'NF_INF_COMPL_OPER_ENT_ST.DM_COD_DA'
               and vl = '1';
      end;
      --
      commit; 
   --
   end if;
   --    
   --   
  vn_existe := null;
  --
   vn_fase := 14;
   -- Verifica se o sequencial ja¡ existe na tabela
    begin
      select count(*)
         into vn_existe
        from sys.all_sequences sq
    where upper(sq.sequence_owner) = upper('CSF_OWN')
      and upper(sq.sequence_name)  = upper('NFINFCOMPLOPERENTST_SEQ');
    exception
      when others then
        vn_existe := 0;
    end;
    --
    vn_fase := 15;
    --
    if nvl(vn_existe,0) = 0 then
      --
      execute immediate 'create sequence CSF_OWN.NFINFCOMPLOPERENTST_SEQ minvalue 1 maxvalue 999999999999999999999999999 start with 1 increment by 1 nocache';
      -- 
    vn_fase := 16;
    --
    execute immediate 'GRANT SELECT ON CSF_OWN.NFINFCOMPLOPERENTST_SEQ TO CSF_WORK';
    --
        --
    BEGIN
      INSERT INTO CSF_OWN.SEQ_TAB ( id
                                  , sequence_name
                                  , table_name
                                  )
                           values ( CSF_OWN.seqtab_seq.nextval
                                  , 'NFINFCOMPLOPERENTST_SEQ'
                                  , 'NF_INF_COMPL_OPER_ENT_ST'
                                  );
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX then
         NULL;
   END;
    
  end if;
  
  
     
     
    begin
      execute immediate 'grant select, insert, update, delete on CSF_OWN.NF_INF_COMPL_OPER_ENT_ST to csf_work';
    exception
      when others then
        raise_application_error(-20101, 'Erro no script #70824. Problemas no grant para a tabela NF_INF_COMPL_OPER_ENT_ST. ' || sqlerrm);
    end;
    --
    commit;
    --
 
  --
end;
/



                                            
declare
  --
  vn_existe number := null;
  vn_fase number := 0;
  --
begin
  --
  begin
    select count(0)
      into vn_existe
      from all_objects a
     where upper(a.owner)       = 'CSF_OWN'
       and upper(a.object_name) = 'NF_INF_COMPL_OPER_SAI_ST';
  exception
    when others then
      vn_existe := 0;
  end;
  --
  if nvl(vn_existe, 0) = 0 then
    --
    begin
      execute immediate 'create table CSF_OWN.NF_INF_COMPL_OPER_SAI_ST( ID                                NUMBER        not null,
                                                                        ITEMNF_ID                         NUMBER        not null,
                                                                        CODMOTRESTCOMPLST_ID              NUMBER        not null,
                                                                        QTDE_CONV                         NUMBER(19,6)  not null,
                                                                        UNIDADE_ID                        NUMBER        not null,
                                                                        VL_UNIT_CONV                      NUMBER(19,6)  not null,
                                                                        VL_UNIT_ICMS_NA_OPERACAO_CONV     NUMBER(19,6),
                                                                        VL_UNIT_ICMS_OP_CONV              NUMBER(19,6),
                                                                        VL_UNIT_ICMS_OP_EST_CONV          NUMBER(19,6),
                                                                        VL_UNIT_ICMS_ST_EST_CONV          NUMBER(19,6),
                                                                        VL_UNIT_FCP_ICMS_ST_EST_CONV	    NUMBER(19,6),
                                                                        VL_UNIT_ICMS_ST_CONV_REST	        NUMBER(19,6),
                                                                        VL_UNIT_FCP_ST_CONV_REST	        NUMBER(19,6),
                                                                        VL_UNIT_ICMS_ST_CONV_COMPL	      NUMBER(19,6),
                                                                        VL_UNIT_FCP_ST_CONV_COMPL	        NUMBER(19,6)  default 0
                                                                    ) tablespace csf_data ';
    exception
      when dup_val_on_index then
        raise_application_error(-20001, 'Tabela NF_INF_COMPL_OPER_SAI_ST ja existe.');
      when others then
        raise_application_error(-20001, 'Erro no script #70824. Criacao da tabela NF_INF_COMPL_OPER_SAI_ST. Erro: ' || sqlerrm);
    end;
    --
    end if;
    --
    begin
      --
      execute immediate 'comment on table CSF_OWN.NF_INF_COMPL_OPER_SAI_ST is ''Informações Complementares das Operações de Saída de Mercadorias Sujeitas à Substituição Tributária - Registro C180'' ';
      execute immediate 'comment on column CSF_OWN.NF_INF_COMPL_OPER_SAI_ST.ITEMNF_ID is ''Relacionado ao ID da tabela ITEM_NOTA_FISCAL'' ';
      execute immediate 'comment on column CSF_OWN.NF_INF_COMPL_OPER_SAI_ST.CODMOTRESTCOMPLST_ID is ''Código do motivo da restituição ou complementação conforme Tabela 5.7, relacionado a tabela COD_MOT_REST_COMPL_ST'' ';
      execute immediate 'comment on column CSF_OWN.NF_INF_COMPL_OPER_SAI_ST.QTDE_CONV is ''Quantidade do item convertida na unidade de controle de estoque'' ';
      execute immediate 'comment on column CSF_OWN.NF_INF_COMPL_OPER_SAI_ST.UNIDADE_ID  is ''ID Relacionado a unidade adotada para informar o campo QUANT_CONV''';
      execute immediate 'comment on column CSF_OWN.NF_INF_COMPL_OPER_SAI_ST.VL_UNIT_CONV   is ''Valor unitário da mercadoria, considerando a unidade utilizada para informar o campo "QUANT_CONV”''';
      execute immediate 'comment on column CSF_OWN.NF_INF_COMPL_OPER_SAI_ST.VL_UNIT_ICMS_NA_OPERACAO_CONV   is ''Valor unitário para o ICMS na operação, caso não houvesse a ST, considerando unidade utilizada para informar o campo "QUANT_CONV”, considerando redução da base de cálculo do ICMS ST na tributação, se houver''';
      execute immediate 'comment on column CSF_OWN.NF_INF_COMPL_OPER_SAI_ST.VL_UNIT_ICMS_OP_CONV   is ''Valor unitário do ICMS OP calculado conforme a legislação de cada UF, considerando a unidade utilizada para informar o campo "QUANT_CONV”, utilizado para cálculo de ressarcimento/restituição de ST, no desfazimento da substituição tributária''';
      execute immediate 'comment on column CSF_OWN.NF_INF_COMPL_OPER_SAI_ST.VL_UNIT_ICMS_OP_EST_CONV  is ''Valor médio unitário do ICMS que o contribuinte teria se creditado referente à operação de entrada das mercadorias em estoque caso estivesse submetida ao regime comum de tributação, calculado conforme a legislação de cada UF, considerando a unidade utilizada para informar o campo "QUANT_CONV”''';
      execute immediate 'comment on column CSF_OWN.NF_INF_COMPL_OPER_SAI_ST.VL_UNIT_ICMS_ST_EST_CONV  is ''Valor médio unitário do ICMS ST, incluindo FCP ST, das mercadorias em estoque, considerando a unidade utilizada para informar o campo "QUANT_CONV”''';
      execute immediate 'comment on column CSF_OWN.NF_INF_COMPL_OPER_SAI_ST.VL_UNIT_FCP_ICMS_ST_EST_CONV  is ''Valor médio unitário do FCP ST agregado ao ICMS das mercadorias em estoque, considerando a unidade utilizada para informar o campo "QUANT_CONV"''';
      execute immediate 'comment on column CSF_OWN.NF_INF_COMPL_OPER_SAI_ST.VL_UNIT_ICMS_ST_CONV_REST  is ''Valor unitário do total do ICMS ST, incluindo FCP ST, a ser restituído/ressarcido, calculado conforme a legislação de cada UF, considerando a unidade utilizada para informar o campo "QUANT_CONV"''';
      execute immediate 'comment on column CSF_OWN.NF_INF_COMPL_OPER_SAI_ST.VL_UNIT_FCP_ST_CONV_REST  is ''Valor unitário correspondente à parcela de ICMS FCP ST que compõe o campo "VL_UNIT_ICMS_ST_CONV_REST", considerando a unidade utilizada para informar o campo "QUANT_CONV"''';
      execute immediate 'comment on column CSF_OWN.NF_INF_COMPL_OPER_SAI_ST.VL_UNIT_ICMS_ST_CONV_COMPL  is ''Valor unitário do complemento do ICMS, incluindo FCP ST, considerando a unidade utilizada para informar o campo "QUANT_CONV"''';
      execute immediate 'comment on column CSF_OWN.NF_INF_COMPL_OPER_SAI_ST.VL_UNIT_FCP_ST_CONV_COMPL  is ''Valor unitário correspondente à parcela de ICMS FCP ST que compõe o campo "VL_UNIT_ICMS_ST_CONV_COMPL", considerando unidade utilizada para informar o campo "QUANT_CONV"''';
      
 
    --
    exception
      when others then
        raise_application_error(-20101, 'Erro no script #70824. Problemas ao criar o comentário da tabela NF_INF_COMPL_OPER_SAI_ST. ' || sqlerrm);
    end;
    --
    
        -- Create/Recreate primary, unique and foreign key constraints    
  vn_existe := NULL;
   --
   begin
   select count(*)
       into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('NF_INF_COMPL_OPER_SAI_ST')
      and upper(ac.CONSTRAINT_NAME)      = upper('NFINFCOMPLOPERENTST_PK');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   --
    begin 
    execute immediate 'alter table CSF_OWN.NF_INF_COMPL_OPER_SAI_ST
  add constraint NFINFCOMPLOPERENTST_PK primary key (ID)';
   exception 
      when others then
        null;
    end; 
   --
   end if;
    --   
    
    
    
   vn_existe := NULL;
   --
   begin
   select count(*)
       into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('NF_INF_COMPL_OPER_SAI_ST')
      and upper(ac.INDEX_NAME)      = upper('NFINFCOMPLOSS_IDX1');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   --
    begin 
    execute immediate 'create index NFINFCOMPLOSS_IDX1 on CSF_OWN.NF_INF_COMPL_OPER_SAI_ST (ITEMNF_ID)
  tablespace CSF_INDEX';
   exception 
      when others then
        null;
    end; 
   --
   end if;
    --
   vn_existe := null;
   --
   begin
   select count(*)
       into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('NF_INF_COMPL_OPER_SAI_ST')
      and upper(ac.CONSTRAINT_NAME) = upper('NFINFCOMPLOSS_UK1');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   -- 
     begin
    execute immediate 'alter table CSF_OWN.NF_INF_COMPL_OPER_SAI_ST
  add constraint NFINFCOMPLOSS_UK1 unique (ITEMNF_ID)';
   exception 
      when others then
        null;
    end; 
   --
   end if;
   --  
   
   
     --
   vn_existe := null;
   --
   begin
   select count(*)
       into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('NF_INF_COMPL_OPER_SAI_ST')
      and upper(ac.CONSTRAINT_NAME) = upper('NFINFCOMPLOSS_ITEMNF_FK');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   -- 
     begin
    execute immediate 'alter table CSF_OWN.NF_INF_COMPL_OPER_SAI_ST
  add constraint NFINFCOMPLOSS_ITEMNF_FK foreign key (ITEMNF_ID)
  references CSF_OWN.ITEM_NOTA_FISCAL(ID)';
   exception 
      when others then
        null;
    end; 
   --
   end if;
   -- 
  --
        --
   vn_existe := null;
   --
   begin
   select count(*)
       into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('NF_INF_COMPL_OPER_SAI_ST')
      and upper(ac.CONSTRAINT_NAME) = upper('NFINFCOMPLOSS_NFICOSS_FK');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   -- 
     begin
    execute immediate 'alter table CSF_OWN.NF_INF_COMPL_OPER_SAI_ST
  add constraint NFINFCOMPLOSS_NFICOSS_FK foreign key (CODMOTRESTCOMPLST_ID)
  references CSF_OWN.COD_MOT_REST_COMPL_ST(ID)';
   exception 
      when others then
        null;
    end; 
   --
   end if;
   -- 
  --
 
   --    
   --   
  vn_existe := null;
  --
   vn_fase := 14;
   -- Verifica se o sequencial ja¡ existe na tabela
    begin
      select count(*)
         into vn_existe
        from sys.all_sequences sq
    where upper(sq.sequence_owner) = upper('CSF_OWN')
      and upper(sq.sequence_name)  = upper('NFINFCOMPLOPERSAIST_SEQ');
    exception
      when others then
        vn_existe := 0;
    end;
    --
    vn_fase := 15;
    --
    if nvl(vn_existe,0) = 0 then
      --
      execute immediate 'create sequence CSF_OWN.NFINFCOMPLOPERSAIST_SEQ minvalue 1 maxvalue 999999999999999999999999999 start with 1 increment by 1 nocache';
      -- 
    vn_fase := 16;
    --
    execute immediate 'GRANT SELECT ON CSF_OWN.NFINFCOMPLOPERSAIST_SEQ TO CSF_WORK';
    --
        --
    BEGIN
      INSERT INTO CSF_OWN.SEQ_TAB ( id
                                  , sequence_name
                                  , table_name
                                  )
                           values ( CSF_OWN.seqtab_seq.nextval
                                  , 'NFINFCOMPLOPERSAIST_SEQ'
                                  , 'NF_INF_COMPL_OPER_SAI_ST'
                                  );
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX then
         NULL;
   END;
    
  end if;
  
  
     
     
    begin
      execute immediate 'grant select, insert, update, delete on CSF_OWN.NF_INF_COMPL_OPER_SAI_ST to csf_work';
    exception
      when others then
        raise_application_error(-20101, 'Erro no script #70824. Problemas no grant para a tabela NF_INF_COMPL_OPER_SAI_ST. ' || sqlerrm);
    end;
    --
    commit;
    --
 
  --
end;
/


                                            


                                            
declare
  --
  vn_existe number := null;
  vn_fase number := 0;
  --
begin
  --
  begin
    select count(0)
      into vn_existe
      from all_objects a
     where upper(a.owner)       = 'CSF_OWN'
       and upper(a.object_name) = 'INVENT_INF_COMP_MERC_ST';
  exception
    when others then
      vn_existe := 0;
  end;
  --
  if nvl(vn_existe, 0) = 0 then
    --
    begin
      execute immediate 'create table CSF_OWN.INVENT_INF_COMP_MERC_ST(  ID               NUMBER       not null,
                                                                        INVENTARIO_ID     NUMBER       not null,
                                                                        VL_ICMS_OP       NUMBER(19,6)  not null,
                                                                        VL_BC_ICMS_ST    NUMBER(19,6)  not null,
                                                                        VL_ICMS_ST       NUMBER(19,6)  not null,
                                                                        VL_FCP           NUMBER(19,6)  not null
                                                                      ) tablespace csf_data ';
    exception
      when dup_val_on_index then
        raise_application_error(-20001, 'Tabela INVENT_INF_COMP_MERC_ST ja existe.');
      when others then
        raise_application_error(-20001, 'Erro no script #70824. Criacao da tabela INVENT_INF_COMP_MERC_ST. Erro: ' || sqlerrm);
    end;
    --
    end if;
    --
    begin
      --
      execute immediate 'comment on table CSF_OWN.INVENT_INF_COMP_MERC_ST is ''Informações Complementares do Inventário das Mercadorias sujeitas ao Regime de Substituição Tributária - Registro H030'' ';
      execute immediate 'comment on column CSF_OWN.INVENT_INF_COMP_MERC_ST.INVENTARIO_ID  is ''Relacionado ao ID da tabela INVENTARIO'' ';
      execute immediate 'comment on column CSF_OWN.INVENT_INF_COMP_MERC_ST.VL_ICMS_OP  is ''Valor médio unitário do ICMS OP a que o informante teria direito ao crédito, pelas entradas, caso esta fosse submetida ao regime comum de tributação.'' '; 
      execute immediate 'comment on column CSF_OWN.INVENT_INF_COMP_MERC_ST.VL_BC_ICMS_ST  is ''Informar o valor médio unitário da base de cálculo ICMS ST pago ou retido, considerando redução de base de cálculo'' '; 
      execute immediate 'comment on column CSF_OWN.INVENT_INF_COMP_MERC_ST.VL_ICMS_ST  is ''Valor médio unitário do ICMS ST'' '; 
      execute immediate 'comment on column CSF_OWN.INVENT_INF_COMP_MERC_ST.VL_FCP  is ''Valor médio unitário do FCP'' ';  
    --
    exception
      when others then
        raise_application_error(-20101, 'Erro no script #70824. Problemas ao criar o comentário da tabela INVENT_INF_COMP_MERC_ST. ' || sqlerrm);
    end;
    --
    
        -- Create/Recreate primary, unique and foreign key constraints    
  vn_existe := NULL;
   --
   begin
   select count(*)
       into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('INVENT_INF_COMP_MERC_ST')
      and upper(ac.CONSTRAINT_NAME)      = upper('INVENTINFCOMPMERCST_PK');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   --
    begin 
    execute immediate 'alter table CSF_OWN.INVENT_INF_COMP_MERC_ST
  add constraint INVENTINFCOMPMERCST_PK primary key (ID)';
   exception 
      when others then
        null;
    end; 
   --
   end if;
    --   
    
    
    
   vn_existe := NULL;
   --
   begin
   select count(*)
       into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('INVENT_INF_COMP_MERC_ST')
      and upper(ac.INDEX_NAME)      = upper('INVENTINFCOMPMST_IDX1');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   --
    begin 
    execute immediate 'create index INVENTINFCOMPMST_IDX1 on CSF_OWN.INVENT_INF_COMP_MERC_ST (INVENTARIO_ID)
  tablespace CSF_INDEX';
   exception 
      when others then
        null;
    end; 
   --
   end if;
    --
   vn_existe := null;
   --
   begin
   select count(*)
       into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('INVENT_INF_COMP_MERC_ST')
      and upper(ac.CONSTRAINT_NAME) = upper('INVENTINFCOMPMST_UK1');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   -- 
     begin
    execute immediate 'alter table CSF_OWN.INVENT_INF_COMP_MERC_ST
  add constraint INVENTINFCOMPMST_UK1 unique (INVENTARIO_ID)';
   exception 
      when others then
        null;
    end; 
   --
   end if;
   --  
   
   
     --
   vn_existe := null;
   --
   begin
   select count(*)
       into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('INVENT_INF_COMP_MERC_ST')
      and upper(ac.CONSTRAINT_NAME) = upper('INVENTINFCOMPMST_INVENT_FK');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   -- 
     begin
    execute immediate 'alter table CSF_OWN.INVENT_INF_COMP_MERC_ST
  add constraint INVENTINFCOMPMST_INVENT_FK foreign key (INVENTARIO_ID)
  references CSF_OWN.INVENTARIO(ID)';
   exception 
      when others then
        null;
    end; 
   --
   end if;
   -- 
  --

 
   --    
   --   
  vn_existe := null;
  --
   vn_fase := 14;
   -- Verifica se o sequencial ja¡ existe na tabela
    begin
      select count(*)
         into vn_existe
        from sys.all_sequences sq
    where upper(sq.sequence_owner) = upper('CSF_OWN')
      and upper(sq.sequence_name)  = upper('INVENTINFCOMPMERCST_SEQ');
    exception
      when others then
        vn_existe := 0;
    end;
    --
    vn_fase := 15;
    --
    if nvl(vn_existe,0) = 0 then
      --
      execute immediate 'create sequence CSF_OWN.INVENTINFCOMPMERCST_SEQ minvalue 1 maxvalue 999999999999999999999999999 start with 1 increment by 1 nocache';
      -- 
    vn_fase := 16;
    --
    execute immediate 'GRANT SELECT ON CSF_OWN.INVENTINFCOMPMERCST_SEQ TO CSF_WORK';
    --
        --
    BEGIN
      INSERT INTO CSF_OWN.SEQ_TAB ( id
                                  , sequence_name
                                  , table_name
                                  )
                           values ( CSF_OWN.seqtab_seq.nextval
                                  , 'INVENTINFCOMPMERCST_SEQ'
                                  , 'INVENT_INF_COMP_MERC_ST'
                                  );
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX then
         NULL;
   END;
    
  end if;
  
  
     
     
    begin
      execute immediate 'grant select, insert, update, delete on CSF_OWN.INVENT_INF_COMP_MERC_ST to csf_work';
    exception
      when others then
        raise_application_error(-20101, 'Erro no script #70824. Problemas no grant para a tabela INVENT_INF_COMP_MERC_ST. ' || sqlerrm);
    end;
    --
    commit;
    --
 
  --
end;
/

 
                                            
declare
  --
  vn_existe number := null;
  vn_fase number := 0;
  --
begin
  --
  begin
    select count(0)
      into vn_existe
      from all_objects a
     where upper(a.owner)       = 'CSF_OWN'
       and upper(a.object_name) = 'SLD_CONS_REST_ICMS_ST';
  exception
    when others then
      vn_existe := 0;
  end;
  --
  if nvl(vn_existe, 0) = 0 then
    --
    begin
      execute immediate 'create table CSF_OWN.SLD_CONS_REST_ICMS_ST(  ID                  NUMBER       not null,
                                                                      EMPRESA_ID          NUMBER       not null,
                                                                      ANO                 NUMBER(4)    not null,
                                                                      MES                 NUMBER(2)    not null,
                                                                      VL_CREDITO_ICMS_OP  NUMBER(15,2) not null,
                                                                      VL_ICMS_ST_REST   	NUMBER(15,2) not null,
                                                                      VL_FCP_ST_REST	    NUMBER(15,2) not null,
                                                                      VL_ICMS_ST_COMPL  	NUMBER(15,2) not null,
                                                                      VL_FCP_ST_COMPL	    NUMBER(15,2) not null,
                                                                      DM_SITUACAO	        NUMBER(1)  default 0   not null
                                                                      ) tablespace csf_data  ';
    exception
      when dup_val_on_index then
        raise_application_error(-20001, 'Tabela SLD_CONS_REST_ICMS_ST ja existe.');
      when others then
        raise_application_error(-20001, 'Erro no script #70824. Criacao da tabela SLD_CONS_REST_ICMS_ST. Erro: ' || sqlerrm);
    end;
    --
    end if;
    --
    begin
      --
      execute immediate 'comment on table CSF_OWN.SLD_CONS_REST_ICMS_ST is ''Informações Consolidadas de Saldos de Restituição, Ressarcimento e Complementação DO ICMS - Registro 1250'' ';
      execute immediate 'comment on column CSF_OWN.SLD_CONS_REST_ICMS_ST.EMPRESA_ID   is ''ID da tabela EMPRESA'' ';
      execute immediate 'comment on column CSF_OWN.SLD_CONS_REST_ICMS_ST.ANO   is ''Ano da consolidação dos saldos de restituição do ICMS ST'' ';
      execute immediate 'comment on column CSF_OWN.SLD_CONS_REST_ICMS_ST.MES   is ''Mês da consolidação dos saldos de restituição do ICMS ST'' ';
      execute immediate 'comment on column CSF_OWN.SLD_CONS_REST_ICMS_ST.VL_CREDITO_ICMS_OP   is ''Informar o valor total do ICMS operação própria que o informante tem direito ao crédito, na forma prevista na legislação, referente às hipóteses de restituição em que há previsão deste crédito.'' ';
      execute immediate 'comment on column CSF_OWN.SLD_CONS_REST_ICMS_ST.VL_ICMS_ST_REST   is ''Informar o valor total do ICMS ST que o informante tem direito ao crédito, na forma prevista na legislação, referente às hipóteses de restituição em que há previsão deste crédito'' ';
      execute immediate 'comment on column CSF_OWN.SLD_CONS_REST_ICMS_ST.VL_FCP_ST_REST   is ''Informar o valor total do FCP_ST agregado ao valor do ICMS ST informado no campo "VL_ICMS_ST_REST".'' ';
      execute immediate 'comment on column CSF_OWN.SLD_CONS_REST_ICMS_ST.VL_ICMS_ST_COMPL   is ''Informar o valor total do débito referente ao complemento do imposto, nos casos previstos na legislação'' ';
      execute immediate 'comment on column CSF_OWN.SLD_CONS_REST_ICMS_ST.VL_FCP_ST_COMPL   is ''Informar o valor total do FCP_ST agregado ao valor informado no campo "VL_ICMS_ST_COMPL"'' ';
      execute immediate 'comment on column CSF_OWN.SLD_CONS_REST_ICMS_ST.DM_SITUACAO   is ''Situação do registro: 0=Não calculado / 1=Calculado / 2=Validado / 3=Erro de validação'' ';
      
  
    --
    exception
      when others then
        raise_application_error(-20101, 'Erro no script #70824. Problemas ao criar o comentário da tabela SLD_CONS_REST_ICMS_ST. ' || sqlerrm);
    end;
    --
    
        -- Create/Recreate primary, unique and foreign key constraints    
  vn_existe := NULL;
   --
   begin
   select count(*)
       into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('SLD_CONS_REST_ICMS_ST')
      and upper(ac.CONSTRAINT_NAME)      = upper('SLDCONSRESTICMSST_PK');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   --
    begin 
    execute immediate 'alter table CSF_OWN.SLD_CONS_REST_ICMS_ST
  add constraint SLDCONSRESTICMSST_PK primary key (ID)';
   exception 
      when others then
        null;
    end; 
   --
   end if;
    --   
    
    
    
   vn_existe := NULL;
   --
   begin
   select count(*)
       into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('SLD_CONS_REST_ICMS_ST')
      and upper(ac.INDEX_NAME)      = upper('SLDCONSRESTIST_IDX1');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   --
    begin 
    execute immediate 'create index SLDCONSRESTICMSST_IDX1 on CSF_OWN.SLD_CONS_REST_ICMS_ST (EMPRESA_ID, ANO, MES)
  tablespace CSF_INDEX';
   exception 
      when others then
        null;
    end; 
   --
   end if;
    --
   vn_existe := null;
   --
   begin
   select count(*)
       into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('SLD_CONS_REST_ICMS_ST')
      and upper(ac.CONSTRAINT_NAME) = upper('SLDCONSRESTICMSST_UK1');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   -- 
     begin
    execute immediate 'alter table CSF_OWN.SLD_CONS_REST_ICMS_ST
  add constraint SLDCONSRESTICMSST_UK1 unique (EMPRESA_ID, ANO, MES)';
   exception 
      when others then
        null;
    end; 
   --
   end if;
   --  
   
   
     --
   vn_existe := null;
   --
   begin
   select count(*)
       into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('SLD_CONS_REST_ICMS_ST')
      and upper(ac.CONSTRAINT_NAME) = upper('SLDCONSRESTICMSST_EMP_FK');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   -- 
     begin
    execute immediate 'alter table CSF_OWN.SLD_CONS_REST_ICMS_ST
  add constraint SLDCONSRESTICMSST_EMP_FK foreign key (EMPRESA_ID)
  references CSF_OWN.EMPRESA(ID)';
   exception 
      when others then
        null;
    end; 
   --
   end if;
   -- 
  --



    vn_existe := NULL;
   --
   begin
   select count(*)
        into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('SLD_CONS_REST_ICMS_ST')
      and upper(ac.CONSTRAINT_NAME)      = upper('SLDCONSRESTICMSST_CK1');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   --
    begin 
    execute immediate 'alter table CSF_OWN.SLD_CONS_REST_ICMS_ST
  add constraint SLDCONSRESTICMSST_CK1 check (DM_SITUACAO in ( 1, 2, 3))';
   exception 
      when others then
        null;
    end; 
   --
      begin
         insert into csf_own.dominio ( dominio
                                     , vl
                                     , descr
                                     , id
                                     )
                              values ( 'SLD_CONS_REST_ICMS_ST.DM_SITUACAO'
                                     , '0'
                                     , 'Não calculado'
                                     , csf_own.dominio_seq.nextval);
      exception
         when others then
            update csf_own.dominio
               set descr = 'Não calculado'
             where dominio = 'SLD_CONS_REST_ICMS_ST.DM_SITUACAO'
               and vl = '0';
      end;
      --
           begin
         insert into csf_own.dominio ( dominio
                                     , vl
                                     , descr
                                     , id
                                     )
                              values ( 'SLD_CONS_REST_ICMS_ST.DM_SITUACAO'
                                     , '1'
                                     , 'Calculado'
                                     , csf_own.dominio_seq.nextval);
      exception
         when others then
            update csf_own.dominio
               set descr = 'Calculado'
             where dominio = 'SLD_CONS_REST_ICMS_ST.DM_SITUACAO'
               and vl = '1';
      end;
     --
      begin
         insert into csf_own.dominio ( dominio
                                     , vl
                                     , descr
                                     , id
                                     )
                              values ( 'SLD_CONS_REST_ICMS_ST.DM_SITUACAO'
                                     , '2'
                                     , 'Validado'
                                     , csf_own.dominio_seq.nextval);
      exception
         when others then
            update csf_own.dominio
               set descr = 'Validado'
             where dominio = 'SLD_CONS_REST_ICMS_ST.DM_COD_DA'
               and vl = '2';
      end;
      --
      begin
         insert into csf_own.dominio ( dominio
                                     , vl
                                     , descr
                                     , id
                                     )
                              values ( 'SLD_CONS_REST_ICMS_ST.DM_SITUACAO'
                                     , '3'
                                     , 'Erro de validação'
                                     , csf_own.dominio_seq.nextval);
      exception
         when others then
            update csf_own.dominio
               set descr = 'Erro de validação'
             where dominio = 'SLD_CONS_REST_ICMS_ST.DM_SITUACAO'
               and vl = '3';
      end;
      --
      commit; 
   --
   end if;
   -- 
  --








 
   --    
   --   
  vn_existe := null;
  --
   vn_fase := 14;
   -- Verifica se o sequencial ja¡ existe na tabela
    begin
      select count(*)
         into vn_existe
        from sys.all_sequences sq
    where upper(sq.sequence_owner) = upper('CSF_OWN')
      and upper(sq.sequence_name)  = upper('SLDCONSRESTICMSST_SEQ');
    exception
      when others then
        vn_existe := 0;
    end;
    --
    vn_fase := 15;
    --
    if nvl(vn_existe,0) = 0 then
      --
      execute immediate 'create sequence CSF_OWN.SLDCONSRESTICMSST_SEQ minvalue 1 maxvalue 999999999999999999999999999 start with 1 increment by 1 nocache';
      -- 
    vn_fase := 16;
    --
    execute immediate 'GRANT SELECT ON CSF_OWN.SLDCONSRESTICMSST_SEQ TO CSF_WORK';
    --
        --
    BEGIN
      INSERT INTO CSF_OWN.SEQ_TAB ( id
                                  , sequence_name
                                  , table_name
                                  )
                           values ( CSF_OWN.seqtab_seq.nextval
                                  , 'SLDCONSRESTICMSST_SEQ'
                                  , 'SLD_CONS_REST_ICMS_ST'
                                  );
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX then
         NULL;
   END;
    
  end if;
  
  
     
     
    begin
      execute immediate 'grant select, insert, update, delete on CSF_OWN.SLD_CONS_REST_ICMS_ST to csf_work';
    exception
      when others then
        raise_application_error(-20101, 'Erro no script #70824. Problemas no grant para a tabela SLD_CONS_REST_ICMS_ST. ' || sqlerrm);
    end;
    --
    commit;
    --
 
  --
end;
/



                                            


                                            
declare
  --
  vn_existe number := null;
  vn_fase number := 0;
  --
begin
  --
  begin
    select count(0)
      into vn_existe
      from all_objects a
     where upper(a.owner)       = 'CSF_OWN'
       and upper(a.object_name) = 'SLD_CONS_MOT_REST_ICMS_ST';
  exception
    when others then
      vn_existe := 0;
  end;
  --
  if nvl(vn_existe, 0) = 0 then
    --
    begin
      execute immediate 'create table CSF_OWN.SLD_CONS_MOT_REST_ICMS_ST(  ID                      NUMBER        not null,
                                                                          SLDCONSRESTICMSST_ID    NUMBER        not null,
                                                                          CODMOTRESTCOMPLST_ID    NUMBER        not null,
                                                                          VL_CREDITO_ICMS_OP_MOT	NUMBER(15,2)  not null,
                                                                          VL_ICMS_ST_REST_MOT	    NUMBER(15,2)  not null,
                                                                          VL_FCP_ST_REST_MOT	    NUMBER(15,2)  not null,
                                                                          VL_ICMS_ST_COMPL_MOT	  NUMBER(15,2)  not null,
                                                                          VL_FCP_ST_COMPL_MOT	    NUMBER(15,2)  not null
                                                                      ) tablespace csf_data ';
    exception
      when dup_val_on_index then
        raise_application_error(-20001, 'Tabela SLD_CONS_MOT_REST_ICMS_ST ja existe.');
      when others then
        raise_application_error(-20001, 'Erro no script #70824. Criacao da tabela SLD_CONS_MOT_REST_ICMS_ST. Erro: ' || sqlerrm);
    end;
    --
    end if;
    --
    begin
      --
      execute immediate 'comment on table CSF_OWN.SLD_CONS_MOT_REST_ICMS_ST is ''Informações Consolidadas de Saldos de Restituição, Ressarcimento e Complementação DO ICMS por Motivo - Registro 1255'' ';
      execute immediate 'comment on column CSF_OWN.SLD_CONS_MOT_REST_ICMS_ST.SLDCONSRESTICMSST_ID   is ''ID da tabela SLD_CONS_REST_ICMS_ST'' ';
      execute immediate 'comment on column CSF_OWN.SLD_CONS_MOT_REST_ICMS_ST.CODMOTRESTCOMPLST_ID   is ''Código do motivo da restituição ou complementação conforme Tabela 5.7, relacionado a tabela COD_MOT_REST_COMPL_ST'' ';
      execute immediate 'comment on column CSF_OWN.SLD_CONS_MOT_REST_ICMS_ST.VL_CREDITO_ICMS_OP_MOT   is ''Informar o valor total do ICMS operação própria que o informante tem direito ao crédito, na forma prevista na legislação, referente às hipóteses de restituição em quehá previsão deste crédito, para o mesmo "COD_MOT_REST_COMPL"'' ';
      execute immediate 'comment on column CSF_OWN.SLD_CONS_MOT_REST_ICMS_ST.VL_ICMS_ST_REST_MOT   is ''Informar o valor total do ICMS ST que o informante tem direito ao crédito, na forma prevista na legislação, referente às hipóteses de restituição em que há previsão deste crédito, para o mesmo "COD_MOT_REST_COMPL"'' ';
      execute immediate 'comment on column CSF_OWN.SLD_CONS_MOT_REST_ICMS_ST.VL_FCP_ST_REST_MOT   is ''Informar o valor total do FCP_ST agregado ao valor do ICMS ST informado no campo "VL_ICMS_ST_REST_MOT"'' ';
      execute immediate 'comment on column CSF_OWN.SLD_CONS_MOT_REST_ICMS_ST.VL_ICMS_ST_COMPL_MOT   is ''Informar o valor total do débito referente ao complemento do imposto, nos casos previstos na legislação, para o mesmo "COD_MOT_REST_COMPL"'' ';
      execute immediate 'comment on column CSF_OWN.SLD_CONS_MOT_REST_ICMS_ST.VL_FCP_ST_COMPL_MOT   is ''Informar o valor total do FCP_ST agregado ao valor informado no campo "VL_ICMS_ST_COMPL_MOT"'' ';
    --
    exception
      when others then
        raise_application_error(-20101, 'Erro no script #70824. Problemas ao criar o comentário da tabela SLD_CONS_MOT_REST_ICMS_ST. ' || sqlerrm);
    end;
    --
    
        -- Create/Recreate primary, unique and foreign key constraints    
  vn_existe := NULL;
   --
   begin
   select count(*)
       into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('SLD_CONS_MOT_REST_ICMS_ST')
      and upper(ac.CONSTRAINT_NAME)      = upper('SLDCONSMOTRESTICMSST_PK');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   --
    begin 
    execute immediate 'alter table CSF_OWN.SLD_CONS_MOT_REST_ICMS_ST
  add constraint SLDCONSMOTRESTICMSST_PK primary key (ID)';
   exception 
      when others then
        null;
    end; 
   --
   end if;
    --   
    
    
    
   vn_existe := NULL;
   --
   begin
   select count(*)
       into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('SLD_CONS_MOT_REST_ICMS_ST')
      and upper(ac.INDEX_NAME)      = upper('SLDCONSMOTRESTICMSST_IDX1');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   --
    begin 
    execute immediate 'create index SLDCONSMOTRESTICMSST_IDX1 on CSF_OWN.SLD_CONS_MOT_REST_ICMS_ST (SLDCONSRESTICMSST_ID, CODMOTRESTCOMPLST_ID)
  tablespace CSF_INDEX';
   exception 
      when others then
        null;
    end; 
   --
   end if;
    --
   vn_existe := null;
   --
   begin
   select count(*)
       into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('SLD_CONS_MOT_REST_ICMS_ST')
      and upper(ac.CONSTRAINT_NAME) = upper('SLDCONSMOTRESTICMSST_UK1');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   -- 
     begin
    execute immediate 'alter table CSF_OWN.SLD_CONS_MOT_REST_ICMS_ST
  add constraint SLDCONSMOTRESTICMSST_UK1 unique (SLDCONSRESTICMSST_ID, CODMOTRESTCOMPLST_ID)';
   exception 
      when others then
        null;
    end; 
   --
   end if;
   --  
   
   
     --
   vn_existe := null;
   --
   begin
   select count(*)
       into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('SLD_CONS_MOT_REST_ICMS_ST')
      and upper(ac.CONSTRAINT_NAME) = upper('SLDCONSMOTRESTICMSST_SLD_FK1');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   -- 
     begin
    execute immediate 'alter table CSF_OWN.SLD_CONS_MOT_REST_ICMS_ST
  add constraint SLDCONSMOTRESTICMSST_SLD_FK1 foreign key (SLDCONSRESTICMSST_ID)
  references CSF_OWN.SLD_CONS_REST_ICMS_ST(ID)';
   exception 
      when others then
        null;
    end; 
   --
   end if;
   -- 
  --
     --
   vn_existe := null;
   --
   begin
   select count(*)
       into vn_existe
     from   all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('SLD_CONS_MOT_REST_ICMS_ST')
      and upper(ac.CONSTRAINT_NAME) = upper('SLDCONSMOTRESTICMSST_COD_FK2');
       exception
    when others then
      vn_existe := 0;
   end; 
   --
   if nvl(vn_existe,0) = 0 then
   -- 
     begin
    execute immediate 'alter table CSF_OWN.SLD_CONS_MOT_REST_ICMS_ST
  add constraint SLDCONSMOTRESTICMSST_COD_FK2 foreign key (CODMOTRESTCOMPLST_ID)
  references CSF_OWN.COD_MOT_REST_COMPL_ST(ID)';
   exception 
      when others then
        null;
    end; 
   --
   end if;
   -- 
  --
 
   --    
   --   
  vn_existe := null;
  --
   vn_fase := 14;
   -- Verifica se o sequencial ja¡ existe na tabela
    begin
      select count(*)
         into vn_existe
        from sys.all_sequences sq
    where upper(sq.sequence_owner) = upper('CSF_OWN')
      and upper(sq.sequence_name)  = upper('SLDCONSMOTRESTICMS_SEQ');
    exception
      when others then
        vn_existe := 0;
    end;
    --
    vn_fase := 15;
    --
    if nvl(vn_existe,0) = 0 then
      --
      execute immediate 'create sequence CSF_OWN.SLDCONSMOTRESTICMS_SEQ minvalue 1 maxvalue 999999999999999999999999999 start with 1 increment by 1 nocache';
      -- 
    vn_fase := 16;
    --
    execute immediate 'GRANT SELECT ON CSF_OWN.SLDCONSMOTRESTICMS_SEQ TO CSF_WORK';
    --
        --
    BEGIN
      INSERT INTO CSF_OWN.SEQ_TAB ( id
                                  , sequence_name
                                  , table_name
                                  )
                           values ( CSF_OWN.seqtab_seq.nextval
                                  , 'SLDCONSMOTRESTICMS_SEQ'
                                  , 'SLD_CONS_MOT_REST_ICMS_ST'
                                  );
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX then
         NULL;
   END;
    
  end if;
  
  
     
     
    begin
      execute immediate 'grant select, insert, update, delete on CSF_OWN.SLD_CONS_MOT_REST_ICMS_ST to csf_work';
    exception
      when others then
        raise_application_error(-20101, 'Erro no script #70824. Problemas no grant para a tabela SLD_CONS_MOT_REST_ICMS_ST. ' || sqlerrm);
    end;
    --
    commit;
    --
 
  --
end;
/

 
DECLARE
ESTADO_MG number := null;
ESTADO_MS number := null; 
--
BEGIN
--
BEGIN 
SELECT ID INTO ESTADO_MG FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'MG';
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
END;
--
BEGIN
SELECT ID INTO ESTADO_MS FROM CSF_OWN.ESTADO WHERE SIGLA_ESTADO = 'MS';
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
END;

 
 
 
BEGIN 
insert into CSF_OWN.COD_MOT_REST_COMPL_ST (ID, ESTADO_ID, COD_AJUR, DESCR, DT_INI, DT_FIM, VERSAO) 
values (CSF_OWN.CODMOTRESTCOMPLST_SEQ.nextval,ESTADO_MS,'MS000','Não se aplica restituição ou complementação de ICMS/ST','01/01/2020',NULL,1);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
END;
--
BEGIN 
insert into CSF_OWN.COD_MOT_REST_COMPL_ST (ID, ESTADO_ID, COD_AJUR, DESCR, DT_INI, DT_FIM, VERSAO) 
values (CSF_OWN.CODMOTRESTCOMPLST_SEQ.nextval,ESTADO_MS,'MS100','Restituição de ICMS/ST, em razão do valor de saída da mercadoria final ser inferior ao da BC/ST','01/01/2020',NULL,1);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
END;
--
BEGIN 
insert into CSF_OWN.COD_MOT_REST_COMPL_ST (ID, ESTADO_ID, COD_AJUR, DESCR, DT_INI, DT_FIM, VERSAO) 
values (CSF_OWN.CODMOTRESTCOMPLST_SEQ.nextval,ESTADO_MS,'MS200','Restituição de ICMS/ST, em razão da não ocorrência do fato gerador presumido','01/01/2020',NULL,1);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
END;
--
BEGIN 
insert into CSF_OWN.COD_MOT_REST_COMPL_ST (ID, ESTADO_ID, COD_AJUR, DESCR, DT_INI, DT_FIM, VERSAO) 
values (CSF_OWN.CODMOTRESTCOMPLST_SEQ.nextval,ESTADO_MS,'MS201','Restituição de ICMS/ST, em razão da saída interestadual','01012020',NULL,1);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
END;
--
BEGIN 
insert into CSF_OWN.COD_MOT_REST_COMPL_ST (ID, ESTADO_ID, COD_AJUR, DESCR, DT_INI, DT_FIM, VERSAO) 
values (CSF_OWN.CODMOTRESTCOMPLST_SEQ.nextval,ESTADO_MS,'MS300','Complementação de ICMS/ST, em razão do valor de saída da mercadoria a consumidor final ser superior ao da BC/ST','01/01/2020',NULL,1);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
END;


 
--
BEGIN 
insert into CSF_OWN.COD_MOT_REST_COMPL_ST (ID, ESTADO_ID, COD_AJUR, DESCR, DT_INI, DT_FIM, VERSAO) 
values (CSF_OWN.CODMOTRESTCOMPLST_SEQ.nextval,ESTADO_MG,'MG000','Não se aplica restituição ou complementação de ICMS/ST','01012020',NULL,1);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
END;
--
--
BEGIN 
insert into CSF_OWN.COD_MOT_REST_COMPL_ST (ID, ESTADO_ID, COD_AJUR, DESCR, DT_INI, DT_FIM, VERSAO) 
values (CSF_OWN.CODMOTRESTCOMPLST_SEQ.nextval,ESTADO_MG,'MG100','Restituição de ICMS/ST, em razão do valor de saída da mercadoria final ser inferior ao da BC/ST','01/01/2020',NULL,1);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
END;
--
--
BEGIN 
insert into CSF_OWN.COD_MOT_REST_COMPL_ST (ID, ESTADO_ID, COD_AJUR, DESCR, DT_INI, DT_FIM, VERSAO) 
values (CSF_OWN.CODMOTRESTCOMPLST_SEQ.nextval,ESTADO_MG,'MG200','Restituição de ICMS/ST, em razão da não ocorrência do fato gerador presumido','01/01/2020',NULL,1);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
END;
--
--
BEGIN 
insert into CSF_OWN.COD_MOT_REST_COMPL_ST (ID, ESTADO_ID, COD_AJUR, DESCR, DT_INI, DT_FIM, VERSAO) 
values (CSF_OWN.CODMOTRESTCOMPLST_SEQ.nextval,ESTADO_MG,'MG300','Complementação de ICMS/ST, em razão do valor de saída da mercadoria aconsumidor final ser superior ao da BC/ST','01/01/2020',NULL,1);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
END;
--
commit;
--
END;
--

/

DECLARE 
vn_existe number := null;
  --
begin
  --
  begin
    select count(0)
      into vn_existe
      from all_synonyms a
     where upper(a.owner)      = 'CSF_OWN'
       and upper(a.table_name) = 'VW_CSF_NF_INF_COMPL_OP_ENT_ST';
  exception
    when others then
      vn_existe := 0;
  end;
  --
  if nvl(vn_existe, 0) = 0 then
    --
    begin
     execute immediate 'create or replace synonym CSF_OWN.VW_CSF_NF_INF_COMPL_OP_ENT_ST for CSF_INT.VW_CSF_NF_INF_COMPL_OP_ENT_ST';
    exception
      when others then
        raise_application_error(-20101, 'Erro no script #70824. Problemas ao criar synonym para a tabela CSF_OWN.VW_CSF_NF_INF_COMPL_OP_ENT_ST.' || sqlerrm);
    end;
    --
  end if;
  --


   --
  begin
    select count(0)
      into vn_existe
      from all_synonyms a
     where upper(a.owner)      = 'CSF_OWN'
       and upper(a.table_name) = 'VW_CSF_NF_INF_COMPL_OP_SAI_ST';
  exception
    when others then
      vn_existe := 0;
  end;
  --
  if nvl(vn_existe, 0) = 0 then
    --
    begin
    execute immediate 'create or replace synonym CSF_OWN.VW_CSF_NF_INF_COMPL_OP_SAI_ST for CSF_INT.VW_CSF_NF_INF_COMPL_OP_SAI_ST';
    exception
      when others then
        raise_application_error(-20101, 'Erro no script #70824. Problemas ao criar synonym para a tabela CSF_OWN.VW_CSF_NF_INF_COMPL_OP_SAI_ST.' || sqlerrm);
    end;
    --
  end if;
  --
   --
  begin
    select count(0)
      into vn_existe
      from all_synonyms a
     where upper(a.owner)      = 'CSF_OWN'
       and upper(a.table_name) = 'VW_CSF_INVENT_INF_COMP_MERC_ST';
  exception
    when others then
      vn_existe := 0;
  end;
  --
  if nvl(vn_existe, 0) = 0 then
    --
    begin
    execute immediate 'create or replace synonym CSF_OWN.VW_CSF_INVENT_INF_COMP_MERC_ST for CSF_INT.VW_CSF_INVENT_INF_COMP_MERC_ST';
    exception
      when others then
        raise_application_error(-20101, 'Erro no script #70824. Problemas ao criar synonym para a tabela CSF_OWN.VW_CSF_INVENT_INF_COMP_MERC_ST.' || sqlerrm);
    end;
    --
  end if;
  --
 
  --
end;
/
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #71565  - Inclusão de registros C180, C185, H030, 1250 e 1255 na geração do Sped Fiscal estado MG - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
-------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------
Prompt INICIO - Redmine #75609 - Criar FK para campos NF_INF_COMPL_OPER_SAI_ST e NF_INF_COMPL_OPER_ENT_ST.UNIDADE_ID  
-------------------------------------------------------------------------------------------------------------------------------------------
--wendel
DECLARE
  --
  vn_existe NUMBER;
  --
BEGIN  
  -- CRIACAO FK NF_INF_COMPL_OPER_SAI_ST
  vn_existe := null;
  --
  begin
   select count(*)
     into vn_existe
     from all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('NF_INF_COMPL_OPER_SAI_ST')
      and upper(ac.CONSTRAINT_NAME) = upper('NFINFCOMPLOSST_UNIDADE_FK');
  exception
   when others then
      vn_existe := 0;
  end; 
  --
  if nvl(vn_existe,0) = 0 then
  -- 
   begin
      execute immediate 'alter table CSF_OWN.NF_INF_COMPL_OPER_SAI_ST 
                          add constraint NFINFCOMPLOSST_UNIDADE_FK foreign key (UNIDADE_ID) 
                           references CSF_OWN.UNIDADE(ID)';
   exception 
     when others then
       null;
  end; 
  --
  end if;
  --
  -- CRIACAO FK NF_INF_COMPL_OPER_ENT_ST 
  vn_existe  := null;
  --
  begin
   select count(*)
     into vn_existe
     from all_constraints ac
    where upper(ac.OWNER)           = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)      = upper('NF_INF_COMPL_OPER_ENT_ST')
      and upper(ac.CONSTRAINT_NAME) = upper('NFINFCOMPLOEST_UNIDADE_FK');
  exception
   when others then
      vn_existe := 0;
  end; 
  --
  if nvl(vn_existe,0) = 0 then
  -- 
   begin
      execute immediate 'alter table CSF_OWN.NF_INF_COMPL_OPER_ENT_ST 
                          add constraint NFINFCOMPLOEST_UNIDADE_FK foreign key (UNIDADE_ID) 
                           references CSF_OWN.UNIDADE(ID)';
   exception 
     when others then
       null;
  end; 
  --
  end if;
  --
END;
/
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #75609 - Criar FK para campos NF_INF_COMPL_OPER_SAI_ST e NF_INF_COMPL_OPER_ENT_ST.UNIDADE_ID 
-------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #71035 - Integração para nota_fiscal_fisco - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
-------------------------------------------------------------------------------------------------------------------------------
 
declare
  vn_qtde    number;
begin
  begin
     select count(1)
       into vn_qtde
       from all_tables t
      where t.OWNER = 'CSF_OWN'  
        and t.TABLE_NAME = 'NOTA_FISCAL_FISCO';
   exception
      when others then
         vn_qtde := 0;
   end;	
   --   
   if vn_qtde > 0 then
      -- 
      -- Add comments to the table   
      BEGIN
         EXECUTE IMMEDIATE 'comment on table CSF_OWN.NOTA_FISCAL_FISCO is ''Tabela de Documento de Arrecadação Referenciado''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao alterar comentario de NOTA_FISCAL_FISCO - '||SQLERRM );
      END;	  
      -- 
   end if;
   --  
   commit;
   --   
end;
/

declare
  --    
  vn_existe number := null;
  --
begin
  --
  begin
    select count(1)
      into vn_existe
      from all_synonyms a
     where upper(a.owner)      = 'CSF_OWN'
       and upper(a.table_name) = 'VW_CSF_NOTA_FISCAL_FISCO';
  exception
    when others then
      vn_existe := 0;
  end;
  --
  if nvl(vn_existe, 0) = 0 then
    --
    begin
     execute immediate 'create or replace synonym CSF_OWN.VW_CSF_NOTA_FISCAL_FISCO for CSF_INT.VW_CSF_NOTA_FISCAL_FISCO';
    exception
      when others then
        raise_application_error(-20101, 'Erro no script #70824. Problemas ao criar synonym para a tabela CSF_OWN.VW_CSF_NOTA_FISCAL_FISCO.' || sqlerrm);
    end;
    --
  end if;
  --
  commit; 
  --
end;
/

begin
   --
   begin
      insert into csf_own.obj_util_integr ( id
                                          , obj_name
                                          , dm_ativo
                                          )
                                   values ( csf_own.objutilintegr_seq.nextval
                                          , 'VW_CSF_NOTA_FISCAL_FISCO'
                                          , 1
                                          );
   exception
      when others then
         update csf_own.obj_util_integr
            set dm_ativo = 1           
          where obj_name = 'VW_CSF_NOTA_FISCAL_FISCO';
   end;
   --  
   commit;
   --   
end;   
/

--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #71035 - Integração para nota_fiscal_fisco - LIBERADO Release_2.9.7.1, Patch_2.9.6.1 e Patch_2.9.5.4
--------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine 75107_75515
-------------------------------------------------------------------------------------------------------------------------------
declare
   vn_existe number := null;
begin 
   select count(*)
     into vn_existe
     from sys.all_tables 
    where OWNER       = 'CSF_OWN'
      and TABLE_NAME  = 'CONHEC_TRANSP_CCE';
   --
   if nvl(vn_existe,0) = 0 then
      --
      execute immediate 'create table CSF_OWN.CONHEC_TRANSP_CCE (
                                                          id                  NUMBER not null,
                                                          conhectransp_id     NUMBER not null,
                                                          dm_st_integra       NUMBER(1) default 0 not null,
                                                          dm_st_proc          NUMBER(2) default 0 not null,
                                                          id_tag_chave        VARCHAR2(54),
                                                          dt_hr_evento        DATE not null,
                                                          tipoeventosefaz_id  NUMBER,
                                                          correcao            VARCHAR2(1000) not null,
                                                          versao_leiaute      VARCHAR2(20),
                                                          versao_evento       VARCHAR2(20),
                                                          versao_cce          VARCHAR2(20),
                                                          versao_aplic        VARCHAR2(40),
                                                          cod_msg_cab         VARCHAR2(4),
                                                          motivo_resp_cab     VARCHAR2(4000),
                                                          msgwebserv_id_cab   NUMBER,
                                                          cod_msg             VARCHAR2(4),
                                                          motivo_resp         VARCHAR2(4000),
                                                          msgwebserv_id       NUMBER,
                                                          dt_hr_reg_evento    DATE,
                                                          nro_protocolo       NUMBER(15),
                                                          usuario_id          NUMBER,
                                                          xml_envio           BLOB,
                                                          xml_retorno         BLOB,
                                                          xml_proc            BLOB,
                                                          dm_download_xml_sic NUMBER(1) default 0 not null
                                                        )';
      --                                                        
      execute immediate 'comment on table CSF_OWN.CONHEC_TRANSP_CCE is ''Tabela de CC-e vinculada ao conhecimento de transporte''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.conhectransp_id    is ''ID relacionado a tabela CONHEC_TRANSP''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.dm_st_integra      is ''Situação de Integração: 0 - Indefinido, 2 - Integrado via arquivo texto (IN), 7 - Integração por view de banco de dados, 8 - Inserida a resposta do CTe para o ERP, 9 - Atualizada a resposta do CTe para o ERP''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.dm_st_proc         is ''Situação: 0-Não Validado; 1-Validado; 2-Aguardando Envio; 3-Processado; 4-Erro de validação; 5-Rejeitada''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.id_tag_chave       is ''Identificador da TAG a ser assinada, a regra de formação do Id é: ID + tpEvento + chave do CT-e + nSeqEvento''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.dt_hr_evento       is ''Data e hora do evento no formato''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.tipoeventosefaz_id is ''ID relacionado a tabela TIPO_EVENTO_SEFAZ''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.correcao           is ''Correção a ser considerada, texto livre. A correção mais recente substitui as anteriores''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.versao_leiaute     is ''Versão do leiaute do evento''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.versao_evento      is ''Versão do evento''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.versao_cce         is ''Versão da carta de correção''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.versao_aplic       is ''Versão da aplicação que processou o evento''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.cod_msg_cab        is ''Código do status da resposta Cabeçalho''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.motivo_resp_cab    is ''Descrição do status da resposta Cabeçalho''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.msgwebserv_id_cab  is ''ID relacionado a tabela MSG_WEB_SERV para cabeçalho do retorno''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.cod_msg            is ''Código do status da resposta''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.motivo_resp        is ''Descrição do status da resposta''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.msgwebserv_id      is ''ID relacionado a tabela MSG_WEB_SERV''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.dt_hr_reg_evento   is ''Data e hora de registro do evento no formato''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.nro_protocolo      is ''Número do Protocolo do Evento da CC-e''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.usuario_id         is ''ID relacionado a tabela NEO_USUARIO''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.xml_envio          is ''XML de envio da CCe''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.xml_retorno        is ''XML de retorno da CCe''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.xml_proc           is ''XML de processado da CCe''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.dm_download_xml_sic is ''Donwload XML pelo SIC: 0-Não; 1-Sim''';
      --
      execute immediate 'create index CONHECTRANSPCCE_USUARIO_FK_I on CSF_OWN.CONHEC_TRANSP_CCE (USUARIO_ID)       tablespace CSF_INDEX';
      execute immediate 'create index CTCCE_CONHECTRANSP_FK_I      on CSF_OWN.CONHEC_TRANSP_CCE (CONHECTRANSP_ID)       tablespace CSF_INDEX';
      execute immediate 'create index CTCCE_MSGWEBSERV_CAB_FK_I    on CSF_OWN.CONHEC_TRANSP_CCE (MSGWEBSERV_ID_CAB)   tablespace CSF_INDEX';
      execute immediate 'create index CTCCE_MSGWEBSERV_FK_I        on CSF_OWN.CONHEC_TRANSP_CCE (MSGWEBSERV_ID)           tablespace CSF_INDEX';
      execute immediate 'create index CTCCE_TIPOEVENTOSEFAZ_FK_I   on CSF_OWN.CONHEC_TRANSP_CCE (TIPOEVENTOSEFAZ_ID) tablespace CSF_INDEX';
      --
      execute immediate 'alter table CSF_OWN.CONHEC_TRANSP_CCE add constraint CONHECTRANSPCCE_PK         primary key (ID) using index tablespace CSF_INDEX';
      execute immediate 'alter table CSF_OWN.CONHEC_TRANSP_CCE add constraint CONHECTRANSPCCE_USUARIO_FK foreign key (USUARIO_ID)         references CSF_OWN.NEO_USUARIO (ID)';
      execute immediate 'alter table CSF_OWN.CONHEC_TRANSP_CCE add constraint CTCCE_CONHECTRANSP_FK      foreign key (CONHECTRANSP_ID)    references CSF_OWN.CONHEC_TRANSP (ID)';
      execute immediate 'alter table CSF_OWN.CONHEC_TRANSP_CCE add constraint CTCCE_MSGWEBSERV_CAB_FK    foreign key (MSGWEBSERV_ID_CAB)  references CSF_OWN.MSG_WEBSERV (ID)';
      execute immediate 'alter table CSF_OWN.CONHEC_TRANSP_CCE add constraint CTCCE_MSGWEBSERV_FK        foreign key (MSGWEBSERV_ID)      references CSF_OWN.MSG_WEBSERV (ID)';
      execute immediate 'alter table CSF_OWN.CONHEC_TRANSP_CCE add constraint CTCCE_TIPOEVENTOSEFAZ_FK   foreign key (TIPOEVENTOSEFAZ_ID) references CSF_OWN.TIPO_EVENTO_SEFAZ (ID)';
      --
      execute immediate 'alter table CSF_OWN.CONHEC_TRANSP_CCE add constraint CTCCE_DMSTINTEGRA_CK check (dm_st_integra IN (0,2,7,8,9))';
      execute immediate 'alter table CSF_OWN.CONHEC_TRANSP_CCE add constraint CTCCE_STPROC_CK      check (DM_ST_PROC in (0, 1, 2, 3, 4, 5))';
      --
      execute immediate 'grant select, insert, update, delete on CSF_OWN.CONHEC_TRANSP_CCE to CSF_WORK';
      --      
   else
      execute immediate 'comment on table CSF_OWN.CONHEC_TRANSP_CCE is ''Tabela de CC-e vinculada ao conhecimento de transporte''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.conhectransp_id    is ''ID relacionado a tabela CONHEC_TRANSP''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.dm_st_integra      is ''Situação de Integração: 0 - Indefinido, 2 - Integrado via arquivo texto (IN), 7 - Integração por view de banco de dados, 8 - Inserida a resposta do CTe para o ERP, 9 - Atualizada a resposta do CTe para o ERP''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.dm_st_proc         is ''Situação: 0-Não Validado; 1-Validado; 2-Aguardando Envio; 3-Processado; 4-Erro de validação; 5-Rejeitada''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.id_tag_chave       is ''Identificador da TAG a ser assinada, a regra de formação do Id é: ID + tpEvento + chave do CT-e + nSeqEvento''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.dt_hr_evento       is ''Data e hora do evento no formato''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.tipoeventosefaz_id is ''ID relacionado a tabela TIPO_EVENTO_SEFAZ''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.correcao           is ''Correção a ser considerada, texto livre. A correção mais recente substitui as anteriores''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.versao_leiaute     is ''Versão do leiaute do evento''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.versao_evento      is ''Versão do evento''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.versao_cce         is ''Versão da carta de correção''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.versao_aplic       is ''Versão da aplicação que processou o evento''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.cod_msg_cab        is ''Código do status da resposta Cabeçalho''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.motivo_resp_cab    is ''Descrição do status da resposta Cabeçalho''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.msgwebserv_id_cab  is ''ID relacionado a tabela MSG_WEB_SERV para cabeçalho do retorno''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.cod_msg            is ''Código do status da resposta''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.motivo_resp        is ''Descrição do status da resposta''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.msgwebserv_id      is ''ID relacionado a tabela MSG_WEB_SERV''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.dt_hr_reg_evento   is ''Data e hora de registro do evento no formato''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.nro_protocolo      is ''Número do Protocolo do Evento da CC-e''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.usuario_id         is ''ID relacionado a tabela NEO_USUARIO''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.xml_envio          is ''XML de envio da CCe''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.xml_retorno        is ''XML de retorno da CCe''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.xml_proc           is ''XML de processado da CCe''';
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.dm_download_xml_sic is ''Donwload XML pelo SIC: 0-Não; 1-Sim''';
      --
      execute immediate 'grant select, insert, update, delete on CSF_OWN.CONHEC_TRANSP_CCE to CSF_WORK';
      --      
   end if;
   --      
exception
   when others then
      raise_application_error(-20001, 'Erro no script 75107_75515. Criacao da tabela CONHEC_TRANSP_CCE. Erro: ' || sqlerrm);      
end;
/

-- sequence
declare
   vn_existe number := null;
begin 
   select count(*)
     into vn_existe
     from sys.all_sequences s
    where s.SEQUENCE_OWNER = 'CSF_OWN'
      and s.SEQUENCE_NAME  = 'CONHECTRANSPCCE_SEQ';
   --
   if nvl(vn_existe,0) = 0 then
      --
      execute immediate 'create sequence CSF_OWN.CONHECTRANSPCCE_SEQ minvalue 1 maxvalue 9999999999999999999999999999 start with 1 increment by 1 nocache';
      execute immediate 'grant select on CSF_OWN.CONHECTRANSPCCE_SEQ to CSF_WORK';      
      --
   elsif nvl(vn_existe,0) > 0 then
      --
      execute immediate 'grant select on CSF_OWN.CONHECTRANSPCCE_SEQ to CSF_WORK';      
      --
   end if;   
   --
exception
   when others then
      raise_application_error(-20001, 'Erro no script 75107_75515. Criacao da sequence CONHECTRANSPCCE_SEQ. Erro: ' || sqlerrm);      
end;
/

-- Dominio
begin 
   execute immediate 'insert into csf_own.dominio (dominio, vl, descr, id) values (''CONHEC_TRANSP_CCE.DM_ST_INTEGRA'', ''0'' , ''Indefinido'', csf_own.dominio_seq.nextval )';
   commit;
exception
   when dup_val_on_index then
      null;      
   when others then
      raise_application_error(-20001, 'Erro no script 75107_75515. Domínio CONHEC_TRANSP_CCE.DM_ST_INTEGRA e Valor "0". Erro: ' || sqlerrm);      
end;
/

begin 
   execute immediate 'insert into csf_own.dominio (dominio, vl, descr, id) values (''CONHEC_TRANSP_CCE.DM_ST_INTEGRA'', ''2'' , ''Integrado via arquivo texto (IN)'', csf_own.dominio_seq.nextval )';
   commit;
exception
   when dup_val_on_index then
      null;      
   when others then
      raise_application_error(-20001, 'Erro no script 75107_75515. Domínio CONHEC_TRANSP_CCE.DM_ST_INTEGRA e Valor "2". Erro: ' || sqlerrm);      
end;
/

begin 
   execute immediate 'insert into csf_own.dominio (dominio, vl, descr, id) values (''CONHEC_TRANSP_CCE.DM_ST_INTEGRA'', ''7'' , ''Integração por view de banco de dados'', csf_own.dominio_seq.nextval )';
   commit;
exception
   when dup_val_on_index then
      null;      
   when others then
      raise_application_error(-20001, 'Erro no script 75107_75515. Domínio CONHEC_TRANSP_CCE.DM_ST_INTEGRA e Valor "7". Erro: ' || sqlerrm);      
end;
/

begin 
   execute immediate 'insert into csf_own.dominio (dominio, vl, descr, id) values (''CONHEC_TRANSP_CCE.DM_ST_INTEGRA'', ''8'' , ''Inserida a resposta do CTe para o ERP'', csf_own.dominio_seq.nextval )';
   commit;
exception
   when dup_val_on_index then
      null;      
   when others then
      raise_application_error(-20001, 'Erro no script 75107_75515. Domínio CONHEC_TRANSP_CCE.DM_ST_INTEGRA e Valor "8". Erro: ' || sqlerrm);      
end;
/

begin 
   execute immediate 'insert into csf_own.dominio (dominio, vl, descr, id) values (''CONHEC_TRANSP_CCE.DM_ST_INTEGRA'', ''9'' , ''Atualizada a resposta do CTe para o ERP'', csf_own.dominio_seq.nextval )';
   commit;
exception
   when dup_val_on_index then
      null;      
   when others then
      raise_application_error(-20001, 'Erro no script 75107_75515. Domínio CONHEC_TRANSP_CCE.DM_ST_INTEGRA e Valor "9". Erro: ' || sqlerrm);      
end;
/

begin 
   execute immediate 'insert into csf_own.dominio (dominio, vl, descr, id) values (''CONHEC_TRANSP_CCE.DM_ST_PROC'', ''0'' , ''Não Validado'', csf_own.dominio_seq.nextval )';
   commit;
exception
   when dup_val_on_index then
      null;      
   when others then
      raise_application_error(-20001, 'Erro no script 75107_75515. Domínio CONHEC_TRANSP_CCE.DM_ST_PROC e Valor "0". Erro: ' || sqlerrm);      
end;
/

begin 
   execute immediate 'insert into csf_own.dominio (dominio, vl, descr, id) values (''CONHEC_TRANSP_CCE.DM_ST_PROC'', ''1'' , ''Validado'', csf_own.dominio_seq.nextval )';
   commit;
exception
   when dup_val_on_index then
      null;      
   when others then
      raise_application_error(-20001, 'Erro no script 75107_75515. Domínio CONHEC_TRANSP_CCE.DM_ST_PROC e Valor "1". Erro: ' || sqlerrm);      
end;
/

begin 
   execute immediate 'insert into csf_own.dominio (dominio, vl, descr, id) values (''CONHEC_TRANSP_CCE.DM_ST_PROC'', ''2'' , ''Aguardando Envio'', csf_own.dominio_seq.nextval )';
   commit;
exception
   when dup_val_on_index then
      null;      
   when others then
      raise_application_error(-20001, 'Erro no script 75107_75515. Domínio CONHEC_TRANSP_CCE.DM_ST_PROC e Valor "2". Erro: ' || sqlerrm);      
end;
/

begin 
   execute immediate 'insert into csf_own.dominio (dominio, vl, descr, id) values (''CONHEC_TRANSP_CCE.DM_ST_PROC'', ''3'' , ''Processado'', csf_own.dominio_seq.nextval )';
   commit;
exception
   when dup_val_on_index then
      null;      
   when others then
      raise_application_error(-20001, 'Erro no script 75107_75515. Domínio CONHEC_TRANSP_CCE.DM_ST_PROC e Valor "3". Erro: ' || sqlerrm);      
end;
/

begin 
   execute immediate 'insert into csf_own.dominio (dominio, vl, descr, id) values (''CONHEC_TRANSP_CCE.DM_ST_PROC'', ''4'' , ''Erro de validação'', csf_own.dominio_seq.nextval )';
   commit;
exception
   when dup_val_on_index then
      null;      
   when others then
      raise_application_error(-20001, 'Erro no script 75107_75515. Domínio CONHEC_TRANSP_CCE.DM_ST_PROC e Valor "4". Erro: ' || sqlerrm);      
end;
/

begin 
   execute immediate 'insert into csf_own.dominio (dominio, vl, descr, id) values (''CONHEC_TRANSP_CCE.DM_ST_PROC'', ''5'' , ''Rejeitada'', csf_own.dominio_seq.nextval )';
   commit;
exception
   when dup_val_on_index then
      null;      
   when others then
      raise_application_error(-20001, 'Erro no script 75107_75515. Domínio CONHEC_TRANSP_CCE.DM_ST_PROC e Valor "5". Erro: ' || sqlerrm);      
end;
/

-------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine 75107_75515
-------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine 75658 -  Alterar tabela estrut_cte incluindo coluna DM_UTIL_CCE
-------------------------------------------------------------------------------------------------------------------------------
declare
   vn_existe number := null;
begin 
   select count(*)
     into vn_existe
     from sys.all_tab_columns ac 
    where ac.OWNER       = 'CSF_OWN'
      and ac.TABLE_NAME  = 'ESTRUT_CTE'
      and ac.COLUMN_NAME = 'DM_UTIL_CCE';
   --
   if nvl(vn_existe,0) = 0 then
      --
      execute immediate 'alter table CSF_OWN.ESTRUT_CTE add DM_UTIL_CCE NUMBER(1) default 0 not null';
      execute immediate 'comment on column CSF_OWN.ESTRUT_CTE.dm_util_cce is ''Utilizada na carta de correcao eletronica - sendo opções 0=Nao e 1=Sim''';
      execute immediate 'alter table CSF_OWN.ESTRUT_CTE add constraint ESTRUTCTE_UTILCCE_CK check (DM_UTIL_CCE IN (0, 1))';
      --
   elsif nvl(vn_existe,0) > 0 then
      --
      execute immediate 'comment on column CSF_OWN.ESTRUT_CTE.dm_util_cce is ''Utilizada na carta de correcao eletronica - sendo opções 0=Nao e 1=Sim''';
      --
   end if;
   -- 
exception
   when others then
      raise_application_error(-20001, 'Erro no script 75658. Campo DM_UTIL_CCE. Erro: ' || sqlerrm);      
end;
/

-- ======= Domínio ====================================================================================================
begin 
   execute immediate 'insert into csf_own.dominio (dominio, vl, descr, id) values (''ESTRUT_CTE.DM_UTIL_CCE'', ''0'' , ''Nao'', csf_own.dominio_seq.nextval )';
   commit;
exception
   when dup_val_on_index then
      null;      
   when others then
      raise_application_error(-20001, 'Erro no script 75658. Domínio ESTRUT_CTE.DM_UTIL_CCE e Valor "0". Erro: ' || sqlerrm);      
end;
/

--
begin 
   execute immediate 'insert into csf_own.dominio (dominio, vl, descr, id) values (''ESTRUT_CTE.DM_UTIL_CCE'', ''1'' , ''Sim'', csf_own.dominio_seq.nextval )';
   commit;
exception
   when dup_val_on_index then
      null;      
   when others then
      raise_application_error(-20001, 'Erro no script 75658. Domínio ESTRUT_CTE.DM_UTIL_CCE e Valor "1". Erro: ' || sqlerrm);      
end;
/

-- Atualiza o valor do dominio
begin
   update CSF_OWN.estrut_cte t3 
      set t3.dm_util_cce = 1
    where exists ( select t2.id
                     from CSF_OWN.estrut_cte t2 
                    where exists ( select * 
                                     from CSF_OWN.estrut_cte t 
                                    where t.campo = 'ide' 
                                      and t.id    = t2.ar_estrutcte_id )
                      and t2.campo in ('CFOP','natOp','dhEmi','tpImp','tpCTe'
                                      ,'indGlobalizado','cMunEnv','xMunEnv','UFEnv'
                                      ,'modal','tpServ','cMunIni','xMunIni','UFIni'
                                      ,'cMunFim','xMunFim','UFFim','retira','xDetRetira'
                                      ,'indIEToma')
                     and t2.id = t3.id );
   --
   commit;
   --
exception
  when others then
     null;  
end;     
/        

begin
update CSF_OWN.estrut_cte t3 
   set t3.dm_util_cce = 1
 where exists ( select t2.id
                  from CSF_OWN.estrut_cte t2 
                 where exists ( select * 
                                  from CSF_OWN.estrut_cte t 
                                 where t.campo = 'toma4' 
                                   and t.id    = t2.ar_estrutcte_id )
                   and t2.campo in ('xNome','xFant','fone','xLgr'
                                   ,'nro','xCpl','xBairro','cMun'
                                   ,'xMun','CEP','UF','cPais','xPais'
                                   ,'email')
                  and t2.id = t3.id );
   --
   commit;
   --
exception
  when others then
     null;  
end;     
/        
                  
begin
update CSF_OWN.estrut_cte t3 
   set t3.dm_util_cce = 1
 where exists ( select t2.id
                  from CSF_OWN.estrut_cte t2 
                 where exists ( select * 
                                  from CSF_OWN.estrut_cte t 
                                 where t.campo = 'emit' 
                                   and t.id    = t2.ar_estrutcte_id )
                   and t2.campo in ('xNome','xFant','xLgr','nro','xCpl'
                                   ,'xBairro','cMun','xMun','CEP','UF'
                                   ,'fone')
                  and t2.id = t3.id );
   --
   commit;
   --
exception
  when others then
     null;  
end;     
/                           
               
begin
update CSF_OWN.estrut_cte t3 
   set t3.dm_util_cce = 1
 where exists ( select t2.id
                  from CSF_OWN.estrut_cte t2 
                 where exists ( select * 
                                  from CSF_OWN.estrut_cte t 
                                 where t.campo = 'rem' 
                                   and t.id    = t2.ar_estrutcte_id )
                   and t2.campo in ('xNome','xFant','fone','xLgr','nro'
                                   ,'xCpl','xBairro','cMun','xMun','CEP'
                                   ,'UF','cPais','xPais','email')
                  and t2.id = t3.id );
   --
   commit;
   --
exception
  when others then
     null;  
end;     
/                           

begin
update CSF_OWN.estrut_cte t3 
   set t3.dm_util_cce = 1
 where exists ( select t2.id
                  from CSF_OWN.estrut_cte t2 
                 where exists ( select * 
                                  from CSF_OWN.estrut_cte t 
                                 where t.campo = 'dest' 
                                   and t.id    = t2.ar_estrutcte_id )
                   and t2.campo in ('xNome','fone','ISUF','xLgr','nro'
                                   ,'xCpl','xBairro','cMun','xMun','CEP'
                                   ,'UF','cPais','xPais','email')
                  and t2.id = t3.id );
   --
   commit;
   --
exception
  when others then
     null;  
end;     
/   

begin
update CSF_OWN.estrut_cte t3 
   set t3.dm_util_cce = 1
 where exists ( select t2.id
                  from CSF_OWN.estrut_cte t2 
                 where exists ( select * 
                                  from CSF_OWN.estrut_cte t 
                                 where t.campo = 'vPrest' 
                                   and t.id    = t2.ar_estrutcte_id )
                   and t2.campo in ('vRec')
                  and t2.id = t3.id );
   --
   commit;
   --
exception
  when others then
     null;  
end;     
/                  

begin
update CSF_OWN.estrut_cte t3 
   set t3.dm_util_cce = 1
 where exists ( select t2.id
                  from CSF_OWN.estrut_cte t2 
                 where exists ( select * 
                                  from CSF_OWN.estrut_cte t 
                                 where t.campo = 'cobr' 
                                   and t.id    = t2.ar_estrutcte_id )
                   and t2.campo in ('nFat','vOrig','vDesc','vLiq','nDup'
                                   ,'dVenc','vDup')
                  and t2.id = t3.id );
   --
   commit;
   --
exception
  when others then
     null;  
end;     
/ 

begin
update CSF_OWN.estrut_cte t3 
   set t3.dm_util_cce = 1
 where exists ( select t2.id
                  from CSF_OWN.estrut_cte t2 
                 where exists ( select * 
                                  from CSF_OWN.estrut_cte t 
                                 where t.campo = 'duto' 
                                   and t.id    = t2.ar_estrutcte_id )
                   and t2.campo in ('vTar','dIni','dFim')
                  and t2.id = t3.id );
   --
   commit;
   --
exception
  when others then
     null;  
end;     
/                        

-- Criação da view
declare
   vn_existe number := null;
begin 
   select count(*)
     into vn_existe
     from sys.all_views v
    where v.OWNER      = 'CSF_OWN'
      and v.VIEW_NAME  = 'V_ESTRUT_CTE_CCE';
   --
   if nvl(vn_existe,0) = 0 then
      --
      execute immediate 'create or replace view CSF_OWN.v_estrut_cte_cce as select r.ident_linha, r.ar_estrutcte_id id_grupo, g.campo grupo, g.descr descr_grupo, r.id id_registro, r.campo registro, r.descr descr_registro from CSF_OWN.estrut_cte r, CSF_OWN.estrut_cte g where r.ar_estrutcte_id = g.id and r.dm_util_cce = 1 order by r.ident_linha';
      --
   elsif nvl(vn_existe,0) > 0 then
      --
      null;
      --
   end if;
   -- 
exception
   when others then
      raise_application_error(-20001, 'Erro no script 75658. View V_ESTRUT_CTE_CCE. Erro: ' || sqlerrm);      
end;
/

-------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine 75658 -  Alterar tabela estrut_cte incluindo coluna DM_UTIL_CCE
-------------------------------------------------------------------------------------------------------------------------------

     
-------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine 50519  - Criar parametro na empresa para reversão automatica
-------------------------------------------------------------------------------------------------------------------------------
-- ===== param_geral_sistema =================================================================================================
-- Criar Parametro Geral do Sistema por mult_org e empresa
-- Parametros ATUALIZA_DOC_TERC_AUTORIZADO
----------------------------------------------------------------------------------------
declare
   --
   vn_modulo_id       csf_own.modulo_sistema.id%type;
   vn_grupo_id        csf_own.grupo_sistema.id%type := null; 
   vn_usuario_id_alt  csf_own.neo_usuario.id%type; 
   -- 
   cursor c_multorg ( en_multorg_cd csf_own.mult_org.cd%type ) is 
   select m.id multorg_id
        , e.id empresa_id 
     from csf_own.mult_org m
        , csf_own.empresa  e 
    where m.cd          = nvl(en_multorg_cd,m.cd)
      and m.dm_situacao = 1  -- Ativa
      and e.multorg_id  = m.id
      and e.dm_situacao = 1; -- Ativa 
   --
begin
   begin
      -- Módulo => COD_MODULO: INTEGRACAO         
      select t.id
        into vn_modulo_id 
        from csf_own.modulo_sistema t 
       where t.cod_modulo = 'INTEGRACAO';
      --
   exception
      when others then
         vn_modulo_id := null;
   end;
   --
   -- Sera gerado para todas as multorgs
   for rec in c_multorg ( en_multorg_cd => null ) loop 
      exit when c_multorg%notfound or (c_multorg%notfound) is null;
      --
      if nvl(vn_modulo_id,0) > 0 then
         --
         if nvl(vn_grupo_id,0) = 0 then
            -- 
             begin
                -- Grupo => COD_GRUPO: DOC_FISCAL
                -- DSC_GRUPO: "Grupo de parametros referentes ao processo de integração de documentos fiscais"              
                select id
                  into vn_grupo_id
                  from csf_own.grupo_sistema gs
                 where cod_grupo    = 'DOC_FISCAL'
                   and gs.modulo_id = vn_modulo_id;
                --
             exception
                when no_data_found then
                   select csf_own.gruposistema_seq.nextval 
                     into vn_grupo_id
                     from dual;
                when others then
                   vn_grupo_id := null;
             end;
            --              
            begin
               insert into csf_own.grupo_sistema ( id
                                                 , modulo_id
                                                 , cod_grupo
                                                 , dsc_grupo
                                                 , observacao 
                                                 )
                                          values ( vn_grupo_id
                                                 , vn_modulo_id
                                                 , 'DOC_FISCAL'
                                                 , 'Grupo de parametros referentes ao processo de integracao de documentos fiscais'
                                                 , null
                                                 );
            exception
               when dup_val_on_index then
                  update csf_own.grupo_sistema
                     set dsc_grupo = 'Grupo de parametros referentes ao processo de integracao de documentos fiscais'
                   where id = vn_grupo_id;  
            end;
            --
         end if;
         --
         begin
            --
            select n.id usuario_id_alt
              into vn_usuario_id_alt
              from csf_own.neo_usuario n
             where upper(n.login) = upper('ADMIN');
            -- 
         exception
            when others then
                vn_usuario_id_alt := null;
         end;    
         --
         if nvl(vn_modulo_id,0) > 0 and nvl(vn_grupo_id,0) > 0 and nvl(vn_usuario_id_alt,0) > 0 then                                               
            --
            -- Parametro 1
            -- PARAM_NAME: ATUALIZA_DOC_TERC_AUTORIZADO
            -- DSC_PARAM: Indica se ao processar integração deve atualizar dados no documento de terceiro que já se encontra autorizado no 
            --            Compliance. Caso esteja liberado, um determinado documento podera ser alterado inumeras vezes em que for recebido 
            --            por integracao e so nao sera atualizado se estiver dentro do periodo de fechamento fiscal ou se foi enviado na Reinf. 
            --            Valores possíveis: 0: Não permite atualizar / 1: Permite atualizar.
            -- VLR_PARAM: 0
            begin
               insert into csf_own.param_geral_sistema ( id
                                                       , multorg_id
                                                       , empresa_id
                                                       , modulo_id
                                                       , grupo_id
                                                       , param_name
                                                       , dsc_param
                                                       , vlr_param
                                                       , usuario_id_alt
                                                       , dt_alteracao )
                                                values ( csf_own.paramgeralsistema_seq.nextval -- id
                                                       , rec.multorg_id                        -- multorg_id
                                                       , rec.empresa_id                        -- empresa_id
                                                       , vn_modulo_id                          -- modulo_id
                                                       , vn_grupo_id                           -- grupo_id
                                                       , 'ATUALIZA_DOC_TERC_AUTORIZADO'        -- param_name
                                                       , 'Indica se ao processar integracao deve atualizar dados no documento de terceiro que ja se encontra autorizado no Compliance. Caso esteja liberado, um determinado documento podera ser alterado inumeras vezes em que for recebido por integracao e so nao sera atualizado se estiver dentro do periodo de fechamento fiscal ou se foi enviado na Reinf. Valores possiveis: 0: Nao permite atualizar / 1: Permite atualizar.' -- dsc_param
                                                       , '0'                                   -- vlr_param
                                                       , vn_usuario_id_alt                     -- usuario_id_alt (Administrador)
                                                       , sysdate );                            -- dt_alteracao      
               --                                                 
            exception
               when dup_val_on_index then
                  update csf_own.param_geral_sistema
                     set dsc_param = 'Indica se ao processar integracao deve atualizar dados no documento de terceiro que ja se encontra autorizado no Compliance. Caso esteja liberado, um determinado documento podera ser alterado inumeras vezes em que for recebido por integracao e so nao sera atualizado se estiver dentro do periodo de fechamento fiscal ou se foi enviado na Reinf. Valores possiveis: 0: Nao permite atualizar / 1: Permite atualizar.' -- dsc_param
                   where multorg_id = rec.multorg_id
                     and empresa_id = rec.empresa_id
                     and modulo_id  = vn_modulo_id
                     and grupo_id   = vn_grupo_id
                     and param_name = 'ATUALIZA_DOC_TERC_AUTORIZADO';
               when others then 
                  raise_application_error(-20101, 'Erro no script Redmine 50519. ATUALIZA_DOC_TERC_AUTORIZADO: ' || sqlerrm);
            end;
            --
         end if;
         --   
      end if;   
      --
   end loop;
   --
   commit;
   --                                            
exception
   when others then
      rollback;
      raise_application_error(-20101, 'Erro no script Redmine 50519: ' || sqlerrm);
end;
/

-------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine 50519  - Criar parametro na empresa para reversão automatica
-------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine 50520  - Criar modelo de integração de reversão de notas
-------------------------------------------------------------------------------------------------------------------------------
-- ===== NOTA_FISCAL =================================================================================================
declare
   vn_existe number := null;
begin
   select count(*)
     into vn_existe
     from sys.all_tab_columns ac
    where upper(ac.OWNER)       = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)  = upper('NOTA_FISCAL')
      and upper(ac.COLUMN_NAME) = upper('DM_REVERTER_DOC');
   --
   if nvl(vn_existe,0) > 0 then
      --
      null;
      --
   elsif nvl(vn_existe,0) = 0 then
      --
      execute immediate 'alter table CSF_OWN.NOTA_FISCAL add dm_reverter_doc NUMBER(1)';
      execute immediate 'alter table CSF_OWN.TMP_NOTA_FISCAL add dm_reverter_doc NUMBER(1)'; 
      execute immediate 'comment on column CSF_OWN.NOTA_FISCAL.DM_REVERTER_DOC is ''Identifica se o registro e de reversao e o status dele''';
      execute immediate 'alter table CSF_OWN.NOTA_FISCAL add constraint NOTAFISCAL_REVERTERDOC_CK check (DM_REVERTER_DOC IN (0, 1, 2, 3))';
      --
   end if;
   --
exception
   when others then
      raise_application_error(-20001, 'Erro no script 50520. Campo NOTA_FISCAL.DM_REVERTER_DOC. Erro: ' || sqlerrm);
end;
/

-- ======= Domínio ====================================================================================================

begin
   execute immediate 'insert into csf_own.dominio (dominio, vl, descr, id) values (''NOTA_FISCAL.DM_REVERTER_DOC'', ''0'' , ''Sem acao'', csf_own.dominio_seq.nextval )';
   commit;
exception
   when dup_val_on_index then
      null;
   when others then
      raise_application_error(-20001, 'Erro no script 50520. Domínio NOTA_FISCAL.DM_REVERTER_DOC e Valor "0". Erro: ' || sqlerrm);
end;
/

begin
   execute immediate 'insert into csf_own.dominio (dominio, vl, descr, id) values (''NOTA_FISCAL.DM_REVERTER_DOC'', ''1'' , ''Reverter'', csf_own.dominio_seq.nextval )';
   commit;
exception
   when dup_val_on_index then
      null;
   when others then
      raise_application_error(-20001, 'Erro no script 50520. Domínio NOTA_FISCAL.DM_REVERTER_DOC e Valor "1". Erro: ' || sqlerrm);
end;
/

begin
   execute immediate 'insert into csf_own.dominio (dominio, vl, descr, id) values (''NOTA_FISCAL.DM_REVERTER_DOC'', ''2'' , ''Processo de reversao concluido'', csf_own.dominio_seq.nextval )';
   commit;
exception
   when dup_val_on_index then
      null;
   when others then
      raise_application_error(-20001, 'Erro no script 50520. Domínio NOTA_FISCAL.DM_REVERTER_DOC e Valor "2". Erro: ' || sqlerrm);
end;
/

begin
   execute immediate 'insert into csf_own.dominio (dominio, vl, descr, id) values (''NOTA_FISCAL.DM_REVERTER_DOC'', ''3'' , ''Erro no reversao'', csf_own.dominio_seq.nextval )';
   commit;
exception
   when dup_val_on_index then
      null;
   when others then
      raise_application_error(-20001, 'Erro no script 50520. Domínio NOTA_FISCAL.DM_REVERTER_DOC e Valor "3". Erro: ' || sqlerrm);
end;
/

-- ===== CONHEC_TRANSP =================================================================================================
declare
   vn_existe number := null;
begin
   select count(*)
     into vn_existe
     from sys.all_tab_columns ac
    where upper(ac.OWNER)       = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)  = upper('CONHEC_TRANSP')
      and upper(ac.COLUMN_NAME) = upper('DM_REVERTER_DOC');
   --
   if nvl(vn_existe,0) > 0 then
      --
      null;
      --
   elsif nvl(vn_existe,0) = 0 then
      --
      execute immediate 'alter table CSF_OWN.CONHEC_TRANSP add dm_reverter_doc NUMBER(1)';
      execute immediate 'alter table CSF_OWN.TMP_CONHEC_TRANSP add dm_reverter_doc NUMBER(1)';       
      execute immediate 'comment on column CSF_OWN.CONHEC_TRANSP.DM_REVERTER_DOC is ''Identifica se o registro e de reversao e o status dele''';
      execute immediate 'alter table CSF_OWN.CONHEC_TRANSP add constraint CONHECTRANSP_REVERTERDOC_CK check (DM_REVERTER_DOC IN (0, 1, 2, 3))';
      --
   end if;
   --
exception
   when others then
      raise_application_error(-20001, 'Erro no script 50520. Campo CONHEC_TRANSP.DM_REVERTER_DOC. Erro: ' || sqlerrm);
end;
/

-- ======= Domínio ====================================================================================================
begin
   execute immediate 'insert into csf_own.dominio (dominio, vl, descr, id) values (''CONHEC_TRANSP.DM_REVERTER_DOC'', ''0'' , ''Sem acao'', csf_own.dominio_seq.nextval )';
   commit;
exception
   when dup_val_on_index then
      null;
   when others then
      raise_application_error(-20001, 'Erro no script 50520. Domínio CONHEC_TRANSP.DM_REVERTER_DOC e Valor "0". Erro: ' || sqlerrm);
end;
/

begin
   execute immediate 'insert into csf_own.dominio (dominio, vl, descr, id) values (''CONHEC_TRANSP.DM_REVERTER_DOC'', ''1'' , ''Reverter'', csf_own.dominio_seq.nextval )';
   commit;
exception
   when dup_val_on_index then
      null;
   when others then
      raise_application_error(-20001, 'Erro no script 50520. Domínio CONHEC_TRANSP.DM_REVERTER_DOC e Valor "1". Erro: ' || sqlerrm);
end;
/

begin
   execute immediate 'insert into csf_own.dominio (dominio, vl, descr, id) values (''CONHEC_TRANSP.DM_REVERTER_DOC'', ''2'' , ''Processo de reversao concluido'', csf_own.dominio_seq.nextval )';
   commit;
exception
   when dup_val_on_index then
      null;
   when others then
      raise_application_error(-20001, 'Erro no script 50520. Domínio CONHEC_TRANSP.DM_REVERTER_DOC e Valor "2". Erro: ' || sqlerrm);
end;
/

begin
   execute immediate 'insert into csf_own.dominio (dominio, vl, descr, id) values (''CONHEC_TRANSP.DM_REVERTER_DOC'', ''3'' , ''Erro no reversao'', csf_own.dominio_seq.nextval )';
   commit;
exception
   when dup_val_on_index then
      null;
   when others then
      raise_application_error(-20001, 'Erro no script 50520. Domínio CONHEC_TRANSP.DM_REVERTER_DOC e Valor "3". Erro: ' || sqlerrm);
end;
/

-- ======= obj_util_integr ====================================================================================================
declare
   vn_existe number := null;
begin
   select count(*)
     into vn_existe
     from CSF_OWN.obj_util_integr a
    where upper(a.obj_name) = upper('VW_CSF_REVERTER_DOC');
   --
   if nvl(vn_existe,0) = 0 then
      --
      begin
         execute immediate 'insert into csf_own.obj_util_integr ( id, obj_name, dm_ativo ) values ( csf_own.objutilintegr_seq.nextval, ''VW_CSF_REVERTER_DOC'',0)';
         commit;
      exception
        when others then
           rollback;
           raise_application_error(-20001, 'Erro no script 50520. Campo obj_util_integr(INSERT VW_CSF_REVERTER_DOC). Erro: ' || sqlerrm);
      end;
      --
   elsif nvl(vn_existe,0) > 0 then
      --
      null;
      --
   end if;
   --
exception
   when others then
      raise_application_error(-20001, 'Erro no script 50520. Campo obj_util_integr(VW_CSF_REVERTER_DOC). Erro: ' || sqlerrm);
end;
/

-- ======= tipo_obj_integr ====================================================================================================
declare
   vn_id number := null;
begin
   select id
     into vn_id
     from CSF_OWN.obj_integr a
     where a.cd = '4';
   --
   if nvl(vn_id,0) > 0 then
      --
      begin
         insert into csf_own.tipo_obj_integr ( id
                                             , objintegr_id
                                             , cd
                                             , descr
                                             )
                                     values  ( csf_own.tipoobjintegr_seq.nextval -- id
                                             , vn_id                             -- objintegr_id
                                             , '8'                               -- cd
                                             , 'Reversao de Documento dentro do obj 4-Conhec. Transporte' -- descr
                                             );
      exception
         when dup_val_on_index then
            update csf_own.tipo_obj_integr b
               set descr          = 'Reversao de Documento dentro do obj 4-Conhec. Transporte'
             where b.objintegr_id = vn_id
               and b.cd           = '8';
         when others then
            raise_application_error(-20001, 'Erro no script 50520. Campo tipo_obj_integr(cd 8) do objeto 4. Erro: ' || sqlerrm);
      end;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      raise_application_error(-20001, 'Erro no script 50520. Campo tipo_obj_integr. Erro: ' || sqlerrm);
end;
/

declare
   vn_id number := null;
begin
   select id
     into vn_id
     from CSF_OWN.obj_integr a
     where a.cd = '5';
   --
   if nvl(vn_id,0) > 0 then
      --
      begin
         insert into csf_own.tipo_obj_integr ( id
                                             , objintegr_id
                                             , cd
                                             , descr
                                             )
                                     values  ( csf_own.tipoobjintegr_seq.nextval -- id
                                             , vn_id                             -- objintegr_id
                                             , '8'                               -- cd
                                             , 'Reversao de Documento dentro do obj 5-NF de Serv. Contínuos.' -- descr
                                             );
      exception
         when dup_val_on_index then
            update csf_own.tipo_obj_integr b
               set descr          = 'Reversao de Documento dentro do obj 5-NF de Serv. Contínuos.'
             where b.objintegr_id = vn_id
               and b.cd           = '8';
         when others then
            raise_application_error(-20001, 'Erro no script 50520. Campo tipo_obj_integr(cd 8) do objeto 5. Erro: ' || sqlerrm);
      end;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      raise_application_error(-20001, 'Erro no script 50520. Campo tipo_obj_integr. Erro: ' || sqlerrm);
end;
/

declare
   vn_id number := null;
begin
   select id
     into vn_id
     from CSF_OWN.obj_integr a
     where a.cd = '6';
   --
   if nvl(vn_id,0) > 0 then
      --
      begin
         insert into csf_own.tipo_obj_integr ( id
                                             , objintegr_id
                                             , cd
                                             , descr
                                             )
                                     values  ( csf_own.tipoobjintegr_seq.nextval -- id
                                             , vn_id                             -- objintegr_id
                                             , '8'                               -- cd
                                             , 'Reversao de Documento dentro do obj 6-Nota Fiscal mercantil' -- descr
                                             );
      exception
         when dup_val_on_index then
            update csf_own.tipo_obj_integr b
               set descr          = 'Reversao de Documento dentro do obj 6-Nota Fiscal mercantil'
             where b.objintegr_id = vn_id
               and b.cd           = '8';
         when others then
            raise_application_error(-20001, 'Erro no script 50520. Campo tipo_obj_integr(cd 8). Erro: ' || sqlerrm);
      end;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      raise_application_error(-20001, 'Erro no script 50520. Campo tipo_obj_integr. Erro: ' || sqlerrm);
end;
/

declare
   vn_id number := null;
begin
   select id
     into vn_id
     from CSF_OWN.obj_integr a
     where a.cd = '7';
   --
   if nvl(vn_id,0) > 0 then
      --
      begin
         insert into csf_own.tipo_obj_integr ( id
                                             , objintegr_id
                                             , cd
                                             , descr
                                             )
                                     values  ( csf_own.tipoobjintegr_seq.nextval -- id
                                             , vn_id                             -- objintegr_id
                                             , '8'                               -- cd
                                             , 'Reversao de Documento dentro do obj 7-NF Serviços EFD.' -- descr
                                             );
      exception
         when dup_val_on_index then
            update csf_own.tipo_obj_integr b
               set descr          = 'Reversao de Documento dentro do obj 7-NF Serviços EFD.'
             where b.objintegr_id = vn_id
               and b.cd           = '8';
         when others then
            raise_application_error(-20001, 'Erro no script 50520. Campo tipo_obj_integr(cd 8) do objeto 7. Erro: ' || sqlerrm);
      end;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      raise_application_error(-20001, 'Erro no script 50520. Campo tipo_obj_integr. Erro: ' || sqlerrm);
end;
/

-------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine 50520  - Criar modelo de integração de reversão de notas
-------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------
Prompt FIM Patch 2.9.6.1 - Alteracoes no CSF_OWN
------------------------------------------------------------------------------------------
