------------------------------------------------------------------------------------------
Prompt INI Patch 2.9.6.2 - Alteracoes no CSF_OWN
------------------------------------------------------------------------------------------

insert into csf_own.versao_sistema ( ID
                                   , VERSAO
                                   , DT_VERSAO
                                   )
                            values ( csf_own.versaosistema_seq.nextval -- ID
                                   , '2.9.6.2'                         -- VERSAO
                                   , sysdate                           -- DT_VERSAO
                                   )
/

commit
/
-------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #75477 -  Criação de Job Scheduler JOB_CORRIGIR_NF_CT
-------------------------------------------------------------------------------------------------------------------------------

DECLARE 
  vn_cont NUMBER;
BEGIN
  --
  -- Verifica se o Job JOB_CORRIGIR_NF_CT já foi criado, caso existir sai da rotina
  BEGIN
    SELECT COUNT(1)
      INTO vn_cont
      FROM ALL_SCHEDULER_JOBS
     WHERE JOB_NAME = 'JOB_CORRIGIR_NF_CT'
       AND ENABLED  = 'TRUE';
    EXCEPTION
      WHEN OTHERS THEN
        vn_cont := 0;
    END;
    --
    IF vn_cont = 0 THEN
        DBMS_SCHEDULER.CREATE_JOB
            (
              JOB_NAME => 'JOB_CORRIGIR_NF_CT',
              JOB_TYPE => 'STORED_PROCEDURE',
              JOB_ACTION => 'CSF_OWN.PB_CORRIGIR_PESSOA_NF_CT',
              START_DATE => SYSDATE,
              REPEAT_INTERVAL => 'SYSDATE + (((1/24)/60))',
              ENABLED => TRUE,
              COMMENTS => 'POPULA PESSOA_ID NA NF/CT QUANDO ESTIVER NULO.'
            );
     END IF;
EXCEPTION
	WHEN OTHERS THEN
		RAISE_APPLICATION_ERROR(-20101, 'Erro ao criar o Job - JOB_CORRIGIR_NF_CT  : '||sqlerrm);
END;
/
-------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #75477 -  Criação de Job Scheduler JOB_CORRIGIR_NF_CT
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #75898 Criação de padrão NFem a adição de Joinville-SC ao padrão
-------------------------------------------------------------------------------------------------------------------------------------------
--
--CIDADE  : Joinville - SC
--IBGE    : 4209102
--PADRAO  : NFem
--HABIL   : SIM
--WS_CANC : SIM

declare 
   --   
   -- dm_tp_amb (Tipo de Ambiente 1-Producao; 2-Homologacao)
   cursor c_dados is
      select   ( select id from csf_own.cidade where ibge_cidade = '4209102' ) id, dm_situacao,  versao,  dm_tp_amb,  dm_tp_soap,  dm_tp_serv, descr, url_wsdl, dm_upload, dm_ind_emit 
        from ( --Produção
			   select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  1 dm_tp_serv, 'Geração de NFS-e'                               descr, 'https://nfemws.joinville.sc.gov.br/NotaFiscal/Servicos.asmx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  2 dm_tp_serv, 'Recepção e Processamento de lote de RPS'        descr, 'https://nfemws.joinville.sc.gov.br/NotaFiscal/Servicos.asmx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  3 dm_tp_serv, 'Consulta de Situação de lote de RPS'            descr, 'https://nfemws.joinville.sc.gov.br/NotaFiscal/Servicos.asmx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  4 dm_tp_serv, 'Consulta de NFS-e por RPS'                      descr, 'https://nfemws.joinville.sc.gov.br/NotaFiscal/Servicos.asmx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  5 dm_tp_serv, 'Consulta de NFS-e'                              descr, 'https://nfemws.joinville.sc.gov.br/NotaFiscal/Servicos.asmx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  6 dm_tp_serv, 'Cancelamento de NFS-e'                          descr, 'https://nfemws.joinville.sc.gov.br/NotaFiscal/Servicos.asmx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  7 dm_tp_serv, 'Substituição de NFS-e'                          descr, 'https://nfemws.joinville.sc.gov.br/NotaFiscal/Servicos.asmx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  8 dm_tp_serv, 'Consulta de Empresas Autorizadas a emitir NFS-e'descr, 'https://nfemws.joinville.sc.gov.br/NotaFiscal/Servicos.asmx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  9 dm_tp_serv, 'Login'                                          descr, 'https://nfemws.joinville.sc.gov.br/NotaFiscal/Servicos.asmx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap, 10 dm_tp_serv, 'Consulta de Lote de RPS'                        descr, 'https://nfemws.joinville.sc.gov.br/NotaFiscal/Servicos.asmx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               --Homologação
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  1 dm_tp_serv, 'Geração de NFS-e'                               descr, 'https://nfemwshomologacao.joinville.sc.gov.br/NotaFiscal/Servicos.asmx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  2 dm_tp_serv, 'Recepção e Processamento de lote de RPS'        descr, 'https://nfemwshomologacao.joinville.sc.gov.br/NotaFiscal/Servicos.asmx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  3 dm_tp_serv, 'Consulta de Situação de lote de RPS'            descr, 'https://nfemwshomologacao.joinville.sc.gov.br/NotaFiscal/Servicos.asmx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  4 dm_tp_serv, 'Consulta de NFS-e por RPS'                      descr, 'https://nfemwshomologacao.joinville.sc.gov.br/NotaFiscal/Servicos.asmx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  5 dm_tp_serv, 'Consulta de NFS-e'                              descr, 'https://nfemwshomologacao.joinville.sc.gov.br/NotaFiscal/Servicos.asmx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  6 dm_tp_serv, 'Cancelamento de NFS-e'                          descr, 'https://nfemwshomologacao.joinville.sc.gov.br/NotaFiscal/Servicos.asmx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  7 dm_tp_serv, 'Substituição de NFS-e'                          descr, 'https://nfemwshomologacao.joinville.sc.gov.br/NotaFiscal/Servicos.asmx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  8 dm_tp_serv, 'Consulta de Empresas Autorizadas a emitir NFS-e'descr, 'https://nfemwshomologacao.joinville.sc.gov.br/NotaFiscal/Servicos.asmx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  9 dm_tp_serv, 'Login'                                          descr, 'https://nfemwshomologacao.joinville.sc.gov.br/NotaFiscal/Servicos.asmx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap, 10 dm_tp_serv, 'Consulta de Lote de RPS'                        descr, 'https://nfemwshomologacao.joinville.sc.gov.br/NotaFiscal/Servicos.asmx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual
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
                  raise_application_error(-20101, 'Erro no script Redmine #75898 Atualização URL ambiente de homologação e Produção Joinville - SC' || sqlerrm);
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
      raise_application_error(-20102, 'Erro no script Redmine #75898 Atualização URL ambiente de homologação e Produção Joinville - SC' || sqlerrm);
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
		execute immediate 'alter table CSF_OWN.CIDADE_NFSE add constraint CIDADENFSE_DMPADRAO_CK check (dm_padrao in (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45))';
	 exception 
		when others then
			null;
	 end;
  elsif  vn_count = 0 then    
     begin
		execute immediate 'alter table CSF_OWN.CIDADE_NFSE add constraint CIDADENFSE_DMPADRAO_CK check (dm_padrao in (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45))';
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
								  ,  '45'
								  ,  'NFem'
								  ,  CSF_OWN.DOMINIO_SEQ.NEXTVAL  ); 
	  --
	  commit;        
	  --
  exception  
      when dup_val_on_index then 
          begin 
              update CSF_OWN.DOMINIO 
                 set vl      = '45'
               where dominio = 'CIDADE_NFSE.DM_PADRAO'
                 and descr   = 'NFem'; 
	  	      --
              commit; 
              --
           exception when others then 
                raise_application_error(-20101, 'Erro no script Redmine #75898 Adicionar Padrão para emissão de NFS-e (NFem)' || sqlerrm);
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
	vv_ibge_cidade := '4209102';
	vv_padrao      := 'NFem';     
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
			raise_application_error(-20103, 'Erro no script Redmine #75898 Atualização do Padrão Joinville - SC' || sqlerrm);
    end;
	--
	commit;
	--
--
end;
--
/  

-------------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #75898 Criação de padrão NFem a adição de Joinville-SC ao padrão
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #75193 - Adicionar campo EMPRESA_FORMA_TRIB.PERC_RED_IR
-------------------------------------------------------------------------------------------------------------------------------
 
declare
  vn_qtde    number;
begin
  begin
     select count(1)
       into vn_qtde 
       from all_tab_columns a
      where a.OWNER = 'CSF_OWN'  
        and a.TABLE_NAME = 'EMPRESA_FORMA_TRIB'
        and a.COLUMN_NAME = 'PERC_RED_IR'; 
   exception
      when others then
         vn_qtde := 0;
   end;	
   --   
   if vn_qtde = 0 then
      -- Add/modify columns    
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.EMPRESA_FORMA_TRIB add perc_red_ir number(5,2)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao incluir coluna "perc_red_ir" em EMPRESA_FORMA_TRIB - '||SQLERRM );
      END;
      -- 
      -- Add comments to the table   
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.EMPRESA_FORMA_TRIB.perc_red_ir is ''Percentual de Redu??o de IR para atividades incentivadas''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao alterar comentario de EMPRESA_FORMA_TRIB - '||SQLERRM );
      END;	  
      -- 
   end if;
   --  
   commit;
   --   
end;
/

--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #75193 - Adicionar campo EMPRESA_FORMA_TRIB.PERC_RED_IR
-------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #74016 - Criar DT_EXE_SERV no conhecimento de transporte
-------------------------------------------------------------------------------------------------------------------------------
 
declare
  vn_qtde    number;
begin
  begin
     select count(1)
       into vn_qtde 
       from all_tab_columns a
      where a.OWNER = 'CSF_OWN'  
        and a.TABLE_NAME = 'CONHEC_TRANSP'
        and a.COLUMN_NAME = 'DT_EXE_SERV'; 
   exception
      when others then
         vn_qtde := 0;
   end;	
   --   
   if vn_qtde = 0 then
      -- Add/modify columns    
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CONHEC_TRANSP add dt_exe_serv date';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao incluir coluna "DT_EXE_SERV" em CONHEC_TRANSP - '||SQLERRM );
      END;
      -- 
      -- Add comments to the table   
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP.dt_exe_serv is ''Data de competência ou em que serviço foi executado''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao alterar comentario de CONHEC_TRANSP - '||SQLERRM );
      END;	  
      -- 
   end if;
   --  
   vn_qtde := 0;   
   --
   begin
      select count(1)
        into vn_qtde 
        from all_tab_columns a
       where a.OWNER = 'CSF_OWN'  
         and a.TABLE_NAME = 'TMP_CONHEC_TRANSP'
         and a.COLUMN_NAME = 'DT_EXE_SERV'; 
   exception
      when others then
         vn_qtde := 0;
   end;	
   --  
   if vn_qtde = 0 then
      -- Add/modify columns    
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.TMP_CONHEC_TRANSP add dt_exe_serv date';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao incluir coluna "DT_EXE_SERV" em TMP_CONHEC_TRANSP - '||SQLERRM );
      END;
      -- 
   end if;
   -- 
   vn_qtde := 0;
   --
   begin
      select count(1)
        into vn_qtde	  
        from csf_own.obj_util_integr    ou
           , csf_own.ff_obj_util_integr ff
       where ou.obj_name         = 'VW_CSF_CONHEC_TRANSP_FF'
         and ff.objutilintegr_id = ou.id
         and ff.atributo         = 'DT_EXE_SERV';
   exception
      when others then
         vn_qtde := 0;
   end;
   --   
   if vn_qtde = 0 then 
      --
      begin
         insert into csf_own.ff_obj_util_integr( id
                                               , objutilintegr_id
                                               , atributo
                                               , descr
                                               , dm_tipo_campo
                                               , tamanho
                                               , qtde_decimal
                                               )    
                                         values( csf_own.objutilintegr_seq.nextval
                                               , (select oi.id from csf_own.obj_util_integr oi where oi.obj_name = 'VW_CSF_CONHEC_TRANSP_FF')
                                               , 'DT_EXE_SERV'
                                               , 'Data de competência ou em que serviço foi executado'
                                               , 0
                                               , 10
                                               , 0
                                               );     	  
      exception
         when dup_val_on_index then
            update csf_own.ff_obj_util_integr ff
               set ff.descr         = 'Data de competência ou em que serviço foi executado'
                 , ff.dm_tipo_campo = 0
                 , ff.tamanho       = 10
                 , ff.qtde_decimal  = 0
             where ff.objutilintegr_id = (select oi.id from csf_own.obj_util_integr oi where oi.obj_name = 'VW_CSF_CONHEC_TRANSP_FF')
               and ff.atributo         = 'DT_EXE_SERV';                 			 
      end;
      --	  
   end if;
   -- 
   commit;
   --   
end;
/

--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #74016 - Criar DT_EXE_SERV no conhecimento de transporte
-------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #73063 - Alterações para emissão de conhecimento de transporte.
-------------------------------------------------------------------------------------------------------------------------------
 
declare
  vn_qtde    number;
begin
  --
  begin
     select count(1)
       into vn_qtde
       from all_tables t
      where t.OWNER = 'CSF_OWN'  
        and t.TABLE_NAME = 'CONHEC_TRANSP_CCE';
   exception
      when others then
         vn_qtde := 0;
   end;	
   --   
   if vn_qtde = 0 then
      -- 
      -- Create table
      --
      BEGIN
         EXECUTE IMMEDIATE 'create table CSF_OWN.CONHEC_TRANSP_CCE (id NUMBER not null, conhectransp_id NUMBER not null, dm_st_integra NUMBER(1) default 0 not null, dm_st_proc NUMBER(2) default 0 not null, id_tag_chave VARCHAR2(54), dt_hr_evento DATE not null, tipoeventosefaz_id NUMBER, correcao VARCHAR2(1000) not null, versao_leiaute VARCHAR2(20), versao_evento VARCHAR2(20), versao_cce VARCHAR2(20), versao_aplic VARCHAR2(40), cod_msg_cab  VARCHAR2(4), motivo_resp_cab VARCHAR2(4000), msgwebserv_id_cab NUMBER, cod_msg VARCHAR2(4), motivo_resp VARCHAR2(4000), msgwebserv_id NUMBER, dt_hr_reg_evento DATE, nro_protocolo NUMBER(15), usuario_id NUMBER, xml_envio BLOB, xml_retorno BLOB, xml_proc BLOB, dm_download_xml_sic NUMBER(1) default 0 not null ) tablespace CSF_DATA';		 
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar tabela de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      -- 
      commit;
      --	  
      -- Add comments to the table   
      BEGIN
         EXECUTE IMMEDIATE 'comment on table CSF_OWN.CONHEC_TRANSP_CCE is ''Tabela de CC-e vinculada ao conhecimento de transporte''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      -- 
      -- Add comments to the columns
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.conhectransp_id is ''ID relacionado a tabela CONHEC_TRANSP''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.dm_st_integra is ''Situa??o de Integra??o: 0 - Indefinido, 2 - Integrado via arquivo texto (IN), 7 - Integra??o por view de banco de dados, 8 - Inserida a resposta do CTe para o ERP, 9 - Atualizada a resposta do CTe para o ERP''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.dm_st_proc is ''Situa??o: 0-N?o Validado; 1-Validado; 2-Aguardando Envio; 3-Processado; 4-Erro de valida??o; 5-Rejeitada''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.id_tag_chave is ''Identificador da TAG a ser assinada, a regra de forma??o do Id ?: ID + tpEvento + chave do CT-e + nSeqEvento''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.dt_hr_evento is ''Data e hora do evento no formato''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.tipoeventosefaz_id is ''ID relacionado a tabela TIPO_EVENTO_SEFAZ''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.correcao is ''Corre??o a ser considerada, texto livre. A corre??o mais recente substitui as anteriores''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.versao_leiaute is ''Vers?o do leiaute do evento''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.versao_evento is ''Vers?o do evento''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.versao_cce is ''Vers?o da carta de corre??o''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.versao_aplic is ''Vers?o da aplica??o que processou o evento''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.cod_msg_cab is ''C?digo do status da resposta Cabe?alho''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.motivo_resp_cab is ''Descri??o do status da resposta Cabe?alho''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.msgwebserv_id_cab is ''ID relacionado a tabela MSG_WEB_SERV para cabe?alho do retorno''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.cod_msg is ''C?digo do status da resposta''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.motivo_resp is ''Descri??o do status da resposta''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.msgwebserv_id is ''ID relacionado a tabela MSG_WEB_SERV''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.dt_hr_reg_evento is ''Data e hora de registro do evento no formato''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.nro_protocolo is ''N?mero do Protocolo do Evento da CC-e''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.usuario_id is ''ID relacionado a tabela NEO_USUARIO''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.xml_envio is ''XML de envio da CCe''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.xml_retorno is ''XML de retorno da CCe''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.xml_proc is ''XML de processado da CCe''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.dm_download_xml_sic is ''Donwload XML pelo SIC: 0-N?o; 1-Sim''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      -- Create/Recreate primary, unique and foreign key constraints
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CONHEC_TRANSP_CCE add constraint CONHECTRANSPCCE_PK primary key (ID) using index tablespace CSF_INDEX';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar primary de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CONHEC_TRANSP_CCE add constraint CTCCE_MSGWEBSERV_CAB_FK foreign key (MSGWEBSERV_ID_CAB) references CSF_OWN.MSG_WEBSERV (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign key de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CONHEC_TRANSP_CCE add constraint CTCCE_MSGWEBSERV_FK foreign key (MSGWEBSERV_ID) references CSF_OWN.MSG_WEBSERV (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign key de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CONHEC_TRANSP_CCE add constraint CTCCE_CONHECTRANSP_FK foreign key (CONHECTRANSP_ID) references CSF_OWN.CONHEC_TRANSP (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign key de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CONHEC_TRANSP_CCE add constraint CTCCE_TIPOEVENTOSEFAZ_FK foreign key (TIPOEVENTOSEFAZ_ID) references CSF_OWN.TIPO_EVENTO_SEFAZ (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign key de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CONHEC_TRANSP_CCE add constraint CONHECTRANSPCCE_USUARIO_FK foreign key (USUARIO_ID) references CSF_OWN.NEO_USUARIO (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign key de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;
      --
      -- Create/Recreate indexes 	  
      BEGIN
         EXECUTE IMMEDIATE 'create index CTCCE_MSGWEBSERV_CAB_FK_I on CSF_OWN.CONHEC_TRANSP_CCE (MSGWEBSERV_ID_CAB) tablespace CSF_INDEX';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar index de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'create index CTCCE_MSGWEBSERV_FK_I on CSF_OWN.CONHEC_TRANSP_CCE (MSGWEBSERV_ID) tablespace CSF_INDEX';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar index de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;
      --		  
      BEGIN
         EXECUTE IMMEDIATE 'create index CTCCE_CONHECTRANSP_FK_I on CSF_OWN.CONHEC_TRANSP_CCE (CONHECTRANSP_ID) tablespace CSF_INDEX';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar index de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'create index CTCCE_TIPOEVENTOSEFAZ_FK_I on CSF_OWN.CONHEC_TRANSP_CCE (TIPOEVENTOSEFAZ_ID) tablespace CSF_INDEX';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar index de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'create index CONHECTRANSPCCE_USUARIO_FK_I on CSF_OWN.CONHEC_TRANSP_CCE (USUARIO_ID) tablespace CSF_INDEX';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar index de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;
      --
      -- Create/Recreate check constraints 	  
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CONHEC_TRANSP_CCE add constraint CTCCE_STPROC_CK check (DM_ST_PROC in (0, 1, 2, 3, 4, 5))';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar check constraints de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CONHEC_TRANSP_CCE add constraint CTCCE_DMSTINTEGRA_CK check (dm_st_integra IN (0,2,7,8,9))';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar check constraints de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;
      --
      -- Grant/Revoke object privileges	
      BEGIN
         EXECUTE IMMEDIATE 'grant select, insert, update, delete on CSF_OWN.CONHEC_TRANSP_CCE to CSF_WORK';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar check constraints de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;
      --
   end if;
   --  
   vn_qtde := 0;   
   --
   begin   
      select count(1)
        into vn_qtde 
        from all_sequences s
       where s.SEQUENCE_OWNER = 'CSF_OWN'
         and s.SEQUENCE_NAME  = 'CONHECTRANSPCCE_SEQ';   
   exception
      when others then
         vn_qtde := 0;		 
   end;
   --  
   if vn_qtde = 0 then 
      --
      BEGIN
         -- Create sequence
         EXECUTE IMMEDIATE 'create sequence CSF_OWN.CONHECTRANSPCCE_SEQ minvalue 1 maxvalue 9999999999999999999999999999 start with 1 increment by 1 nocache';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar sequence de CONHECTRANSPCCE_SEQ - '||SQLERRM );
      END;
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
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CONHEC_TRANSP_CCE.DM_ST_INTEGRA'
                                  , '0'
                                  , 'Indefinido'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Indefinido'           
          where dominio = 'CONHEC_TRANSP_CCE.DM_ST_INTEGRA'
            and vl = '0';
   end;		
   --
   begin
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CONHEC_TRANSP_CCE.DM_ST_INTEGRA'
                                  , '2'
                                  , 'Integrado via arquivo texto (IN)'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Integrado via arquivo texto (IN)'           
          where dominio = 'CONHEC_TRANSP_CCE.DM_ST_INTEGRA'
            and vl = '2';
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CONHEC_TRANSP_CCE.DM_ST_INTEGRA'
                                  , '7'
                                  , 'Integra??o por view de banco de dados'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Integra??o por view de banco de dados'           
          where dominio = 'CONHEC_TRANSP_CCE.DM_ST_INTEGRA'
            and vl = '7';
   end;		
   --   
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CONHEC_TRANSP_CCE.DM_ST_INTEGRA'
                                  , '8'
                                  , 'Inserida a resposta do CTe para o ERP'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Inserida a resposta do CTe para o ERP'           
          where dominio = 'CONHEC_TRANSP_CCE.DM_ST_INTEGRA'
            and vl = '8';
   end;		
   --   
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CONHEC_TRANSP_CCE.DM_ST_INTEGRA'
                                  , '9'
                                  , 'Atualizada a resposta do CTe para o ERP'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Atualizada a resposta do CTe para o ERP'           
          where dominio = 'CONHEC_TRANSP_CCE.DM_ST_INTEGRA'
            and vl = '9';
   end;		
   --  
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CONHEC_TRANSP_CCE.DM_ST_PROC'
                                  , '0'
                                  , 'N?o Validado'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'N?o Validado'           
          where dominio = 'CONHEC_TRANSP_CCE.DM_ST_PROC'
            and vl = '0';
   end;	
   --   
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CONHEC_TRANSP_CCE.DM_ST_PROC'
                                  , '1'
                                  , 'Validado'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Validado'           
          where dominio = 'CONHEC_TRANSP_CCE.DM_ST_PROC'
            and vl = '1';
   end;
   --   
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CONHEC_TRANSP_CCE.DM_ST_PROC'
                                  , '2'
                                  , 'Aguardando Envio'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Aguardando Envio'           
          where dominio = 'CONHEC_TRANSP_CCE.DM_ST_PROC'
            and vl = '2';
   end;
   --   
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CONHEC_TRANSP_CCE.DM_ST_PROC'
                                  , '3'
                                  , 'Processado'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Processado'           
          where dominio = 'CONHEC_TRANSP_CCE.DM_ST_PROC'
            and vl = '3';
   end;   
   --   
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CONHEC_TRANSP_CCE.DM_ST_PROC'
                                  , '4'
                                  , 'Erro de valida??o'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Erro de valida??o'           
          where dominio = 'CONHEC_TRANSP_CCE.DM_ST_PROC'
            and vl = '4';
   end;    
   --   
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CONHEC_TRANSP_CCE.DM_ST_PROC'
                                  , '5'
                                  , 'Rejeitada'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Rejeitada'           
          where dominio = 'CONHEC_TRANSP_CCE.DM_ST_PROC'
            and vl = '5';
   end;   
   --
   commit;
   --     
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
		execute immediate 'alter table CSF_OWN.CIDADE_NFSE add constraint CIDADENFSE_DMPADRAO_CK check (dm_padrao in (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45))';
	 exception 
		when others then
			null;
	 end;
  elsif  vn_count = 0 then    
     begin
		execute immediate 'alter table CSF_OWN.CIDADE_NFSE add constraint CIDADENFSE_DMPADRAO_CK check (dm_padrao in (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45))';
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
								  ,  '45'
								  ,  'NFem'
								  ,  CSF_OWN.DOMINIO_SEQ.NEXTVAL  ); 
	  --
	  commit;        
	  --
  exception  
      when dup_val_on_index then 
          begin 
              update CSF_OWN.DOMINIO 
                 set vl      = '45'
               where dominio = 'CIDADE_NFSE.DM_PADRAO'
                 and descr   = 'NFem'; 
	  	      --
              commit; 
              --
           exception when others then 
                raise_application_error(-20101, 'Erro no script Redmine #75898 Adicionar Padr?o para emissão de NFS-e (NFem)' || sqlerrm);
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
	-- Popula vari?veis
	vv_ibge_cidade := '4209102';
	vv_padrao      := 'NFem';     
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
			raise_application_error(-20103, 'Erro no script Redmine #75898 Atualiza??o do Padr?o Joinville - SC' || sqlerrm);
    end;
	--
	commit;
	--
--
end;
--
/  

-------------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #75898 Criação de padr?o NFem a adi??o de Joinville-SC ao padr?o
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #75749 Sincroniza??o dos scripts Padr?o Tinus Goiana - PE
-------------------------------------------------------------------------------------------------------------------------------------------
--
--CIDADE  : Goiana - PE
--IBGE    : 2606200
--PADRAO  : Tinus
--HABIL   : SIM
--WS_CANC : SIM

declare 
   --   
   -- dm_tp_amb (Tipo de Ambiente 1-Producao; 2-Homologacao)
   cursor c_dados is
      select   ( select id from csf_own.cidade where ibge_cidade = '2606200' ) id, dm_situacao,  versao,  dm_tp_amb,  dm_tp_soap,  dm_tp_serv, descr, url_wsdl, dm_upload, dm_ind_emit 
        from ( --Produ??o
			   select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  1 dm_tp_serv, 'Gera??o de NFS-e'                               descr, 'http://www.tinus.com.br/csp/goiana/WSNFSE.RecepcionarLoteRps.CLS?WSDL=1' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  2 dm_tp_serv, 'Recep??o e Processamento de lote de RPS'        descr, 'http://www.tinus.com.br/csp/goiana/WSNFSE.RecepcionarLoteRps.CLS?WSDL=1' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  3 dm_tp_serv, 'Consulta de Situa??o de lote de RPS'            descr, 'http://www.tinus.com.br/csp/goiana/WSNFSE.ConsultarSituacaoLoteRps.CLS?WSDL=1' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  4 dm_tp_serv, 'Consulta de NFS-e por RPS'                      descr, 'http://www.tinus.com.br/csp/goiana/WSNFSE.ConsultarNfsePorRps.CLS?WSDL=1' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  5 dm_tp_serv, 'Consulta de NFS-e'                              descr, 'http://www.tinus.com.br/csp/goiana/WSNFSE.ConsultarNfse.CLS?WSDL=1' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  6 dm_tp_serv, 'Cancelamento de NFS-e'                          descr, 'http://www.tinus.com.br/csp/goiana/WSNFSE.CancelarNfse.CLS?WSDL=1' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  7 dm_tp_serv, 'Substitui??o de NFS-e'                          descr, 'http://www.tinus.com.br/csp/goiana/WSNFSE.RecepcionarLoteRps.CLS?WSDL=1' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  8 dm_tp_serv, 'Consulta de Empresas Autorizadas a emitir NFS-e'descr, 'http://www.tinus.com.br/csp/goiana/WSNFSE.RecepcionarLoteRps.CLS?WSDL=1' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  9 dm_tp_serv, 'Login'                                          descr, 'http://www.tinus.com.br/csp/goiana/WSNFSE.RecepcionarLoteRps.CLS?WSDL=1' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap, 10 dm_tp_serv, 'Consulta de Lote de RPS'                        descr, 'http://www.tinus.com.br/csp/goiana/WSNFSE.ConsultarLoteRps.CLS?WSDL=1' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               --Homologa??o
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  1 dm_tp_serv, 'Gera??o de NFS-e'                               descr, 'http://www2.tinus.com.br/csp/testegoi/WSNFSE.RecepcionarLoteRps.CLS?WSDL=1' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  2 dm_tp_serv, 'Recep??o e Processamento de lote de RPS'        descr, 'http://www2.tinus.com.br/csp/testegoi/WSNFSE.RecepcionarLoteRps.CLS?WSDL=1' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  3 dm_tp_serv, 'Consulta de Situa??o de lote de RPS'            descr, 'http://www2.tinus.com.br/csp/testegoi/WSNFSE.ConsultarSituacaoLoteRps.CLS?WSDL=1' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  4 dm_tp_serv, 'Consulta de NFS-e por RPS'                      descr, 'http://www2.tinus.com.br/csp/testegoi/WSNFSE.ConsultarNfsePorRps.CLS?WSDL=1' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  5 dm_tp_serv, 'Consulta de NFS-e'                              descr, 'http://www2.tinus.com.br/csp/testegoi/WSNFSE.ConsultarNfse.CLS?WSDL=1' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  6 dm_tp_serv, 'Cancelamento de NFS-e'                          descr, 'http://www2.tinus.com.br/csp/testegoi/WSNFSE.CancelarNfse.CLS?WSDL=1' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  7 dm_tp_serv, 'Substitui??o de NFS-e'                          descr, 'http://www2.tinus.com.br/csp/testegoi/WSNFSE.RecepcionarLoteRps.CLS?WSDL=1' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  8 dm_tp_serv, 'Consulta de Empresas Autorizadas a emitir NFS-e'descr, 'http://www2.tinus.com.br/csp/testegoi/WSNFSE.RecepcionarLoteRps.CLS?WSDL=1' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  9 dm_tp_serv, 'Login'                                          descr, 'http://www2.tinus.com.br/csp/testegoi/WSNFSE.RecepcionarLoteRps.CLS?WSDL=1' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap, 10 dm_tp_serv, 'Consulta de Lote de RPS'                        descr, 'http://www2.tinus.com.br/csp/testegoi/WSNFSE.ConsultarLoteRps.CLS?WSDL=1' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual
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
                  raise_application_error(-20101, 'Erro no script Redmine #75749 Atualiza??o URL ambiente de homologa??o e Produ??o Goiana - PE' || sqlerrm);
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
      raise_application_error(-20102, 'Erro no script Redmine #75749 Atualiza??o URL ambiente de homologa??o e Produ??o Goiana - PE' || sqlerrm);
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
	-- Popula vari?veis
	vv_ibge_cidade := '2606200';
	vv_padrao      := 'Tinus';     
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
			raise_application_error(-20103, 'Erro no script Redmine #75749 Atualiza??o do Padr?o Goiana - PE' || sqlerrm);
    end;
	--
	commit;
	--
--
end;
--
/  

-------------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #75749 Sincroniza??o dos scripts Padr?o Tinus Goiana - PE
-------------------------------------------------------------------------------------------------------------------------------------------
------------- ---------------------------------------------------------------------------
  vn_qtde    number;
begin
  --
  begin
     select count(1)
       into vn_qtde
       from all_tab_columns c
      where c.OWNER       = 'CSF_OWN'
        and c.TABLE_NAME  = 'INUTILIZA_CONHEC_TRANSP'
        and c.COLUMN_NAME = 'ID_INUT' 
        and c.NULLABLE    = 'N';
   exception
      when others then
         vn_qtde := 0;
   end;	
   --   
   if vn_qtde = 1 then
      -- 
	  -- Add/modify columns 
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.INUTILIZA_CONHEC_TRANSP modify id_inut null';		 
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro alterar coluna ID_INUT de INUTILIZA_CONHEC_TRANSP - '||SQLERRM );
      END;	  
      -- 
      commit;
      --	  
   end if;
   --  
end;
/

begin
   --
   begin  
     insert into csf_own.tipo_obj_integr( id
                                        , objintegr_id
                                        , cd
                                        , descr )
                                 values ( tipoobjintegr_seq.nextval
                                        , (select o.id from csf_own.obj_integr o where o.cd = '4')
                                        , '4'
                                        , 'Inutiliza??o de emissão Pr?pria de Conhec. de Transporte'
                                        );       
   exception
     when others then
       update csf_own.tipo_obj_integr
          set descr = 'Inutiliza??o de emissão Pr?pria de Conhec. de Transporte'
        where objintegr_id in (select o.id from csf_own.obj_integr o where o.cd = '4')
          and cd           = '4';       
   end; 
   --  
   begin  
     insert into csf_own.tipo_obj_integr( id
                                        , objintegr_id
                                        , cd
                                        , descr )
                                 values ( tipoobjintegr_seq.nextval
                                        , (select o.id from csf_own.obj_integr o where o.cd = '4')
                                        , '5'
                                        , 'Carta de Corre??o emissão Pr?pria de Conhec. de Transporte'
                                        );       
   exception
     when others then
       update csf_own.tipo_obj_integr
          set descr = 'Carta de Corre??o emissão Pr?pria de Conhec. de Transporte'
        where objintegr_id in (select o.id from csf_own.obj_integr o where o.cd = '4')
          and cd           = '5';       
   end; 
   -- 
   commit;
   --   
end;
/

--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine Redmine #73063 - Alterações para emissão de conhecimento de transporte.
--------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #74444 - Pontos de corre??o no processo de Apura??o do IRPJ e CSLL
-------------------------------------------------------------------------------------------------------------------------------
declare
   vn_modulo_id number := 0;
   vn_grupo_id number := 0;
   vn_param_id number := 0;
   vn_usuario_id number := null;
begin

-- MODULO DO SISTEMA --
   begin
      select ms.id
        into vn_modulo_id
        from CSF_OWN.MODULO_SISTEMA ms
       where ms.cod_modulo = 'CONTABIL';
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
      values(CSF_OWN.MODULOSISTEMA_SEQ.NEXTVAL, 'CONTABIL', 'Obriga??es Cont?beis ECD e ECF', 'M?dulo com parametros referentes as obriga??es contabeis ECD E ECF (Sped Cont?bil e Sped ECF)')
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
         and gs.cod_grupo = 'ECF';
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
      values(CSF_OWN.GRUPOSISTEMA_SEQ.NextVal, vn_modulo_id, 'ECF', 'PARAMETROS UTILIZADOS NA ECF', 'GRUPO COM INFORMA??ES DE PARAMETROS UTILIZADOS NA ECF')
      returning id into vn_grupo_id;
      --
   end if;
   --
   -- PARAMETRO DO SISTEMA --
   for x in (select * from CSF_OWN.EMPRESA m where m.dm_situacao = 1)
   loop
      begin
         select pgs.id
           into vn_param_id
           from CSF_OWN.PARAM_GERAL_SISTEMA pgs  -- UK: MULTORG_ID, EMPRESA_ID, MODULO_ID, GRUPO_ID, PARAM_NAME
          where pgs.Empresa_Id = x.Id
            and pgs.modulo_id  = vn_modulo_id
            and pgs.grupo_id   = vn_grupo_id
            and pgs.param_name = 'APUR_IR_CSLL_PARC_MENSAL';
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
         -- Busca o usu?rio respond?vel pelo Mult_org
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
                   where nu.Multorg_Id = x.MULTORG_ID;
               exception
                  when others then
                     goto SAIR_SCRIPT;
               end;
         end;
         --
         insert into CSF_OWN.PARAM_GERAL_SISTEMA( id
                                                , multorg_id
                                                , empresa_id
                                                , modulo_id
                                                , grupo_id
                                                , param_name
                                                , dsc_param
                                                , vlr_param
                                                , usuario_id_alt
                                                , dt_alteracao )
         values( CSF_OWN.PARAMGERALSISTEMA_SEQ.NextVal
               , X.MULTORG_ID
               , X.ID
               , vn_modulo_id
               , vn_grupo_id
               , 'APUR_IR_CSLL_PARC_MENSAL'
               , 'Realiza apura??o parcial do IR e CSLL somente do m?s e n?o acumulado.  Valores poss?veis: N = Padr?o / S = Recupera os dados de forma parcial'
               , 'N'
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
Prompt FIM Redmine #74444 - Pontos de corre??o no processo de Apura??o do IRPJ e CSLL
-------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #74016 - Criar DT_EXE_SERV no conhecimento de transporte
-------------------------------------------------------------------------------------------------------------------------------
 
declare
  vn_qtde    number;
begin
  begin
     select count(1)
       into vn_qtde 
       from all_tab_columns a
      where a.OWNER = 'CSF_OWN'  
        and a.TABLE_NAME = 'CONHEC_TRANSP'
        and a.COLUMN_NAME = 'DT_EXE_SERV'; 
   exception
      when others then
         vn_qtde := 0;
   end;	
   --   
   if vn_qtde = 0 then
      -- Add/modify columns    
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CONHEC_TRANSP add dt_exe_serv date';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao incluir coluna "DT_EXE_SERV" em CONHEC_TRANSP - '||SQLERRM );
      END;
      -- 
      -- Add comments to the table   
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP.dt_exe_serv is ''Data de competência ou em que serviço foi executado''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao alterar comentario de CONHEC_TRANSP - '||SQLERRM );
      END;	  
      -- 
   end if;
   --  
   vn_qtde := 0;   
   --
   begin
      select count(1)
        into vn_qtde 
        from all_tab_columns a
       where a.OWNER = 'CSF_OWN'  
         and a.TABLE_NAME = 'TMP_CONHEC_TRANSP'
         and a.COLUMN_NAME = 'DT_EXE_SERV'; 
   exception
      when others then
         vn_qtde := 0;
   end;	
   --  
   if vn_qtde = 0 then
      -- Add/modify columns    
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.TMP_CONHEC_TRANSP add dt_exe_serv date';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao incluir coluna "DT_EXE_SERV" em TMP_CONHEC_TRANSP - '||SQLERRM );
      END;
      --
   end if;
   -- 
   vn_qtde := 0;
   --
   begin
      select count(1)
        into vn_qtde	  
        from csf_own.obj_util_integr    ou
           , csf_own.ff_obj_util_integr ff
       where ou.obj_name         = 'VW_CSF_CONHEC_TRANSP_FF'
         and ff.objutilintegr_id = ou.id
         and ff.atributo         = 'DT_EXE_SERV';
   exception
      when others then
         vn_qtde := 0;
   end;
   --   
   if vn_qtde = 0 then 
      --
      begin
         insert into csf_own.ff_obj_util_integr( id
                                               , objutilintegr_id
                                               , atributo
                                               , descr
                                               , dm_tipo_campo
                                               , tamanho
                                               , qtde_decimal
                                               )    
                                         values( csf_own.objutilintegr_seq.nextval
                                               , (select oi.id from csf_own.obj_util_integr oi where oi.obj_name = 'VW_CSF_CONHEC_TRANSP_FF')
                                               , 'DT_EXE_SERV'
                                               , 'Data de competência ou em que serviço foi executado'
                                               , 0
                                               , 10
                                               , 0
                                               );     	  
      exception
         when dup_val_on_index then
            update csf_own.ff_obj_util_integr ff
               set ff.descr         = 'Data de competência ou em que serviço foi executado'
                 , ff.dm_tipo_campo = 0
                 , ff.tamanho       = 10
                 , ff.qtde_decimal  = 0
             where ff.objutilintegr_id = (select oi.id from csf_own.obj_util_integr oi where oi.obj_name = 'VW_CSF_CONHEC_TRANSP_FF')
               and ff.atributo         = 'DT_EXE_SERV';                 			 
      end;
      --	  
   end if;
   -- 
   commit;
   --   
end;
/

--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #74016 - Criar DT_EXE_SERV no conhecimento de transporte
-------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #73922 - Estrutura de tabelas
-------------------------------------------------------------------------------------------------------------------------------

@@73922_01_Nova_tab_FORMULA_COD_DIN_LUCEXP.sql
/

@@73922_02_Nova_tab_COD_DIN_LUCR_EXPR.sql
/

@@73922_03_Nova_tab_ITFORMULA_COD_DIN_LUCEXP.sql
/

@@73922_04_Nova_tab_PAR_DP_CODDIN_CTA_LUCEXP.sql
/

@@73922_05_Nova_tab_CRIT_PESQ_SLD_LUCR_EXPL.sql
/

@@73922_06_Nova_tab_CRIT_PESQ_LCTO_LUCR_EXPL.sql
/

@@73922_07_Nova_tab_PER_LUCR_EXPL.sql
/

@@73922_08_Nova_tab_APUR_LUCRO_EXPL.sql
/

@@73922_09_Nova_tab_MEM_CALC_LUCRO_EXPL.sql
/

@@73922_10_Nova_tab_PARAM_REC_LUCR_EXPL.sql
/

@@73922_11_Nova_tab_REC_UNID_LUCR_EXP.sql
/

@@73922_12_Nova_tab_CALC_LUCRO_EXPL.sql
/

@@73922_13_Nova_tab_CALC_BENEF_LUCRO_EXPL.sql
/

@@73922_14_Nova_tab_REL_CALC_LUCR_EXPLR.sql
/

@@73922_15_Nova_tab_REL_DISTR_ATV_LUCR_EXPLR.sql
/

@@73922_16_Cria_dominios.sql
/

--------------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #73922 - Estrutura de tabelas
--------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #75703 Adicionar cidade Poá ao padrão e-Transparencia
-------------------------------------------------------------------------------------------------------------------------------------------

--CIDADE  : Poá - SP
--IBGE    : 3539806
--PADRAO  : eTransparencia
--HABIL   : SIM
--WS_CANC : SIM

declare 
   --   
   -- dm_tp_amb (Tipo de Ambiente 1-Producao; 2-Homologacao)
   cursor c_dados is
      select   ( select id from csf_own.cidade where ibge_cidade = '3539806' ) id, dm_situacao,  versao,  dm_tp_amb,  dm_tp_soap,  dm_tp_serv, descr, url_wsdl, dm_upload, dm_ind_emit 
        from ( --Produção
			   select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  1 dm_tp_serv, 'Geração de NFS-e'                               descr, 'https://nfe.etransparencia.com.br/sp.poa/webservice/aws_nfe.aspx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  2 dm_tp_serv, 'Recepção e Processamento de lote de RPS'        descr, 'https://nfe.etransparencia.com.br/sp.poa/webservice/aws_nfe.aspx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  3 dm_tp_serv, 'Consulta de Situação de lote de RPS'            descr, 'https://nfe.etransparencia.com.br/sp.poa/webservice/aws_nfe.aspx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  4 dm_tp_serv, 'Consulta de NFS-e por RPS'                      descr, 'https://nfe.etransparencia.com.br/sp.poa/webservice/aws_nfe.aspx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  5 dm_tp_serv, 'Consulta de NFS-e'                              descr, 'https://nfe.etransparencia.com.br/sp.poa/webservice/aws_nfe.aspx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  6 dm_tp_serv, 'Cancelamento de NFS-e'                          descr, 'https://nfe.etransparencia.com.br/sp.poa/webservice/aws_nfe.aspx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  7 dm_tp_serv, 'Substituição de NFS-e'                          descr, 'https://nfe.etransparencia.com.br/sp.poa/webservice/aws_nfe.aspx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  8 dm_tp_serv, 'Consulta de Empresas Autorizadas a emitir NFS-e'descr, 'https://nfe.etransparencia.com.br/sp.poa/webservice/aws_nfe.aspx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  9 dm_tp_serv, 'Login'                                          descr, 'https://nfe.etransparencia.com.br/sp.poa/webservice/aws_nfe.aspx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap, 10 dm_tp_serv, 'Consulta de Lote de RPS'                        descr, 'https://nfe.etransparencia.com.br/sp.poa/webservice/aws_nfe.aspx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               --Homologação
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  1 dm_tp_serv, 'Geração de NFS-e'                               descr, 'https://nfehomologacao.etransparencia.com.br/sp.poa/webservice/aws_nfe.aspx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  2 dm_tp_serv, 'Recepção e Processamento de lote de RPS'        descr, 'https://nfehomologacao.etransparencia.com.br/sp.poa/webservice/aws_nfe.aspx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  3 dm_tp_serv, 'Consulta de Situação de lote de RPS'            descr, 'https://nfehomologacao.etransparencia.com.br/sp.poa/webservice/aws_nfe.aspx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  4 dm_tp_serv, 'Consulta de NFS-e por RPS'                      descr, 'https://nfehomologacao.etransparencia.com.br/sp.poa/webservice/aws_nfe.aspx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  5 dm_tp_serv, 'Consulta de NFS-e'                              descr, 'https://nfehomologacao.etransparencia.com.br/sp.poa/webservice/aws_nfe.aspx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  6 dm_tp_serv, 'Cancelamento de NFS-e'                          descr, 'https://nfehomologacao.etransparencia.com.br/sp.poa/webservice/aws_nfe.aspx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  7 dm_tp_serv, 'Substituição de NFS-e'                          descr, 'https://nfehomologacao.etransparencia.com.br/sp.poa/webservice/aws_nfe.aspx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  8 dm_tp_serv, 'Consulta de Empresas Autorizadas a emitir NFS-e'descr, 'https://nfehomologacao.etransparencia.com.br/sp.poa/webservice/aws_nfe.aspx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  9 dm_tp_serv, 'Login'                                          descr, 'https://nfehomologacao.etransparencia.com.br/sp.poa/webservice/aws_nfe.aspx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap, 10 dm_tp_serv, 'Consulta de Lote de RPS'                        descr, 'https://nfehomologacao.etransparencia.com.br/sp.poa/webservice/aws_nfe.aspx?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual
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
                  raise_application_error(-20101, 'Erro no script Redmine #75703 Atualização URL ambiente de homologação e Produção Poá - SP' || sqlerrm);
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
      raise_application_error(-20102, 'Erro no script Redmine #75703 Atualização URL ambiente de homologação e Produção Poá - SP' || sqlerrm);
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
	vv_ibge_cidade := '3539806';
	vv_padrao      := 'eTransparencia';     
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
			raise_application_error(-20103, 'Erro no script Redmine #75703 Atualização do Padrão Poá - SP' || sqlerrm);
    end;
	--
	commit;
	--
--
end;
--
/  
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #75703 Adicionar cidade Poá ao padrão e-Transparencia
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #76219 Sincronização dos scripts Maringá
-------------------------------------------------------------------------------------------------------------------------------------------
--
--CIDADE  : Maringá
--IBGE    : 4115200
--PADRAO  : Por Cidade
--HABIL   : SIM
--WS_CANC : SIM

--HML: https://nfse-ws.hom-ecity.maringa.pr.gov.br/v2.01
--PRD: https://nfse-ws.ecity.maringa.pr.gov.br/v2.01

declare 
   --   
   -- dm_tp_amb (Tipo de Ambiente 1-Producao; 2-Homologacao)
   cursor c_dados is
      select   ( select id from csf_own.cidade where ibge_cidade = '4115200' ) id, dm_situacao,  versao,  dm_tp_amb,  dm_tp_soap,  dm_tp_serv, descr, url_wsdl, dm_upload, dm_ind_emit 
        from ( --Produção
			   select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  1 dm_tp_serv, 'Geração de NFS-e'                               descr, 'https://nfse-ws.ecity.maringa.pr.gov.br/v2.01' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  2 dm_tp_serv, 'Recepção e Processamento de lote de RPS'        descr, 'https://nfse-ws.ecity.maringa.pr.gov.br/v2.01' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  3 dm_tp_serv, 'Consulta de Situação de lote de RPS'            descr, 'https://nfse-ws.ecity.maringa.pr.gov.br/v2.01' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  4 dm_tp_serv, 'Consulta de NFS-e por RPS'                      descr, 'https://nfse-ws.ecity.maringa.pr.gov.br/v2.01' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  5 dm_tp_serv, 'Consulta de NFS-e'                              descr, 'https://nfse-ws.ecity.maringa.pr.gov.br/v2.01' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  6 dm_tp_serv, 'Cancelamento de NFS-e'                          descr, 'https://nfse-ws.ecity.maringa.pr.gov.br/v2.01' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  7 dm_tp_serv, 'Substituição de NFS-e'                          descr, 'https://nfse-ws.ecity.maringa.pr.gov.br/v2.01' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  8 dm_tp_serv, 'Consulta de Empresas Autorizadas a emitir NFS-e'descr, 'https://nfse-ws.ecity.maringa.pr.gov.br/v2.01' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  9 dm_tp_serv, 'Login'                                          descr, 'https://nfse-ws.ecity.maringa.pr.gov.br/v2.01' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap, 10 dm_tp_serv, 'Consulta de Lote de RPS'                        descr, 'https://nfse-ws.ecity.maringa.pr.gov.br/v2.01' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               --Homologação
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  1 dm_tp_serv, 'Geração de NFS-e'                               descr, 'https://nfse-ws.hom-ecity.maringa.pr.gov.br/v2.01' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  2 dm_tp_serv, 'Recepção e Processamento de lote de RPS'        descr, 'https://nfse-ws.hom-ecity.maringa.pr.gov.br/v2.01' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  3 dm_tp_serv, 'Consulta de Situação de lote de RPS'            descr, 'https://nfse-ws.hom-ecity.maringa.pr.gov.br/v2.01' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  4 dm_tp_serv, 'Consulta de NFS-e por RPS'                      descr, 'https://nfse-ws.hom-ecity.maringa.pr.gov.br/v2.01' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  5 dm_tp_serv, 'Consulta de NFS-e'                              descr, 'https://nfse-ws.hom-ecity.maringa.pr.gov.br/v2.01' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  6 dm_tp_serv, 'Cancelamento de NFS-e'                          descr, 'https://nfse-ws.hom-ecity.maringa.pr.gov.br/v2.01' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  7 dm_tp_serv, 'Substituição de NFS-e'                          descr, 'https://nfse-ws.hom-ecity.maringa.pr.gov.br/v2.01' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  8 dm_tp_serv, 'Consulta de Empresas Autorizadas a emitir NFS-e'descr, 'https://nfse-ws.hom-ecity.maringa.pr.gov.br/v2.01' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  9 dm_tp_serv, 'Login'                                          descr, 'https://nfse-ws.hom-ecity.maringa.pr.gov.br/v2.01' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap, 10 dm_tp_serv, 'Consulta de Lote de RPS'                        descr, 'https://nfse-ws.hom-ecity.maringa.pr.gov.br/v2.01' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual
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
                  raise_application_error(-20101, 'Erro no script Redmine #76219 Atualização URL ambiente de homologação e Produção Maringá - PR' || sqlerrm);
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
      raise_application_error(-20102, 'Erro no script Redmine #76219 Atualização URL ambiente de homologação e Produção Maringá - PR' || sqlerrm);
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
	vv_ibge_cidade := '4115200';
	vv_padrao      := 'Por Cidade';     
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
			raise_application_error(-20103, 'Erro no script Redmine #76219 Atualização do Padrão Maringá - PR' || sqlerrm);
    end;
	--
	commit;
	--
--
end;
--
/  

-------------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #76219 Sincronização dos scripts Maringá
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #76409 Criação de padrão betha a adição de Lages - SC ao padrão
-------------------------------------------------------------------------------------------------------------------------------------------
--
--CIDADE  : Lages - SC
--IBGE    : 4209300
--PADRAO  : Betha Sistemas
--HABIL   : SIM
--WS_CANC : SIM

declare 
   --   
   -- dm_tp_amb (Tipo de Ambiente 1-Producao; 2-Homologacao)
   cursor c_dados is
      select   ( select id from csf_own.cidade where ibge_cidade = '4209300' ) id, dm_situacao,  versao,  dm_tp_amb,  dm_tp_soap,  dm_tp_serv, descr, url_wsdl, dm_upload, dm_ind_emit 
        from ( --Produção
			   select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  1 dm_tp_serv, 'Geração de NFS-e'                               descr, 'http://e-gov.betha.com.br/e-nota-contribuinte-ws/nfseWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  2 dm_tp_serv, 'Recepção e Processamento de lote de RPS'        descr, 'http://e-gov.betha.com.br/e-nota-contribuinte-ws/nfseWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  3 dm_tp_serv, 'Consulta de Situação de lote de RPS'            descr, 'http://e-gov.betha.com.br/e-nota-contribuinte-ws/nfseWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  4 dm_tp_serv, 'Consulta de NFS-e por RPS'                      descr, 'http://e-gov.betha.com.br/e-nota-contribuinte-ws/nfseWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  5 dm_tp_serv, 'Consulta de NFS-e'                              descr, 'http://e-gov.betha.com.br/e-nota-contribuinte-ws/nfseWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  6 dm_tp_serv, 'Cancelamento de NFS-e'                          descr, 'http://e-gov.betha.com.br/e-nota-contribuinte-ws/nfseWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  7 dm_tp_serv, 'Substituição de NFS-e'                          descr, 'http://e-gov.betha.com.br/e-nota-contribuinte-ws/nfseWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  8 dm_tp_serv, 'Consulta de Empresas Autorizadas a emitir NFS-e'descr, 'http://e-gov.betha.com.br/e-nota-contribuinte-ws/nfseWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  9 dm_tp_serv, 'Login'                                          descr, 'http://e-gov.betha.com.br/e-nota-contribuinte-ws/nfseWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap, 10 dm_tp_serv, 'Consulta de Lote de RPS'                        descr, 'http://e-gov.betha.com.br/e-nota-contribuinte-ws/nfseWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               --Homologação
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  1 dm_tp_serv, 'Geração de NFS-e'                               descr, 'http://e-gov.betha.com.br/e-nota-contribuinte-test-ws/nfseWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  2 dm_tp_serv, 'Recepção e Processamento de lote de RPS'        descr, 'http://e-gov.betha.com.br/e-nota-contribuinte-test-ws/nfseWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  3 dm_tp_serv, 'Consulta de Situação de lote de RPS'            descr, 'http://e-gov.betha.com.br/e-nota-contribuinte-test-ws/nfseWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  4 dm_tp_serv, 'Consulta de NFS-e por RPS'                      descr, 'http://e-gov.betha.com.br/e-nota-contribuinte-test-ws/nfseWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  5 dm_tp_serv, 'Consulta de NFS-e'                              descr, 'http://e-gov.betha.com.br/e-nota-contribuinte-test-ws/nfseWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  6 dm_tp_serv, 'Cancelamento de NFS-e'                          descr, 'http://e-gov.betha.com.br/e-nota-contribuinte-test-ws/nfseWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  7 dm_tp_serv, 'Substituição de NFS-e'                          descr, 'http://e-gov.betha.com.br/e-nota-contribuinte-test-ws/nfseWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  8 dm_tp_serv, 'Consulta de Empresas Autorizadas a emitir NFS-e'descr, 'http://e-gov.betha.com.br/e-nota-contribuinte-test-ws/nfseWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  9 dm_tp_serv, 'Login'                                          descr, 'http://e-gov.betha.com.br/e-nota-contribuinte-test-ws/nfseWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap, 10 dm_tp_serv, 'Consulta de Lote de RPS'                        descr, 'http://e-gov.betha.com.br/e-nota-contribuinte-test-ws/nfseWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual
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
                  raise_application_error(-20101, 'Erro no script Redmine #76409 Atualização URL ambiente de homologação e Produção Lages - SC' || sqlerrm);
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
      raise_application_error(-20102, 'Erro no script Redmine #76409 Atualização URL ambiente de homologação e Produção Lages - SC' || sqlerrm);
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
	vv_ibge_cidade := '4209300';
	vv_padrao      := 'Betha Sistemas';     
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
			raise_application_error(-20103, 'Erro no script Redmine #76409 Atualização do Padrão Lages - SC' || sqlerrm);
    end;
	--
	commit;
	--
--
end;
--
/  

-------------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #76409 Criação de padrão betha a adição de Lages - SC ao padrão
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #76469 Criação de padrão Fiorilli a adição de Ji Parana - RO ao padrão
-------------------------------------------------------------------------------------------------------------------------------------------
--
--CIDADE  : Ji Parana - RO
--IBGE    : 1100122
--PADRAO  : Fiorilli
--HABIL   : SIM
--WS_CANC : SIM

declare 
   --   
   -- dm_tp_amb (Tipo de Ambiente 1-Producao; 2-Homologacao)
   cursor c_dados is
      select   ( select id from csf_own.cidade where ibge_cidade = '1100122' ) id, dm_situacao,  versao,  dm_tp_amb,  dm_tp_soap,  dm_tp_serv, descr, url_wsdl, dm_upload, dm_ind_emit 
        from ( --Produção
			   select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  1 dm_tp_serv, 'Geração de NFS-e'                               descr, 'http://177.124.184.59:5660/IssWeb-ejb/IssWebWS/IssWebWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  2 dm_tp_serv, 'Recepção e Processamento de lote de RPS'        descr, 'http://177.124.184.59:5660/IssWeb-ejb/IssWebWS/IssWebWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  3 dm_tp_serv, 'Consulta de Situação de lote de RPS'            descr, 'http://177.124.184.59:5660/IssWeb-ejb/IssWebWS/IssWebWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  4 dm_tp_serv, 'Consulta de NFS-e por RPS'                      descr, 'http://177.124.184.59:5660/IssWeb-ejb/IssWebWS/IssWebWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  5 dm_tp_serv, 'Consulta de NFS-e'                              descr, 'http://177.124.184.59:5660/IssWeb-ejb/IssWebWS/IssWebWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  6 dm_tp_serv, 'Cancelamento de NFS-e'                          descr, 'http://177.124.184.59:5660/IssWeb-ejb/IssWebWS/IssWebWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  7 dm_tp_serv, 'Substituição de NFS-e'                          descr, 'http://177.124.184.59:5660/IssWeb-ejb/IssWebWS/IssWebWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  8 dm_tp_serv, 'Consulta de Empresas Autorizadas a emitir NFS-e'descr, 'http://177.124.184.59:5660/IssWeb-ejb/IssWebWS/IssWebWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  9 dm_tp_serv, 'Login'                                          descr, 'http://177.124.184.59:5660/IssWeb-ejb/IssWebWS/IssWebWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap, 10 dm_tp_serv, 'Consulta de Lote de RPS'                        descr, 'http://177.124.184.59:5660/IssWeb-ejb/IssWebWS/IssWebWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               --Homologação
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  1 dm_tp_serv, 'Geração de NFS-e'                               descr, 'http://fi1.fiorilli.com.br:5663/IssWeb-ejb/IssWebWS/IssWebWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  2 dm_tp_serv, 'Recepção e Processamento de lote de RPS'        descr, 'http://fi1.fiorilli.com.br:5663/IssWeb-ejb/IssWebWS/IssWebWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  3 dm_tp_serv, 'Consulta de Situação de lote de RPS'            descr, 'http://fi1.fiorilli.com.br:5663/IssWeb-ejb/IssWebWS/IssWebWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  4 dm_tp_serv, 'Consulta de NFS-e por RPS'                      descr, 'http://fi1.fiorilli.com.br:5663/IssWeb-ejb/IssWebWS/IssWebWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  5 dm_tp_serv, 'Consulta de NFS-e'                              descr, 'http://fi1.fiorilli.com.br:5663/IssWeb-ejb/IssWebWS/IssWebWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  6 dm_tp_serv, 'Cancelamento de NFS-e'                          descr, 'http://fi1.fiorilli.com.br:5663/IssWeb-ejb/IssWebWS/IssWebWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  7 dm_tp_serv, 'Substituição de NFS-e'                          descr, 'http://fi1.fiorilli.com.br:5663/IssWeb-ejb/IssWebWS/IssWebWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  8 dm_tp_serv, 'Consulta de Empresas Autorizadas a emitir NFS-e'descr, 'http://fi1.fiorilli.com.br:5663/IssWeb-ejb/IssWebWS/IssWebWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  9 dm_tp_serv, 'Login'                                          descr, 'http://fi1.fiorilli.com.br:5663/IssWeb-ejb/IssWebWS/IssWebWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap, 10 dm_tp_serv, 'Consulta de Lote de RPS'                        descr, 'http://fi1.fiorilli.com.br:5663/IssWeb-ejb/IssWebWS/IssWebWS?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual
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
                  raise_application_error(-20101, 'Erro no script Redmine #76469 Atualização URL ambiente de homologação e Produção Ji Parana - RO' || sqlerrm);
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
      raise_application_error(-20102, 'Erro no script Redmine #76469 Atualização URL ambiente de homologação e Produção Ji Parana - RO' || sqlerrm);
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
	vv_ibge_cidade := '1100122';
	vv_padrao      := 'Fiorilli';     
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
			raise_application_error(-20103, 'Erro no script Redmine #76469 Atualização do Padrão Ji Parana - RO' || sqlerrm);
    end;
	--
	commit;
	--
--
end;
--
/  

-------------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #76469 Criação de padrão Fiorilli a adição de Ji Parana - RO ao padrão
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #76568 Criação de padrão betha a adição de PASSO FUNDO - RS ao padrão
-------------------------------------------------------------------------------------------------------------------------------------------
--
--CIDADE  : PASSO FUNDO - RS
--IBGE    : 4314100
--PADRAO  : Thema
--HABIL   : SIM
--WS_CANC : SIM

declare 
   --   
   -- dm_tp_amb (Tipo de Ambiente 1-Producao; 2-Homologacao)
   cursor c_dados is
      select   ( select id from csf_own.cidade where ibge_cidade = '4314100' ) id, dm_situacao,  versao,  dm_tp_amb,  dm_tp_soap,  dm_tp_serv, descr, url_wsdl, dm_upload, dm_ind_emit 
        from ( --Produção
			   select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  1 dm_tp_serv, 'Geração de NFS-e'                               descr, 'http://hmlnfse.pmpf.rs.gov.br/thema-nfse/services/NFSEremessa?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  2 dm_tp_serv, 'Recepção e Processamento de lote de RPS'        descr, 'http://hmlnfse.pmpf.rs.gov.br/thema-nfse/services/NFSEremessa?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  3 dm_tp_serv, 'Consulta de Situação de lote de RPS'            descr, 'http://hmlnfse.pmpf.rs.gov.br/thema-nfse/services/NFSEconsulta?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  4 dm_tp_serv, 'Consulta de NFS-e por RPS'                      descr, 'http://hmlnfse.pmpf.rs.gov.br/thema-nfse/services/NFSEconsulta?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  5 dm_tp_serv, 'Consulta de NFS-e'                              descr, 'http://hmlnfse.pmpf.rs.gov.br/thema-nfse/services/NFSEconsulta?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  6 dm_tp_serv, 'Cancelamento de NFS-e'                          descr, 'http://hmlnfse.pmpf.rs.gov.br/thema-nfse/services/NFSEcancelamento?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  7 dm_tp_serv, 'Substituição de NFS-e'                          descr, 'http://hmlnfse.pmpf.rs.gov.br/thema-nfse/services/NFSEremessa?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  8 dm_tp_serv, 'Consulta de Empresas Autorizadas a emitir NFS-e'descr, 'http://hmlnfse.pmpf.rs.gov.br/thema-nfse/services/NFSEdadosCadastrais?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap,  9 dm_tp_serv, 'Login'                                          descr, 'http://hmlnfse.pmpf.rs.gov.br/thema-nfse/services/NFSEconsulta?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 1 dm_tp_amb, 2 dm_tp_soap, 10 dm_tp_serv, 'Consulta de Lote de RPS'                        descr, 'http://hmlnfse.pmpf.rs.gov.br/thema-nfse/services/NFSEconsulta?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               --Homologação
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  1 dm_tp_serv, 'Geração de NFS-e'                               descr, 'http://hmlnfse.pmpf.rs.gov.br/thema-nfse/services/NFSEremessa?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  2 dm_tp_serv, 'Recepção e Processamento de lote de RPS'        descr, 'http://hmlnfse.pmpf.rs.gov.br/thema-nfse/services/NFSEremessa?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  3 dm_tp_serv, 'Consulta de Situação de lote de RPS'            descr, 'http://hmlnfse.pmpf.rs.gov.br/thema-nfse/services/NFSEconsulta?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  4 dm_tp_serv, 'Consulta de NFS-e por RPS'                      descr, 'http://hmlnfse.pmpf.rs.gov.br/thema-nfse/services/NFSEconsulta?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  5 dm_tp_serv, 'Consulta de NFS-e'                              descr, 'http://hmlnfse.pmpf.rs.gov.br/thema-nfse/services/NFSEconsulta?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  6 dm_tp_serv, 'Cancelamento de NFS-e'                          descr, 'http://hmlnfse.pmpf.rs.gov.br/thema-nfse/services/NFSEcancelamento?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  7 dm_tp_serv, 'Substituição de NFS-e'                          descr, 'http://hmlnfse.pmpf.rs.gov.br/thema-nfse/services/NFSEremessa?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  8 dm_tp_serv, 'Consulta de Empresas Autorizadas a emitir NFS-e'descr, 'http://hmlnfse.pmpf.rs.gov.br/thema-nfse/services/NFSEdadosCadastrais?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap,  9 dm_tp_serv, 'Login'                                          descr, 'http://hmlnfse.pmpf.rs.gov.br/thema-nfse/services/NFSEconsulta?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual union
               select 1 dm_situacao, '1' versao, 2 dm_tp_amb, 2 dm_tp_soap, 10 dm_tp_serv, 'Consulta de Lote de RPS'                        descr, 'http://hmlnfse.pmpf.rs.gov.br/thema-nfse/services/NFSEconsulta?wsdl' url_wsdl, 0 dm_upload,  0 dm_ind_emit from dual
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
                  raise_application_error(-20101, 'Erro no script Redmine #76568 Atualização URL ambiente de homologação e Produção PASSO FUNDO - RS' || sqlerrm);
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
      raise_application_error(-20102, 'Erro no script Redmine #76568 Atualização URL ambiente de homologação e Produção PASSO FUNDO - RS' || sqlerrm);
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
	vv_ibge_cidade := '4314100';
	vv_padrao      := 'Thema';     
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
			raise_application_error(-20103, 'Erro no script Redmine #76568 Atualização do Padrão PASSO FUNDO - RS' || sqlerrm);
    end;
	--
	commit;
	--
--
end;
--
/  

-------------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #76568 Criação de padrão betha a adição de PASSO FUNDO - RS ao padrão
-------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #76385 - Inclus?da sequence ctdifaliq_seq na seq_tab
--------------------------------------------------------------------------------------------------------------------------------------
declare
  --
  vv_sql    long;
  vn_existe number := 0;
  --
begin
   BEGIN
    SELECT COUNT(1)
        INTO vn_existe
      FROM CSF_OWN.SEQ_TAB
     WHERE UPPER(SEQUENCE_NAME) = UPPER('ctdifaliq_seq');
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
          VALUES (CSF_OWN.SEQTAB_SEQ.NEXTVAL, 'ctdifaliq_seq', 'CT_DIF_ALIQ');
          COMMIT;   
    EXCEPTION 
     WHEN OTHERS THEN
      NULL;
    END;
  END IF;
   --
end;
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #76385 - Inclus?da sequence ctdifaliq_seq na seq_tab
-------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
Prompt Inicio Redmine #75742: Customização ACG.
---------------------------------------------------------------------------------------------------------


declare
vn_count number;
begin
  ---
  vn_count:=0;
  --
  -- valida se ja existe a coluna na tabela PARAM_GERA_INF_PROV_DOC_FISC, senao existir, cria.
  BEGIN
    SELECT count(1) 
        into vn_count
      FROM ALL_TAB_COLUMNS
     WHERE UPPER(OWNER)       = UPPER('CSF_OWN')
       AND UPPER(TABLE_NAME)  = UPPER('PARAM_GERA_INF_PROV_DOC_FISC')
       AND UPPER(COLUMN_NAME) = UPPER('ORIG');
    exception
    when others then
      vn_count:=0;
  end;
  ---
  if  vn_count = 0 then
   begin 
      EXECUTE IMMEDIATE 'ALTER TABLE CSF_OWN.PARAM_GERA_INF_PROV_DOC_FISC ADD ORIG NUMBER(1)';
      EXECUTE IMMEDIATE 'comment on column CSF_OWN.PARAM_GERA_INF_PROV_DOC_FISC.ORIG  is ''Origem da mercadoria''';
    exception
    when others then
      null;
  end;
  --
 end if;
 --
 end;
/

declare
vn_count number;
begin
  ---
  vn_count:=0;
  ---
  begin
    select count(1) into vn_count
    from all_constraints a
    where a.owner         ='CSF_OWN'
    and a.table_name      ='PARAM_GERA_INF_PROV_DOC_FISC'
    and a.constraint_name ='INFPROVDOCFISC_ORIG_CK';
  exception
    when others then
      vn_count:=0;
  end;
  ---
  if  vn_count = 0 then
   begin
    execute immediate 'alter table CSF_OWN.PARAM_GERA_INF_PROV_DOC_FISC add constraint INFPROVDOCFISC_ORIG_CK check (ORIG in (0, 1, 2, 3, 4, 5, 6, 7, 8))';
    exception
    when others then
      null;
   end;
  end if;
  ---
  commit;
end;
/

 

declare
vn_count number;
begin
  ---
  vn_count:=0;
  ---
BEGIN
  --
  -- valida se ja existe a coluna na tabela PARAM_GERA_INF_PROV_DOC_FISC, senao existir, cria.
    SELECT  count(1) 
        into vn_count
      FROM ALL_TAB_COLUMNS
     WHERE UPPER(OWNER)       = UPPER('CSF_OWN')
       AND UPPER(TABLE_NAME)  = UPPER('PARAM_GERA_REG_SUB_APUR_ICMS')
       AND UPPER(COLUMN_NAME) = UPPER('ORIG');
    exception
    when others then
      vn_count:=0;
  end;
  ---
  if  vn_count = 0 then
   begin 
      EXECUTE IMMEDIATE 'ALTER TABLE CSF_OWN.PARAM_GERA_REG_SUB_APUR_ICMS ADD ORIG NUMBER(1)';
      EXECUTE IMMEDIATE 'comment on column CSF_OWN.PARAM_GERA_REG_SUB_APUR_ICMS.ORIG  is ''Origem da mercadoria''';
    exception
    when others then
      null;
  end;
  --
  end if;
  --
END;
/
 
 

declare
vn_count number;
begin
  ---
  vn_count:=0;
  ---
  begin
    select count(1) into vn_count
    from all_constraints a
    where a.owner         ='CSF_OWN'
    and a.table_name      ='PARAM_GERA_REG_SUB_APUR_ICMS'
    and a.constraint_name ='REGSUBAPURICMS_ORIG_CK';
  exception
    when others then
      vn_count:=0;
  end;
  ---
  if  vn_count = 0 then
   begin
    execute immediate 'alter table CSF_OWN.PARAM_GERA_REG_SUB_APUR_ICMS add constraint REGSUBAPURICMS_ORIG_CK check (ORIG in (0, 1, 2, 3, 4, 5, 6, 7, 8))';
    exception
    when others then
      null;
   end;
  end if;
  ---
  commit;
end;
/ 
 

--retirar UK da tabela  
declare
  v_existe  number := 0 ;
begin
  --
  begin
    -- verifica se existe uk
     select 1
       into v_existe
       from all_constraints a
      where upper(a.OWNER) = upper('CSF_OWN')
        and upper(a.TABLE_NAME) = upper('PARAM_GERA_REG_SUB_APUR_ICMS')
        and upper(a.CONSTRAINT_NAME) = upper('PARAMGERRSAI_CFOPCSTPER_UK');
    --
  exception
    when others then
      v_existe := 0 ;
  end ;
  --
  -- se existir dropa ela
  if v_existe > 0 then
    --
    begin
      execute immediate 'ALTER TABLE CSF_OWN.PARAM_GERA_REG_SUB_APUR_ICMS DROP CONSTRAINT PARAMGERRSAI_CFOPCSTPER_UK';
    exception
     when others then
       raise_application_error(-20101, 'Erro ao excluir constraint no script 75742 Customização ACG - ' || sqlerrm);
    end ;
    --
  end if;
  --
     -- cria novamente com o campo ORI
    begin
      execute immediate 'alter table CSF_OWN.PARAM_GERA_REG_SUB_APUR_ICMS
  add constraint PARAMGERRSAI_CFOPCSTPER_UK unique (EMPRESA_ID, CFOP_ID, CODST_ID, ALIQ_ICMS, ORIG)
  using index tablespace CSF_DATA';
    exception
     when others then
       raise_application_error(-20101, 'Erro ao excluir constraint no script 75742 Customização ACG - ' || sqlerrm);
    end ;

end;
/
  
  
--retirar UK da tabela  
declare
  v_existe  number := 0 ;
begin
  --
  begin
    -- verifica se existe uk
     select 1
       into v_existe
       from all_constraints a
      where upper(a.OWNER) = upper('CSF_OWN')
        and upper(a.TABLE_NAME) = upper('PARAM_GERA_INF_PROV_DOC_FISC')
        and upper(a.CONSTRAINT_NAME) = upper('PARAMGERAIPDF_CFOPCSTPER_UK');
    --
  exception
    when others then
      v_existe := 0 ;
  end ;
  --
  -- se existir dropa ela
  if v_existe > 0 then
    --
    begin
      execute immediate 'ALTER TABLE CSF_OWN.PARAM_GERA_INF_PROV_DOC_FISC DROP CONSTRAINT PARAMGERAIPDF_CFOPCSTPER_UK';
    exception
     when others then
       raise_application_error(-20101, 'Erro ao excluir constraint no script 75742 Customização ACG - ' || sqlerrm);
    end ;
    --
  end if;
    -- cria novamente com o campo ORI
    begin
      execute immediate 'alter table CSF_OWN.PARAM_GERA_INF_PROV_DOC_FISC
  add constraint PARAMGERAIPDF_CFOPCSTPER_UK unique (EMPRESA_ID, CFOP_ID, CODST_ID, ALIQ_ICMS, ORIG)
  using index tablespace CSF_DATA';
    exception
     when others then
       raise_application_error(-20101, 'Erro ao excluir constraint no script 75742 Customização ACG - ' || sqlerrm);
    end ;
  --
end;
/

---------------------------------------------------------------------------------------------------------
Prompt Inicio Redmine #75742: Customização ACG.
---------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine  #76108 - Novo processo de integra��o contabil
-------------------------------------------------------------------------------------------------------------------------------------
declare
   vn_existe number := null;
begin
   select count(*)
     into vn_existe
     from sys.all_tables
    where OWNER       = 'CSF_OWN'
      and TABLE_NAME  = 'TMP_TIPO_CTRL_ARQ';
   --
   if nvl(vn_existe,0) = 0 then
      --
      execute immediate 'create table csf_own.TMP_TIPO_CTRL_ARQ
                                      (
                                        ID              NUMBER,
                                        TP_REGISTRO     NUMBER,
                                        CD_MULTORG      VARCHAR2(10),
                                        HASH_MULTORG    VARCHAR2(255),
                                        NM_OBJ_INT      VARCHAR2(30),
                                        VERSAO_LAYOUT   NUMBER(4),
                                        DT_ARQUIVO      DATE,
                                        IDENT_UNICO_ARQ NUMBER(10),
                                        NM_MAX_IDENT    NUMBER(10)
                                      ) tablespace CSF_DATA';
      --
      execute immediate 'comment on table  CSF_OWN.TMP_TIPO_CTRL_ARQ                 is ''REGISTRO TIPO CONTROLE DO ARQUIVO''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_CTRL_ARQ.ID              is ''ID da tabela TMP_TIPO_CTRL_ARQ''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_CTRL_ARQ.TP_REGISTRO     is ''Tipo do registro''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_CTRL_ARQ.CD_MULTORG      is ''Código do MultOrg''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_CTRL_ARQ.HASH_MULTORG    is ''Hash do MultOrg''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_CTRL_ARQ.NM_OBJ_INT      is ''Nome do objeto de integração: SALDO; LANCAMENTO; PARTIDA; PLANOCONTA''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_CTRL_ARQ.VERSAO_LAYOUT   is ''Versão do layout. Fixo 1''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_CTRL_ARQ.DT_ARQUIVO      is ''Data do arquivo. Data em que arquivo foi gerado''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_CTRL_ARQ.IDENT_UNICO_ARQ is ''Identificador único do arquivo.ID sequencial único que permite rastrear os arquivos e também saber o estágio da integração''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_CTRL_ARQ.NM_MAX_IDENT    is ''Numero máximo do identificador.ID do futuro ultimo arquivo para permitir saber em que momento deve ser iniciada a validação de dados.''';
      --
      execute immediate 'create index CSF_OWN.TMP_TIPO_CTRL_ARQ_IDX on CSF_OWN.TMP_TIPO_CTRL_ARQ (ID) tablespace CSF_INDEX';
      --
      execute immediate 'grant select, insert, update, delete on CSF_OWN.TMP_TIPO_CTRL_ARQ to CSF_WORK';
      --
   else
      --
      execute immediate 'comment on table  CSF_OWN.TMP_TIPO_CTRL_ARQ                 is ''REGISTRO TIPO CONTROLE DO ARQUIVO''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_CTRL_ARQ.ID              is ''ID da tabela TMP_TIPO_CTRL_ARQ''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_CTRL_ARQ.TP_REGISTRO     is ''Tipo do registro''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_CTRL_ARQ.CD_MULTORG      is ''Código do MultOrg''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_CTRL_ARQ.HASH_MULTORG    is ''Hash do MultOrg''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_CTRL_ARQ.NM_OBJ_INT      is ''Nome do objeto de integração: SALDO; LANCAMENTO; PARTIDA; PLANOCONTA''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_CTRL_ARQ.VERSAO_LAYOUT   is ''Versão do layout. Fixo 1''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_CTRL_ARQ.DT_ARQUIVO      is ''Data do arquivo. Data em que arquivo foi gerado''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_CTRL_ARQ.IDENT_UNICO_ARQ is ''Identificador único do arquivo.ID sequencial único que permite rastrear os arquivos e também saber o estágio da integração''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_CTRL_ARQ.NM_MAX_IDENT    is ''Numero máximo do identificador.ID do futuro ultimo arquivo para permitir saber em que momento deve ser iniciada a validação de dados.''';
      --
      execute immediate 'grant select, insert, update, delete on CSF_OWN.TMP_TIPO_CTRL_ARQ to CSF_WORK';
      --
   end if;
   --
   commit;
exception
   when others then
      raise_application_error(-20001, 'Erro no script 76108. Criacao da tabela TMP_TIPO_CTRL_ARQ. Erro: ' || sqlerrm);
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
      and s.SEQUENCE_NAME  = 'TMPTPCTRLARQ_SEQ';
   --
   if nvl(vn_existe,0) = 0 then
      --
      execute immediate 'create sequence CSF_OWN.TMPTPCTRLARQ_SEQ minvalue 1 maxvalue 9999999999999999999999999999 start with 1 increment by 1 nocache';
      execute immediate 'grant select on CSF_OWN.TMPTPCTRLARQ_SEQ to CSF_WORK';
      --
   elsif nvl(vn_existe,0) > 0 then
      --
      execute immediate 'grant select on CSF_OWN.TMPTPCTRLARQ_SEQ to CSF_WORK';
      --
   end if;
   --
   commit;
exception
   when others then
      raise_application_error(-20001, 'Erro no script 76108. Criacao da sequence TMPTPCTRLARQ_SEQ. Erro: ' || sqlerrm);
end;
/

declare
  --
  vv_sql    long;
  vn_existe number := 0;
  --
begin
   BEGIN
        SELECT COUNT(1)
	INTO vn_existe
	FROM CSF_OWN.SEQ_TAB
	WHERE UPPER(SEQUENCE_NAME) = UPPER('TMPTPCTRLARQ_SEQ');
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
          VALUES (CSF_OWN.SEQTAB_SEQ.NEXTVAL, 'TMPTPCTRLARQ_SEQ', 'TMP_TIPO_CTRL_ARQ');
          COMMIT;
 	EXCEPTION
	 WHEN OTHERS THEN
	  NULL;
	END;
    END IF;
    --
end;
/

declare
   vn_existe number := null;
begin
   select count(*)
     into vn_existe
     from sys.all_tables
    where OWNER       = 'CSF_OWN'
      and TABLE_NAME  = 'TMP_CAB_SALDO';
   --
   if nvl(vn_existe,0) = 0 then
      --
      execute immediate 'create table csf_own.TMP_CAB_SALDO
                            (
                              ID                NUMBER,
                              TMPTIPOCTRLARQ_ID NUMBER,
                              TP_REGISTRO       NUMBER,
                              CNPJ_EMPRESA      VARCHAR2(14),
                              DT_INICIAL        DATE,
                              DT_FINAL          DATE
                            ) tablespace CSF_DATA';
      --
      execute immediate 'comment on table  csf_own.TMP_CAB_SALDO                   is ''REGISTRO TIPO CABEÇALHO DO SALDO''';
      execute immediate 'comment on column csf_own.TMP_CAB_SALDO.ID                is ''ID da tabela TMP_CAB_SALDO''';
      execute immediate 'comment on column csf_own.TMP_CAB_SALDO.TMPTIPOCTRLARQ_ID is ''ID da tabela TMP_TIPO_CTRL_ARQ''';
      execute immediate 'comment on column csf_own.TMP_CAB_SALDO.TP_REGISTRO       is ''Tipo do registro. Fixo 1.''';
      execute immediate 'comment on column csf_own.TMP_CAB_SALDO.CNPJ_EMPRESA      is ''CNPJ da empresa. CNPJ com 14 dígitos (considerar 0 a esquerda)''';
      execute immediate 'comment on column csf_own.TMP_CAB_SALDO.DT_INICIAL        is ''Data inicial do Saldo''';
      execute immediate 'comment on column csf_own.TMP_CAB_SALDO.DT_FINAL          is ''Data final do saldo''';
      --
      execute immediate 'create index CSF_OWN.TMP_CAB_SALDO_IDX1 on CSF_OWN.TMP_CAB_SALDO (ID)                   tablespace CSF_INDEX';
      execute immediate 'create index CSF_OWN.TMP_CAB_SALDO_IDX2 on CSF_OWN.TMP_CAB_SALDO (TMPTIPOCTRLARQ_ID)    tablespace CSF_INDEX';
      execute immediate 'create index CSF_OWN.TMP_CAB_SALDO_IDX3 on CSF_OWN.TMP_CAB_SALDO (DT_INICIAL, DT_FINAL) tablespace CSF_INDEX';
      --
      execute immediate 'grant select, insert, update, delete on CSF_OWN.TMP_CAB_SALDO to CSF_WORK';
      --
   else
      --
      execute immediate 'comment on table  csf_own.TMP_CAB_SALDO                   is ''REGISTRO TIPO CABEÇALHO DO SALDO''';
      execute immediate 'comment on column csf_own.TMP_CAB_SALDO.ID                is ''ID da tabela TMP_CAB_SALDO''';
      execute immediate 'comment on column csf_own.TMP_CAB_SALDO.TMPTIPOCTRLARQ_ID is ''ID da tabela TMP_TIPO_CTRL_ARQ''';
      execute immediate 'comment on column csf_own.TMP_CAB_SALDO.TP_REGISTRO       is ''Tipo do registro. Fixo 1.''';
      execute immediate 'comment on column csf_own.TMP_CAB_SALDO.CNPJ_EMPRESA      is ''CNPJ da empresa. CNPJ com 14 dígitos (considerar 0 a esquerda)''';
      execute immediate 'comment on column csf_own.TMP_CAB_SALDO.DT_INICIAL        is ''Data inicial do Saldo''';
      execute immediate 'comment on column csf_own.TMP_CAB_SALDO.DT_FINAL          is ''Data final do saldo''';
      --
      execute immediate 'grant select, insert, update, delete on CSF_OWN.TMP_CAB_SALDO to CSF_WORK';
      --
   end if;
   --
   commit;
exception
   when others then
      raise_application_error(-20001, 'Erro no script 76108. Criacao da tabela TMP_CAB_SALDO. Erro: ' || sqlerrm);
end;
/

declare
   vn_existe number := null;
begin
   select count(*)
     into vn_existe
     from sys.all_sequences s
    where s.SEQUENCE_OWNER = 'CSF_OWN'
      and s.SEQUENCE_NAME  = 'TMPCABSALDO_SEQ';
   --
   if nvl(vn_existe,0) = 0 then
      --
      execute immediate 'create sequence CSF_OWN.TMPCABSALDO_SEQ minvalue 1 maxvalue 9999999999999999999999999999 start with 1 increment by 1 nocache';
      execute immediate 'grant select on CSF_OWN.TMPCABSALDO_SEQ to CSF_WORK';
      --
   elsif nvl(vn_existe,0) > 0 then
      --
      execute immediate 'grant select on CSF_OWN.TMPCABSALDO_SEQ to CSF_WORK';
      --
   end if;
   --
   commit;
exception
   when others then
      raise_application_error(-20001, 'Erro no script 76108. Criacao da sequence TMPCABSALDO_SEQ. Erro: ' || sqlerrm);
end;
/

declare
  --
  vv_sql    long;
  vn_existe number := 0;
  --
begin
   BEGIN
   SELECT COUNT(1)
     INTO vn_existe
     FROM CSF_OWN.SEQ_TAB
     WHERE UPPER(SEQUENCE_NAME) = UPPER('TMPCABSALDO_SEQ');
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
        VALUES (CSF_OWN.SEQTAB_SEQ.NEXTVAL, 'TMPCABSALDO_SEQ', 'TMP_CAB_SALDO');
      COMMIT;
      EXCEPTION
      WHEN OTHERS THEN
      NULL;
    END;
   END IF;
   --
end;
/

declare
   vn_existe number := null;
begin 
   select count(*)
     into vn_existe
     from sys.all_tables 
    where OWNER       = 'CSF_OWN'
      and TABLE_NAME  = 'TMP_TIPO_DET_SALDO';
   --
   if nvl(vn_existe,0) = 0 then
      --
      execute immediate 'create table csf_own.TMP_TIPO_DET_SALDO
                                      (
                                        ID             NUMBER,
                                        TMPCABSALDO_ID NUMBER,
                                        TP_REGISTO     NUMBER,
                                        COD_CTA        VARCHAR2(255),
                                        COD_CCUS       VARCHAR2(60),
                                        VL_SLD_INI     NUMBER(19,2),
                                        DM_IND_DC_INI  VARCHAR2(1),
                                        VL_DEB         NUMBER(19,2),
                                        VL_CRED        NUMBER(19,2),
                                        VL_SLD_FIN     NUMBER(19,2),
                                        DM_IND_DC_FIN  VARCHAR2(1)
                                      )
                                      tablespace CSF_DATA';
      --                                                        
      execute immediate 'comment on table CSF_OWN.TMP_TIPO_DET_SALDO is ''REGISTRO TIPO DETALHE DO SALDO''';
      -- 
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_DET_SALDO.ID  is ''ID da tabela TMP_TIPO_DET_SALDO''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_DET_SALDO.TMPCABSALDO_ID  is ''ID da tabela TMP_CAB_SALDO''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_DET_SALDO.TP_REGISTO  is ''Tipo do registro. Fixo 5.''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_DET_SALDO.COD_CTA  is ''Código da Conta contabil''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_DET_SALDO.COD_CCUS  is ''Código do centro de custos''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_DET_SALDO.VL_SLD_INI  is ''Valor do Saldo Inicial''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_DET_SALDO.DM_IND_DC_INI  is ''Indicador de situação do saldo inicial - D ou C. D = Débito / C = Crédito.''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_DET_SALDO.VL_DEB  is ''Valor do saldo a débito''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_DET_SALDO.VL_CRED  is ''Valor do saldo a crédito''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_DET_SALDO.VL_SLD_FIN  is ''Valor do Saldo Final''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_DET_SALDO.DM_IND_DC_FIN  is ''Indicador de situação do saldo final - D ou C. D = Débito / C = Crédito.''';
      -- 
      execute immediate 'create index CSF_OWN.TMP_TIPO_DET_SALDO_IDX1 on CSF_OWN.TMP_TIPO_DET_SALDO (ID)  tablespace CSF_INDEX';
      execute immediate 'create index CSF_OWN.TMP_TIPO_DET_SALDO_IDX2 on CSF_OWN.TMP_TIPO_DET_SALDO (TMPCABSALDO_ID) tablespace CSF_INDEX';
      execute immediate 'create index CSF_OWN.TMP_TIPO_DET_SALDO_IDX3 on CSF_OWN.TMP_TIPO_DET_SALDO (TP_REGISTO, COD_CTA, COD_CCUS) tablespace CSF_INDEX';
      
      execute immediate 'grant select, insert, update, delete on CSF_OWN.TMP_TIPO_DET_SALDO to CSF_WORK';
      --    
   else
      --
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_DET_SALDO.ID  is ''ID da tabela TMP_TIPO_DET_SALDO''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_DET_SALDO.TMPCABSALDO_ID  is ''ID da tabela TMP_CAB_SALDO''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_DET_SALDO.TP_REGISTO  is ''Tipo do registro. Fixo 5.''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_DET_SALDO.COD_CTA  is ''Código da Conta contabil''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_DET_SALDO.COD_CCUS  is ''Código do centro de custos''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_DET_SALDO.VL_SLD_INI  is ''Valor do Saldo Inicial''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_DET_SALDO.DM_IND_DC_INI  is ''Indicador de situação do saldo inicial - D ou C. D = Débito / C = Crédito.''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_DET_SALDO.VL_DEB  is ''Valor do saldo a débito''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_DET_SALDO.VL_CRED  is ''Valor do saldo a crédito''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_DET_SALDO.VL_SLD_FIN  is ''Valor do Saldo Final''';
      execute immediate 'comment on column CSF_OWN.TMP_TIPO_DET_SALDO.DM_IND_DC_FIN  is ''Indicador de situação do saldo final - D ou C. D = Débito / C = Crédito.''';
      -- 
      execute immediate 'grant select, insert, update, delete on CSF_OWN.TMP_TIPO_DET_SALDO to CSF_WORK';
      --    
   end if;
   --
   commit;
exception
   when others then
      raise_application_error(-20001, 'Erro no script 76108. Criacao da tabela TMP_TIPO_DET_SALDO. Erro: ' || sqlerrm);      
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
      and s.SEQUENCE_NAME  = 'TMPTPDETSLD_SEQ';
   --
   if nvl(vn_existe,0) = 0 then
      --
      execute immediate 'create sequence CSF_OWN.TMPTPDETSLD_SEQ minvalue 1 maxvalue 9999999999999999999999999999 start with 1 increment by 1 nocache';
      execute immediate 'grant select on CSF_OWN.TMPTPDETSLD_SEQ to CSF_WORK';      
      --
   elsif nvl(vn_existe,0) > 0 then
      --
      execute immediate 'grant select on CSF_OWN.TMPTPDETSLD_SEQ to CSF_WORK';      
      --
   end if;   
   --
   commit;
exception
   when others then
      raise_application_error(-20001, 'Erro no script 76108. Criacao da sequence TMPTPDETSLD_SEQ. Erro: ' || sqlerrm);      
end;
/

declare
  --
  vv_sql    long;
  vn_existe number := 0;
  --
begin
    BEGIN
      SELECT COUNT(1)
      INTO vn_existe
	  FROM CSF_OWN.SEQ_TAB
	 WHERE UPPER(SEQUENCE_NAME) = UPPER('TMPTPDETSLD_SEQ');
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
      VALUES (CSF_OWN.SEQTAB_SEQ.NEXTVAL, 'TMPTPDETSLD_SEQ', 'TMP_TIPO_DET_SALDO');
      COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
     END;
    END IF;
   --
   commit;
end;
/

declare
   vn_existe number := null;
begin 
   select count(*)
     into vn_existe
     from sys.all_tables 
    where OWNER       = 'CSF_OWN'
      and TABLE_NAME  = 'TMP_CAB_LANCTO';
   --
   if nvl(vn_existe,0) = 0 then
      --
      execute immediate 'create table csf_own.TMP_CAB_LANCTO
                                      (
                                        ID                NUMBER,
                                        TMPTIPOCTRLARQ_ID NUMBER,
                                        TP_REGISTRO       NUMBER,
                                        CNPJ_EMPRESA      VARCHAR2(14)
                                       ) tablespace CSF_DATA';
      --                                                        
      execute immediate 'comment on table  CSF_OWN.TMP_CAB_LANCTO                   is ''REGISTRO TIPO CABEÇALHO DO LANÇAMENTO''';
      --       
      execute immediate 'comment on column CSF_OWN.TMP_CAB_LANCTO.ID                is ''ID da tabela TMP_CAB_LANCTO''';
      execute immediate 'comment on column CSF_OWN.TMP_CAB_LANCTO.TMPTIPOCTRLARQ_ID is ''ID da tabela TMP_TIPO_DET_SALDO''';
      execute immediate 'comment on column CSF_OWN.TMP_CAB_LANCTO.TP_REGISTRO       is ''Tipo do registro. Fixo 1.''';
      execute immediate 'comment on column CSF_OWN.TMP_CAB_LANCTO.CNPJ_EMPRESA      is ''CNPJ da empresa. CNPJ com 14 dígitos (considerar 0 a esquerda).''';      
      ---      
      execute immediate 'create index CSF_OWN.TMP_CAB_LANCTO_IDX1 on CSF_OWN.TMP_CAB_LANCTO (ID)                tablespace CSF_INDEX';
      execute immediate 'create index CSF_OWN.TMP_CAB_LANCTO_IDX2 on CSF_OWN.TMP_CAB_LANCTO (TMPTIPOCTRLARQ_ID) tablespace CSF_INDEX';      
      ---      
    
      execute immediate 'grant select, insert, update, delete on CSF_OWN.TMP_CAB_LANCTO to CSF_WORK';
      --    
   else
      --
      execute immediate 'comment on table  CSF_OWN.TMP_CAB_LANCTO                   is ''REGISTRO TIPO CABEÇALHO DO LANÇAMENTO''';
      --       
      execute immediate 'comment on column CSF_OWN.TMP_CAB_LANCTO.ID                is ''ID da tabela TMP_CAB_LANCTO''';
      execute immediate 'comment on column CSF_OWN.TMP_CAB_LANCTO.TMPTIPOCTRLARQ_ID is ''ID da tabela TMP_TIPO_DET_SALDO''';
      execute immediate 'comment on column CSF_OWN.TMP_CAB_LANCTO.TP_REGISTRO       is ''Tipo do registro. Fixo 1.''';
      execute immediate 'comment on column CSF_OWN.TMP_CAB_LANCTO.CNPJ_EMPRESA      is ''CNPJ da empresa. CNPJ com 14 dígitos (considerar 0 a esquerda).''';      
      --- 
      execute immediate 'grant select, insert, update, delete on CSF_OWN.TMP_CAB_LANCTO to CSF_WORK';
      --    
   end if;
   --
   commit;
exception
   when others then
      raise_application_error(-20001, 'Erro no script 76108. Criacao da tabela TMP_CAB_LANCTO. Erro: ' || sqlerrm);      
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
      and s.SEQUENCE_NAME  = 'TMPCABLANCTO_SEQ';
   --
   if nvl(vn_existe,0) = 0 then
      --
      execute immediate 'create sequence CSF_OWN.TMPCABLANCTO_SEQ minvalue 1 maxvalue 9999999999999999999999999999 start with 1 increment by 1 nocache';
      execute immediate 'grant select on CSF_OWN.TMPCABLANCTO_SEQ to CSF_WORK';      
      --
   elsif nvl(vn_existe,0) > 0 then
      --
      execute immediate 'grant select on CSF_OWN.TMPCABLANCTO_SEQ to CSF_WORK';      
      --
   end if;   
   --
   commit;
exception
   when others then
      raise_application_error(-20001, 'Erro no script 76108. Criacao da sequence TMPCABLANCTO_SEQ. Erro: ' || sqlerrm);      
end;
/

declare
  --
  vv_sql    long;
  vn_existe number := 0;
  --
begin
   BEGIN
     SELECT COUNT(1)
     INTO vn_existe
     FROM CSF_OWN.SEQ_TAB
     WHERE UPPER(SEQUENCE_NAME) = UPPER('TMPCABLANCTO_SEQ');
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
      VALUES (CSF_OWN.SEQTAB_SEQ.NEXTVAL, 'TMPCABLANCTO_SEQ', 'TMP_CAB_LANCTO');
      COMMIT;
    EXCEPTION
    WHEN OTHERS THEN
     NULL;
    END;
    END IF;
   --
end;
/

declare
   vn_existe number := null;
begin 
   select count(*)
     into vn_existe
     from sys.all_tables 
    where OWNER       = 'CSF_OWN'
      and TABLE_NAME  = 'TMP_DET_LANCTO';
   --
   if nvl(vn_existe,0) = 0 then
      --
      execute immediate 'create table csf_own.TMP_DET_LANCTO
                              (
                                ID              NUMBER,
                                TMPCABLANCTO_ID NUMBER,
                                TP_REGISTRO     NUMBER,
                                NUM_LCTO        VARCHAR2(255),
                                DT_LCTO         DATE,
                                VL_LCTO         NUMBER(19,2),
                                DM_IND_LCTO     VARCHAR2(1),
                                QTDE_PARTIDAS   NUMBER(6)
                              ) tablespace CSF_DATA';
      --                                                        
      execute immediate 'comment on table  CSF_OWN.TMP_DET_LANCTO                   is ''REGISTRO TIPO DETALHE DO LANÇAMENTO''';
      --
      execute immediate 'comment on column CSF_OWN.TMP_DET_LANCTO.ID                is ''ID da tabela TMP_DET_LANCTO''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_LANCTO.TMPCABLANCTO_ID   is ''ID da tabela TMP_CAB_LANCTO''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_LANCTO.TP_REGISTRO       is ''Tipo do registro. Fixo 5.''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_LANCTO.NUM_LCTO          is ''Número do lançamento''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_LANCTO.DT_LCTO           is ''Data do Lançamento''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_LANCTO.VL_LCTO           is ''Valor do Lançamento''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_LANCTO.DM_IND_LCTO       is ''Indicador do tipo de lançamento - N ou E''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_LANCTO.QTDE_PARTIDAS     is ''Quantidade de partidas''';      
      ---      
      execute immediate 'create index CSF_OWN.TMP_DET_LANCTO_IDX1 on CSF_OWN.TMP_DET_LANCTO (ID)                                tablespace CSF_INDEX';
      execute immediate 'create index CSF_OWN.TMP_DET_LANCTO_IDX2 on CSF_OWN.TMP_DET_LANCTO (TMPCABLANCTO_ID)                   tablespace CSF_INDEX';
      execute immediate 'create index CSF_OWN.TMP_DET_LANCTO_IDX3 on CSF_OWN.TMP_DET_LANCTO (TP_REGISTRO, DT_LCTO, DM_IND_LCTO) tablespace CSF_INDEX';
      ---      
      execute immediate 'grant select, insert, update, delete on CSF_OWN.TMP_DET_LANCTO to CSF_WORK';
      --    
   else
      --                                                        
      execute immediate 'comment on table  CSF_OWN.TMP_DET_LANCTO                   is ''REGISTRO TIPO DETALHE DO LANÇAMENTO''';
      --
      execute immediate 'comment on column CSF_OWN.TMP_DET_LANCTO.ID                is ''ID da tabela TMP_DET_LANCTO''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_LANCTO.TMPCABLANCTO_ID   is ''ID da tabela TMP_CAB_LANCTO''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_LANCTO.TP_REGISTRO       is ''Tipo do registro. Fixo 5.''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_LANCTO.NUM_LCTO          is ''Número do lançamento''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_LANCTO.DT_LCTO           is ''Data do Lançamento''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_LANCTO.VL_LCTO           is ''Valor do Lançamento''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_LANCTO.DM_IND_LCTO       is ''Indicador do tipo de lançamento - N ou E''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_LANCTO.QTDE_PARTIDAS     is ''Quantidade de partidas''';      
      ---   
      execute immediate 'grant select, insert, update, delete on CSF_OWN.TMP_DET_LANCTO to CSF_WORK';
      --    
   end if;
   --
   commit;
exception
   when others then
      raise_application_error(-20001, 'Erro no script 76108. Criacao da tabela TMP_DET_LANCTO. Erro: ' || sqlerrm);      
end;
/

declare
   vn_existe number := null;
begin 
   select count(*)
     into vn_existe
     from sys.all_sequences s
    where s.SEQUENCE_OWNER = 'CSF_OWN'
      and s.SEQUENCE_NAME  = 'TMPDETLANCTO_SEQ';
   --
   if nvl(vn_existe,0) = 0 then
      --
      execute immediate 'create sequence CSF_OWN.TMPDETLANCTO_SEQ minvalue 1 maxvalue 9999999999999999999999999999 start with 1 increment by 1 nocache';
      execute immediate 'grant select on CSF_OWN.TMPDETLANCTO_SEQ to CSF_WORK';      
      --
   elsif nvl(vn_existe,0) > 0 then
      --
      execute immediate 'grant select on CSF_OWN.TMPDETLANCTO_SEQ to CSF_WORK';      
      --
   end if;   
   --
   commit;
exception
   when others then
      raise_application_error(-20001, 'Erro no script 76108. Criacao da sequence TMPDETLANCTO_SEQ. Erro: ' || sqlerrm);      
end;
/

declare
  --
  vv_sql    long;
  vn_existe number := 0;
  --
begin
   BEGIN
        SELECT COUNT(1)
	  INTO vn_existe
	 FROM CSF_OWN.SEQ_TAB
	 WHERE UPPER(SEQUENCE_NAME) = UPPER('TMPDETLANCTO_SEQ');
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
       VALUES (CSF_OWN.SEQTAB_SEQ.NEXTVAL, 'TMPDETLANCTO_SEQ', 'TMP_DET_LANCTO');
       COMMIT;
     EXCEPTION
       WHEN OTHERS THEN
	  NULL;
       END;
    END IF;
   --
end;
/

declare
   vn_existe number := null;
begin 
   select count(*)
     into vn_existe
     from sys.all_tables 
    where OWNER       = 'CSF_OWN'
      and TABLE_NAME  = 'TMP_CAB_PARTIDA';
   --
   if nvl(vn_existe,0) = 0 then
      --
      execute immediate 'create table CSF_OWN.TMP_CAB_PARTIDA
                        (
                          ID                NUMBER,
                          TMPTIPOCTRLARQ_ID NUMBER,
                          TP_REGISTRO       NUMBER,
                          CNPJ_EMPRESA      VARCHAR2(14),
                          NUM_LCTO          VARCHAR2(255)
                        )
                        tablespace CSF_DATA';
      ---      
      execute immediate 'comment on table  CSF_OWN.TMP_CAB_PARTIDA                   is ''REGISTRO TIPO CABEÇALHO DA PARTIDA''';
      -- 
      execute immediate 'comment on column CSF_OWN.TMP_CAB_PARTIDA.ID                is ''ID da tabela TMP_CAB_PARTIDA''';
      execute immediate 'comment on column CSF_OWN.TMP_CAB_PARTIDA.TMPTIPOCTRLARQ_ID is ''ID da tabela TMP_TIPO_CTRL_ARQ''';
      execute immediate 'comment on column CSF_OWN.TMP_CAB_PARTIDA.TP_REGISTRO       is ''Tipo do registro''';
      execute immediate 'comment on column CSF_OWN.TMP_CAB_PARTIDA.CNPJ_EMPRESA      is ''CNPJ da empresa''';
      execute immediate 'comment on column CSF_OWN.TMP_CAB_PARTIDA.NUM_LCTO          is ''Numero do Lançamento''';            
      ---
      execute immediate 'create index CSF_OWN.TMP_CAB_PARTIDA_IDX1 on CSF_OWN.TMP_CAB_PARTIDA (ID)                tablespace CSF_INDEX';
      execute immediate 'create index CSF_OWN.TMP_CAB_PARTIDA_IDX2 on CSF_OWN.TMP_CAB_PARTIDA (TMPTIPOCTRLARQ_ID) tablespace CSF_INDEX';
      execute immediate 'create index CSF_OWN.TMP_CAB_PARTIDA_IDX3 on CSF_OWN.TMP_CAB_PARTIDA (NUM_LCTO)          tablespace CSF_INDEX';
      ---
      execute immediate 'grant select, insert, update, delete on CSF_OWN.TMP_CAB_PARTIDA to CSF_WORK';
      --    
   else
      --
      execute immediate 'comment on table  CSF_OWN.TMP_CAB_PARTIDA                   is ''REGISTRO TIPO CABEÇALHO DA PARTIDA''';
      -- 
      execute immediate 'comment on column CSF_OWN.TMP_CAB_PARTIDA.ID                is ''ID da tabela TMP_CAB_PARTIDA''';
      execute immediate 'comment on column CSF_OWN.TMP_CAB_PARTIDA.TMPTIPOCTRLARQ_ID is ''ID da tabela TMP_TIPO_CTRL_ARQ''';
      execute immediate 'comment on column CSF_OWN.TMP_CAB_PARTIDA.TP_REGISTRO       is ''Tipo do registro''';
      execute immediate 'comment on column CSF_OWN.TMP_CAB_PARTIDA.CNPJ_EMPRESA      is ''CNPJ da empresa''';
      execute immediate 'comment on column CSF_OWN.TMP_CAB_PARTIDA.NUM_LCTO          is ''Numero do Lançamento''';      
      ---   
      execute immediate 'grant select, insert, update, delete on CSF_OWN.TMP_CAB_PARTIDA to CSF_WORK';
      --    
   end if;
   --
   commit;
exception
   when others then
      raise_application_error(-20001, 'Erro no script 76108. Criacao da tabela TMP_CAB_PARTIDA. Erro: ' || sqlerrm);      
end;
/

declare
   vn_existe number := null;
begin 
   select count(*)
     into vn_existe
     from sys.all_sequences s
    where s.SEQUENCE_OWNER = 'CSF_OWN'
      and s.SEQUENCE_NAME  = 'TMPCABPARTIDA_SEQ';
   --
   if nvl(vn_existe,0) = 0 then
      --
      execute immediate 'create sequence CSF_OWN.TMPCABPARTIDA_SEQ minvalue 1 maxvalue 9999999999999999999999999999 start with 1 increment by 1 nocache';
      execute immediate 'grant select on CSF_OWN.TMPCABPARTIDA_SEQ to CSF_WORK';      
      --
   elsif nvl(vn_existe,0) > 0 then
      --
      execute immediate 'grant select on CSF_OWN.TMPCABPARTIDA_SEQ to CSF_WORK';      
      --
   end if;   
   --
   commit;
exception
   when others then
      raise_application_error(-20001, 'Erro no script 76108. Criacao da sequence TMPCABPARTIDA_SEQ. Erro: ' || sqlerrm);      
end;
/

declare
  --
  vv_sql    long;
  vn_existe number := 0;
  --
begin
   BEGIN
   SELECT COUNT(1)
      INTO vn_existe
   FROM CSF_OWN.SEQ_TAB
   WHERE UPPER(SEQUENCE_NAME) = UPPER('TMPCABPARTIDA_SEQ');
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
      VALUES (CSF_OWN.SEQTAB_SEQ.NEXTVAL, 'TMPCABPARTIDA_SEQ', 'TMP_CAB_PARTIDA');
      COMMIT;
     EXCEPTION
       WHEN OTHERS THEN
        NULL;
    END;
    END IF;
   --
end;
/

declare
   vn_existe number := null;
begin 
   select count(*)
     into vn_existe
     from sys.all_tables 
    where OWNER       = 'CSF_OWN'
      and TABLE_NAME  = 'TMP_DET_PARTIDA';
   --
   if nvl(vn_existe,0) = 0 then
      --
      execute immediate 'create table csf_own.TMP_DET_PARTIDA
                                (
                                  ID               NUMBER,
                                  TMPCABPARTIDA_ID NUMBER,
                                  TP_REGISTRO      NUMBER,
                                  COD_CTA          VARCHAR2(255),
                                  COD_CCUS         VARCHAR2(60),
                                  VL_DC            NUMBER(19,2),
                                  DM_IND_DC        VARCHAR2(1),
                                  NUM_ARQ          VARCHAR2(255),
                                  COD_HIST_PAD     VARCHAR2(30),
                                  COMPL_HIST       VARCHAR2(4000),
                                  COD_PART         VARCHAR2(60),
                                  NUM_SEQ_PART     NUMBER(7)
                                ) tablespace CSF_DATA';
      ---      
      execute immediate 'comment on table CSF_OWN.TMP_DET_PARTIDA                   is ''REGISTRO TIPO DETALHE DA PARTIDA''';
      -- 
      execute immediate 'comment on column CSF_OWN.TMP_DET_PARTIDA.ID               is ''ID da tabela TMP_DET_PARTIDA''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_PARTIDA.TMPCABPARTIDA_ID is ''ID da tabela TMP_CAB_PARTIDA''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_PARTIDA.TP_REGISTRO      is ''Tipo do registro''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_PARTIDA.COD_CTA          is ''Código da Conta contabil''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_PARTIDA.COD_CCUS         is ''Código do centro de custos''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_PARTIDA.VL_DC            is ''Valor da partida''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_PARTIDA.DM_IND_DC        is ''Indicador de situação da partida - D ou C. D = Débito / C = Crédito''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_PARTIDA.NUM_ARQ          is ''Numero ou código de arquivo do documento''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_PARTIDA.COD_HIST_PAD     is ''Código do histórico padrão''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_PARTIDA.COMPL_HIST       is ''Complemento do histórico contabil''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_PARTIDA.COD_PART         is ''Código do participante''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_PARTIDA.NUM_SEQ_PART     is ''Numero sequencial da partida''';               
      ---
      execute immediate 'create index CSF_OWN.TMP_DET_PARTIDA_IDX1 on CSF_OWN.TMP_DET_PARTIDA (ID) tablespace CSF_INDEX';
      execute immediate 'create index CSF_OWN.TMP_DET_PARTIDA_IDX2 on CSF_OWN.TMP_DET_PARTIDA (TMPCABPARTIDA_ID) tablespace CSF_INDEX';
      ---
      execute immediate 'grant select, insert, update, delete on CSF_OWN.TMP_DET_PARTIDA to CSF_WORK';
      --    
   else
      --
      execute immediate 'comment on table CSF_OWN.TMP_DET_PARTIDA                   is ''REGISTRO TIPO DETALHE DA PARTIDA''';
      -- 
      execute immediate 'comment on column CSF_OWN.TMP_DET_PARTIDA.ID               is ''ID da tabela TMP_DET_PARTIDA''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_PARTIDA.TMPCABPARTIDA_ID is ''ID da tabela TMP_CAB_PARTIDA''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_PARTIDA.TP_REGISTRO      is ''Tipo do registro''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_PARTIDA.COD_CTA          is ''Código da Conta contabil''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_PARTIDA.COD_CCUS         is ''Código do centro de custos''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_PARTIDA.VL_DC            is ''Valor da partida''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_PARTIDA.DM_IND_DC        is ''Indicador de situação da partida - D ou C. D = Débito / C = Crédito''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_PARTIDA.NUM_ARQ          is ''Numero ou código de arquivo do documento''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_PARTIDA.COD_HIST_PAD     is ''Código do histórico padrão''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_PARTIDA.COMPL_HIST       is ''Complemento do histórico contabil''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_PARTIDA.COD_PART         is ''Código do participante''';
      execute immediate 'comment on column CSF_OWN.TMP_DET_PARTIDA.NUM_SEQ_PART     is ''Numero sequencial da partida''';               
      ---   
      execute immediate 'grant select, insert, update, delete on CSF_OWN.TMP_DET_PARTIDA to CSF_WORK';
      --    
   end if;
   --
   commit;
exception
   when others then
      raise_application_error(-20001, 'Erro no script 76108. Criacao da tabela TMP_DET_PARTIDA. Erro: ' || sqlerrm);      
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
      and s.SEQUENCE_NAME  = 'TMPDETPARTIDA_SEQ';
   --
   if nvl(vn_existe,0) = 0 then
      --
      execute immediate 'create sequence CSF_OWN.TMPDETPARTIDA_SEQ minvalue 1 maxvalue 9999999999999999999999999999 start with 1 increment by 1 nocache';
      execute immediate 'grant select on CSF_OWN.TMPDETPARTIDA_SEQ to CSF_WORK';      
      --
   elsif nvl(vn_existe,0) > 0 then
      --
      execute immediate 'grant select on CSF_OWN.TMPDETPARTIDA_SEQ to CSF_WORK';      
      --
   end if;   
   --
   commit;
exception
   when others then
      raise_application_error(-20001, 'Erro no script 76108. Criacao da sequence TMPDETPARTIDA_SEQ. Erro: ' || sqlerrm);      
end;
/

declare
  --
  vv_sql    long;
  vn_existe number := 0;
  --
begin
   BEGIN
     SELECT COUNT(1)
        INTO vn_existe
     FROM CSF_OWN.SEQ_TAB
     WHERE UPPER(SEQUENCE_NAME) = UPPER('TMPDETPARTIDA_SEQ');
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
     VALUES (CSF_OWN.SEQTAB_SEQ.NEXTVAL, 'TMPDETPARTIDA_SEQ', 'TMP_DET_PARTIDA');
     COMMIT;
   EXCEPTION
    WHEN OTHERS THEN
      NULL;
   END;
   END IF;
   --
end;
/
-------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #76108 - Novo processo de integra��o contabil
-------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #76520 - PJ do Informe de rendimentos saindo em branco
-------------------------------------------------------------------------------------------------------------------------------

declare
  vn_existe number := null;
begin
   begin
      select count(1)
        into vn_existe
        from all_tab_columns c
       where c.OWNER       = 'CSF_OWN'
         and c.TABLE_NAME  = 'REL_JUR_INF_REND_DIRF'
         and c.COLUMN_NAME = 'NOME_EMPRESA' 
         and c.DATA_LENGTH = 60;
   exception
      when others then
         vn_existe := null;
   end;
   --
   if nvl(vn_existe, 0) > 0 then
      --  
      vn_existe := null;
      --	  
      begin
         select count(1)
           into vn_existe		 
           from all_tab_columns c
          where c.OWNER      = 'CSF_OWN'
           and c.TABLE_NAME  = 'REL_JUR_INF_REND_DIRF'   
           and c.COLUMN_NAME = 'NOME_FORN' 
           and c.DATA_LENGTH = 60;
      exception		   
         when others then
             vn_existe := null;
      end;
      --
      if nvl(vn_existe, 0) > 0 then	  
         --  
         vn_existe := null;
         --	  
         begin 
            select count(1) 
              into vn_existe			
             from all_tab_columns c
            where c.OWNER       = 'CSF_OWN'
              and c.TABLE_NAME  = 'REL_JUR_INF_REND_DIRF' 
              and c.COLUMN_NAME = 'NOME_RESP' 
              and c.DATA_LENGTH = 60;
         exception
            when others then
               vn_existe := null;
         end;
         --
      end if;
      --
   end if;	  
   --
   if nvl(vn_existe, 0) > 0 then  
      --   
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.REL_JUR_INF_REND_DIRF modify nome_empresa VARCHAR2(70)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao modificar coluna NOME_EMPRESA tabela REL_JUR_INF_REND_DIRF - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.REL_JUR_INF_REND_DIRF modify nome_forn VARCHAR2(70)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao modificar coluna NOME_FORN tabela REL_JUR_INF_REND_DIRF - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.REL_JUR_INF_REND_DIRF modify nome_resp VARCHAR2(70)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao modificar coluna NOME_RESP tabela REL_JUR_INF_REND_DIRF - '||SQLERRM );
      END;	  
      --
   end if;
   -- 
   commit;
   --   
end;
/

-------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #76520 - PJ do Informe de rendimentos saindo em branco
-------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #71237 - NT 2020.006
-------------------------------------------------------------------------------------------------------------------------------

declare
   vn_existe number := null;
begin
   select count(*)
     into vn_existe
     from sys.all_tab_columns ac
    where upper(ac.OWNER)       = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)  = upper('NOTA_FISCAL')
      and upper(ac.COLUMN_NAME) = upper('DM_IND_INTERMED');
   --
   if nvl(vn_existe,0) > 0 then
      --
      begin execute immediate 'comment on column CSF_OWN.NOTA_FISCAL.DM_IND_INTERMED is ''Indicador de intermediador/marketplace. 0=Opera��o sem intermediador (em site ou plataforma pr�pria) / 1=Opera��o em site ou plataforma de terceiros (intermediadores/marketplace)''';
      exception when others then raise_application_error(-20001, 'Erro no script 71247. Campo DM_IND_INTERMED. Erro: ' || sqlerrm); end;
      --
   elsif nvl(vn_existe,0) = 0 then
      --
      begin execute immediate 'alter trigger CSF_OWN.T_A_I_U_NOTA_FISCAL_04 DISABLE'; exception when others then raise_application_error(-20001, 'Erro no script 71247. Campo DM_IND_INTERMED. Erro: ' || sqlerrm); end;
      begin execute immediate 'alter trigger CSF_OWN.T_A_I_U_NOTA_FISCAL_02 DISABLE'; exception when others then raise_application_error(-20001, 'Erro no script 71247. Campo DM_IND_INTERMED. Erro: ' || sqlerrm); end;
      begin execute immediate 'alter trigger CSF_OWN.T_B_U_NOTA_FISCAL_01 DISABLE'; exception when others then raise_application_error(-20001, 'Erro no script 71247. Campo DM_IND_INTERMED. Erro: ' || sqlerrm); end;
      begin execute immediate 'alter trigger CSF_OWN.T_A_I_U_NOTA_FISCAL_NF_REF_01 DISABLE'; exception when others then raise_application_error(-20001, 'Erro no script 71247. Campo DM_IND_INTERMED. Erro: ' || sqlerrm); end;
      --
      begin execute immediate 'alter table CSF_OWN.NOTA_FISCAL add DM_IND_INTERMED NUMBER(1) default null'; exception when dup_val_on_index then null; end;
      begin execute immediate 'alter table CSF_OWN.tmp_nota_fiscal add DM_IND_INTERMED NUMBER(1)'; exception when dup_val_on_index then null; end;
      begin execute immediate 'comment on column CSF_OWN.NOTA_FISCAL.DM_IND_INTERMED is ''Indicador de intermediador/marketplace. 0=Opera��o sem intermediador (em site ou plataforma pr�pria) / 1=Opera��o em site ou plataforma de terceiros (intermediadores/marketplace)'''; exception when dup_val_on_index then null; end;
      begin execute immediate 'alter table CSF_OWN.NOTA_FISCAL add constraint CSF_OWN.NOTAFISCAL_INDINTERMED_CK check (DM_IND_INTERMED IN (0,1))'; exception when others then raise_application_error(-20001, 'Erro no script 71247. Campo DM_IND_INTERMED. Erro: ' || sqlerrm); end;
      --
      begin execute immediate 'alter trigger CSF_OWN.T_A_I_U_NOTA_FISCAL_04 DISABLE'; exception when others then raise_application_error(-20001, 'Erro no script 71247. Campo DM_IND_INTERMED. Erro: ' || sqlerrm); end;
      begin execute immediate 'alter trigger CSF_OWN.T_A_I_U_NOTA_FISCAL_02 ENABLE'; exception when others then raise_application_error(-20001, 'Erro no script 71247. Campo DM_IND_INTERMED. Erro: ' || sqlerrm); end;
      begin execute immediate 'alter trigger CSF_OWN.T_B_U_NOTA_FISCAL_01 ENABLE'; exception when others then raise_application_error(-20001, 'Erro no script 71247. Campo DM_IND_INTERMED. Erro: ' || sqlerrm); end;
      begin execute immediate 'alter trigger CSF_OWN.T_A_I_U_NOTA_FISCAL_NF_REF_01 ENABLE'; exception when others then raise_application_error(-20001, 'Erro no script 71247. Campo DM_IND_INTERMED. Erro: ' || sqlerrm); end;
      --
   end if;
   --
exception
   when others then
      raise_application_error(-20001, 'Erro no script 71247. Campo DM_IND_INTERMED. Erro: ' || sqlerrm);
end;
/

begin
   execute immediate 'insert into csf_own.dominio (dominio, vl, descr, id) values (''NOTA_FISCAL.DM_IND_INTERMED'', ''0'' , ''Opera��o sem intermediador (em site ou plataforma pr�pria)'', csf_own.dominio_seq.nextval )';
   commit;
exception
   when dup_val_on_index then
      null;
   when others then
      raise_application_error(-20001, 'Erro no script 71247. Dom�nio NOTA_FISCAL.DM_IND_INTERMED e Valor "0". Erro: ' || sqlerrm);
end;
/

begin
   execute immediate 'insert into csf_own.dominio (dominio, vl, descr, id) values (''NOTA_FISCAL.DM_IND_INTERMED'', ''1'' , ''Opera��o em site ou plataforma de terceiros'', csf_own.dominio_seq.nextval )';
   commit;
exception
   when dup_val_on_index then
      null;
   when others then
      raise_application_error(-20001, 'Erro no script 71247. Dom�nio NOTA_FISCAL.DM_IND_INTERMED e Valor "1". Erro: ' || sqlerrm);
end;
/

commit
/

begin
   execute immediate 'insert into csf_own.dominio (dominio, vl, descr, id) values (''NF_FORMA_PGTO.DM_TP_PAG'', ''16'' , ''Dep�sito Banc�rio'', csf_own.dominio_seq.nextval )';
   commit;
exception
   when dup_val_on_index then
      null;
   when others then
      raise_application_error(-20001, 'Erro no script 71247. Dom�nio NF_FORMA_PGTO.DM_TP_PAG e Valor "16". Erro: ' || sqlerrm);
end;
/

begin
   execute immediate 'insert into csf_own.dominio (dominio, vl, descr, id) values (''NF_FORMA_PGTO.DM_TP_PAG'', ''17'' , ''Pagamento Instant�neo (PIX)'', csf_own.dominio_seq.nextval )';
   commit;
exception
   when dup_val_on_index then
      null;
   when others then
      raise_application_error(-20001, 'Erro no script 71247. Dom�nio NF_FORMA_PGTO.DM_TP_PAG e Valor "17". Erro: ' || sqlerrm);
end;
/

begin
   execute immediate 'insert into csf_own.dominio (dominio, vl, descr, id) values (''NF_FORMA_PGTO.DM_TP_PAG'', ''18'' , ''Transfer�ncia banc�ria, Carteira Digital'', csf_own.dominio_seq.nextval )';
   commit;
exception
   when dup_val_on_index then
      null;
   when others then
      raise_application_error(-20001, 'Erro no script 71247. Dom�nio NF_FORMA_PGTO.DM_TP_PAG e Valor "18". Erro: ' || sqlerrm);
end;
/

begin
   execute immediate 'insert into csf_own.dominio (dominio, vl, descr, id) values (''NF_FORMA_PGTO.DM_TP_PAG'', ''19'' , ''Programa de fidelidade, Cashback, Cr�dito Virtual'', csf_own.dominio_seq.nextval )';
   commit;
exception
   when dup_val_on_index then
      null;
   when others then
      raise_application_error(-20001, 'Erro no script 71247. Dom�nio NF_FORMA_PGTO.DM_TP_PAG e Valor "19". Erro: ' || sqlerrm);
end;
/

begin
  execute immediate 'alter table CSF_OWN.NF_FORMA_PGTO drop constraint CSF_OWN.NFFORMAPGTO_TPPAG_CK ';
 exception when others then
   raise_application_error(-20001, 'Erro no script 71247. Campo DM_TP_PAG. Erro: ' || sqlerrm);
end;
/

begin
  execute immediate 'alter table CSF_OWN.NF_FORMA_PGTO  add constraint CSF_OWN.NFFORMAPGTO_TPPAG_CK check (dm_tp_pag in (''01'', ''02'', ''03'', ''04'', ''05'', ''10'', ''11'', ''12'', ''13'', ''14'', ''15'',''16'',''17'',''18'',''19'', ''90'', ''99''))';
exception when others then
  raise_application_error(-20001, 'Erro no script 71247. Campo DM_TP_PAG. Erro: ' || sqlerrm);
end;
/

commit
/

declare
   vn_existe number := null;
begin 
   select count(*)
     into vn_existe
     from sys.all_tab_columns ac 
    where upper(ac.OWNER)       = upper('CSF_OWN')
      and upper(ac.TABLE_NAME)  = upper('NOTA_FISCAL')
      and upper(ac.COLUMN_NAME) = upper('PESSOA_ID_INTERMED');
   --
   if nvl(vn_existe,0) > 0 then
      --
      begin execute immediate 'comment on column CSF_OWN.NOTA_FISCAL.PESSOA_ID_INTERMED is ''Informar pessoa do Intermediador da Transa��o (agenciador, plataforma de delivery, marketplace e similar) de servi�os e de neg�cios.''';
      exception when others then raise_application_error(-20001, 'Erro no script 71247. Campo PESSOA_ID_INTERMED . Erro: ' || sqlerrm); end;
      --
   elsif nvl(vn_existe,0) = 0 then
      --
      begin execute immediate 'alter trigger CSF_OWN.T_A_I_U_NOTA_FISCAL_04 DISABLE'; exception when others then raise_application_error(-20001, 'Erro no script 71247. Campo PESSOA_ID_INTERMED . Erro: ' || sqlerrm); end;
      begin execute immediate 'alter trigger CSF_OWN.T_A_I_U_NOTA_FISCAL_02 DISABLE'; exception when others then raise_application_error(-20001, 'Erro no script 71247. Campo PESSOA_ID_INTERMED . Erro: ' || sqlerrm); end;
      begin execute immediate 'alter trigger CSF_OWN.T_B_U_NOTA_FISCAL_01 DISABLE'; exception when others then raise_application_error(-20001, 'Erro no script 71247. Campo PESSOA_ID_INTERMED . Erro: ' || sqlerrm); end;
      begin execute immediate 'alter trigger CSF_OWN.T_A_I_U_NOTA_FISCAL_NF_REF_01 DISABLE'; exception when others then raise_application_error(-20001, 'Erro no script 71247. Campo PESSOA_ID_INTERMED . Erro: ' || sqlerrm); end;
      --
      begin execute immediate 'alter table CSF_OWN.NOTA_FISCAL add PESSOA_ID_INTERMED NUMBER'; exception when dup_val_on_index then null; end;
      begin execute immediate 'alter table CSF_OWN.tmp_nota_fiscal add PESSOA_ID_INTERMED NUMBER'; exception when dup_val_on_index then null; end;
      begin execute immediate 'comment on column CSF_OWN.NOTA_FISCAL.PESSOA_ID_INTERMED is ''Informar pessoa do Intermediador da Transa��o (agenciador, plataforma de delivery, marketplace e similar) de servi�os e de neg�cios.'''; exception when dup_val_on_index then null; end;
      --
      begin execute immediate 'alter trigger CSF_OWN.T_A_I_U_NOTA_FISCAL_04 DISABLE'; exception when others then raise_application_error(-20001, 'Erro no script 71247. Campo PESSOA_ID_INTERMED . Erro: ' || sqlerrm); end;      
      begin execute immediate 'alter trigger CSF_OWN.T_A_I_U_NOTA_FISCAL_02 ENABLE'; exception when others then raise_application_error(-20001, 'Erro no script 71247. Campo PESSOA_ID_INTERMED . Erro: ' || sqlerrm); end;
      begin execute immediate 'alter trigger CSF_OWN.T_B_U_NOTA_FISCAL_01 ENABLE'; exception when others then raise_application_error(-20001, 'Erro no script 71247. Campo PESSOA_ID_INTERMED . Erro: ' || sqlerrm); end;
      begin execute immediate 'alter trigger CSF_OWN.T_A_I_U_NOTA_FISCAL_NF_REF_01 ENABLE'; exception when others then raise_application_error(-20001, 'Erro no script 71247. Campo PESSOA_ID_INTERMED . Erro: ' || sqlerrm); end;
      --
   end if;
   -- 
exception
   when others then
      raise_application_error(-20001, 'Erro no script 71247. Campo PESSOA_ID_INTERMED . Erro: ' || sqlerrm);      
end;
/

declare
   vn_existe number := null;
begin
  select count(*)
     into vn_existe
  from sys.all_constraints acc
  where upper(acc.OWNER)       = upper('CSF_OWN')
    and upper(acc.TABLE_NAME)  = upper('NOTA_FISCAL')
    and upper(acc.constraint_name) = upper('NOTAFISCAL_PES_ID_INTERMED_FK');

if nvl(vn_existe,0) = 0 then
  begin execute immediate 'alter table csf_own.NOTA_FISCAL add constraint CSF_OWN.NOTAFISCAL_PES_ID_INTERMED_FK foreign key (PESSOA_ID_INTERMED) references PESSOA (ID)'; exception when dup_val_on_index then null; end;
  begin execute immediate 'create index csf_own.NOTAFISCAL_PES_ID_INTERM_FK_I on csf_own.NOTA_FISCAL (PESSOA_ID_INTERMED) tablespace csf_index'; exception when dup_val_on_index then null; end;
end if;
exception
   when others then
      raise_application_error(-20001, 'Erro no script 71247. FK NOTAFISCAL_PES_ID_INTERMED_FK . Erro: ' || sqlerrm);
end;
/

commit
/

declare
   --
   cursor c_view is
      select a.id
        from csf_own.obj_util_integr a
       where a.obj_name = 'VW_CSF_NOTA_FISCAL_FF';
   --
begin
   --
   for rec_view in c_view loop
      exit when c_view%notfound or (c_view%notfound) is null;
      --
      -- DM_IND_INTERMED:
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
                                                , 'DM_IND_INTERMED'                   -- atributo
                                                , 'Indicador de intermediador/marketplace'  -- descr
                                                , 1                                   -- dm_tipo_campo (Tipo do campo/atributo (0-data, 1-numerico, 2-caractere)
                                                , 1                                   -- tamanho
                                                , 0                                   -- qtde_decimal
                                                );
         --
      exception
         when dup_val_on_index then
            begin
               update csf_own.ff_obj_util_integr ff
                  set ff.dm_tipo_campo    = 1
                    , ff.tamanho          = 1
                    , ff.qtde_decimal     = 0
                    , ff.descr            = 'Indicador de intermediador/marketplace'
                where ff.atributo         = 'DM_IND_INTERMED'
                  and ff.objutilintegr_id = rec_view.id;
            exception
               when others then
                  raise_application_error(-20101, 'Erro no script 71247 (DM_IND_INTERMED). Erro:' || sqlerrm);
            end;
      end;
      --
      --COD_PART_INTERMED:
      begin
         insert into csf_own.ff_obj_util_integr ( id
                                                , objutilintegr_id
                                                , atributo
                                                , descr
                                                , dm_tipo_campo
                                                , tamanho
                                                , qtde_decimal )
              values                            ( csf_own.ffobjutilintegr_seq.nextval      -- id
                                                , rec_view.id                              -- objutilintegr_id
                                                , 'COD_PART_INTERMED'                      -- atributo
                                                , 'Pessoa do Intermediador da Transa��o de servi�os e de neg�cios'   -- descr
                                                , 2                                        -- dm_tipo_campo (Tipo do campo/atributo (0-data, 1-numerico, 2-caractere)
                                                , 60                                       -- tamanho
                                                , 0                                        -- qtde_decimal
                                                );
         --
      exception
         when dup_val_on_index then
            begin
               update csf_own.ff_obj_util_integr ff
                  set ff.dm_tipo_campo    = 2
                    , ff.tamanho          = 60
                    , ff.qtde_decimal     = 0
                    , ff.descr            = 'Pessoa do Intermediador da Transa��o de servi�os e de neg�cios'
                where ff.atributo         = 'COD_PART_INTERMED'
                  and ff.objutilintegr_id = rec_view.id;
            exception
               when others then
                  raise_application_error(-20101, 'Erro no script 71247 (DM_IND_INTERMED). Erro:' || sqlerrm);
            end;
      end;
      --
      commit;
      --
   end loop;
   --
end;
/

commit
/
-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #71237 - NT 2020.006
-------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------
Prompt FIM Patch 2.9.6.2 - Alteracoes no CSF_OWN
------------------------------------------------------------------------------------------
