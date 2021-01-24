create or replace trigger csf_own.t_a_i_nota_fiscal_rabbitmq_nfe
after insert
    on nota_fiscal
 referencing old as old new as new
 for each row
   ---------------------------------------------------------------------------------------------------
   -- Em 29/12/2020   - Armando/Wendel 
   -- Redmine #74637  - Integração via view alterando a chave da nota fiscal de emissão própria
   -- Alteracao       - comentando cod_part no select final e inserido trim nos filtros por problemas 
   --                   na integração da ocyan
   --------------------------------------------------------------------------------------------------- 
declare
   --
   vn_modfiscal_id   number               := pk_csf.fkg_mod_fiscal_id('55');
   vv_cpf_cnpj_emit  varchar2(14)         := pk_csf.fkg_cnpj_ou_cpf_empresa(:new.empresa_id);
   --vv_cod_part       pessoa.cod_part%type := pk_csf.fkg_pessoa_cod_part(:new.pessoa_id);
   vn_qtde           number               := 0;
   --
   --vn_empresa_id     number := pk_csf.fkg_empresa_notafiscal(:new.id);
   vn_multorg_id     number := pk_csf.fkg_multorg_id_empresa(:new.empresa_id);
   MODULO_SISTEMA    constant number := pk_csf.fkg_ret_id_modulo_sistema('INTEGRACAO');
   GRUPO_SISTEMA     constant number := pk_csf.fkg_ret_id_grupo_sistema(MODULO_SISTEMA, 'CTRL_FILAS');
   vn_util_rabbitmq  number := 0;
   vv_erro2          varchar2(4000);
   --
begin
   --
   if not pk_csf.fkg_ret_vl_param_geral_sistema (en_multorg_id => vn_multorg_id,
                                                 en_empresa_id => :NEW.EMPRESA_ID,
                                                 en_modulo_id  => MODULO_SISTEMA,
                                                 en_grupo_id   => GRUPO_SISTEMA,
                                                 ev_param_name => 'UTILIZA_RABBIT_MQ',
                                                 sv_vlr_param  => vn_util_rabbitmq,
                                                 sv_erro       => vv_erro2) then
      --
      vn_util_rabbitmq := 0;
      --
   end if;
   
   if vv_erro2 is not null then
      declare
          vn_loggenerico_id  log_generico_nf.id%TYPE;
       begin
          --
          pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                         , ev_mensagem         => 'Falha ao tentar recuperar dados da empresa e multorg t_a_i_nota_fiscal_rabbitmq_nfe NOTAFISCAL_ID='||:NEW.ID||', ERRO: '||vv_erro2
                                         , ev_resumo           => 'Falha ao tentar recuperar dados da empresa e multorg t_a_i_nota_fiscal_rabbitmq_nfe NOTAFISCAL_ID='||:NEW.ID
                                         , en_tipo_log         => 35
                                         , en_referencia_id    => :NEW.ID
                                         , ev_obj_referencia   => 'NOTA_FISCAL' );
          --
       exception
          when others then
             null;
       end;
   elsif vn_util_rabbitmq = 1
      and :new.dm_ind_emit = 0
      and :new.dm_legado = 0
      and :new.dm_st_proc = 0
      and :new.modfiscal_id = vn_modfiscal_id then -- nota fiscal para emitir
      --
      begin
         --
        select count(1)
          into vn_qtde
          from vw_csf_nota_fiscal
         where trim(cpf_cnpj_emit) = vv_cpf_cnpj_emit
           and trim(dm_ind_emit)   = :new.dm_ind_emit
           and trim(dm_ind_oper)   = :new.dm_ind_oper
          --and nvl(cod_part,'0')  = nvl(vv_cod_part,'0') 
           and trim(cod_mod)       = '55'
           and trim(serie)         = :new.serie
           and trim(nro_nf)        = :new.nro_nf
           ;
        --
      exception
         when others then
            vn_qtde := 0;
      end;
      --
      if vn_qtde = 0 then
         --
         pk_csf_rabbitmq.pb_valida_nfe(:new.id);
         --
      end if;
      --
   end if;
   --
end;
/
