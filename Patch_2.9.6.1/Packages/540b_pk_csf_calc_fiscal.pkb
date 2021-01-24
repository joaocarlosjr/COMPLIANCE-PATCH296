create or replace package body csf_own.pk_csf_calc_fiscal is
-------------------------------------------------------------------------------------------------------
-- Corpo do pacote de funções de utilizadas para a Calculadora Fiscal

-------------------------------------------------------------------------------------------------------
--| Função de Retorno do ID da tabela de log_generico_calcfiscal
function fkg_loggenericocalcfiscal_id ( en_referencia_id in log_generico_calcfiscal.referencia_id%type
                                      , ev_mensagem      in log_generico_calcfiscal.mensagem%type
                                      ) return log_generico_calcfiscal.id%type
is
   --
   vn_loggenericocalcfiscal_id        log_generico_calcfiscal.id%type;
   vn_csftipolog_id                   csf_tipo_log.id%type;
   --
begin
   --
   vn_loggenericocalcfiscal_id := null;
   vn_csftipolog_id            := null;
   --
   begin
      --
       select id
         into vn_csftipolog_id
         from csf_tipo_log 
        where cd = 'INFO_CALC_FISCAL';
   exception 
     when others then
        vn_csftipolog_id := null;
   end;
   --
   select id
     into vn_loggenericocalcfiscal_id
     from log_generico_calcfiscal
    where referencia_id = en_referencia_id
      and mensagem   = ev_mensagem
      and csftipolog_id   = vn_csftipolog_id;
   --
   return vn_loggenericocalcfiscal_id;
   --
exception
  when others then
     return null;
end fkg_loggenericocalcfiscal_id;


-------------------------------------------------------------------------------------------------------
--| Função de Retorno do ID da tabela de param_icms_inter_cf
function fkg_paramicmsintercf_id ( en_empresa_id  in empresa.id%type
                                 , en_estado_id   in estado.id%type
                                 , ed_dt_ini      in param_icms_inter_cf.dt_ini%type
                                 , ed_dt_fin      in param_icms_inter_cf.dt_fin%type
                                 , en_cfop_id     in cfop.id%type
                                 , en_ncm_id      in ncm.id%type
                                 , en_item_id     in item.id%type
                                 ) return param_icms_inter_cf.id%type
is
   --
   vn_paramicmsintercf_id        param_icms_inter_cf.id%type;
   --
begin
   --
   begin
      --
      if trim(ed_dt_fin) is not null then
         --
         select id
           into vn_paramicmsintercf_id
           from param_icms_inter_cf
          where empresa_id = en_empresa_id
            and estado_id  = en_estado_id
            and dt_ini     = ed_dt_ini
            and dt_fin     = trim(ed_dt_fin)
            and ((cfop_id is null        and en_cfop_id is null)        or (cfop_id = en_cfop_id))
            and ((ncm_id is null         and en_ncm_id is null)         or (ncm_id = en_ncm_id))
            and ((item_id is null        and en_item_id is null)        or (item_id = en_item_id));
         --
      else
         --
         select id
           into vn_paramicmsintercf_id
           from param_icms_inter_cf
          where empresa_id = en_empresa_id
            and estado_id  = en_estado_id
            and dt_ini     = ed_dt_ini
            and ((cfop_id is null        and en_cfop_id is null)        or (cfop_id = en_cfop_id))
            and ((ncm_id is null         and en_ncm_id is null)         or (ncm_id = en_ncm_id))
            and ((item_id is null        and en_item_id is null)        or (item_id = en_item_id));
         --
   end if;
      --
   exception
     when others then
        return null;
   end;
   --
exception
  when others then
     return null;
end fkg_paramicmsintercf_id;

-------------------------------------------------------------------------------------------------------
--| Função de Retorno do ID da tabela de param_calc_icms_empr
function fkg_paramcalcicmsempr_id ( en_empresa_id             in empresa.id%type
                                  , ed_dt_ini                 in param_calc_icms_empr.dt_ini%type
                                  , ed_dt_fin                 in param_calc_icms_empr.dt_fin%type
                                  , ev_dm_tipo_param          in param_calc_icms_empr.dm_tipo_param%type
                                  , en_prioridade             in param_calc_icms_empr.prioridade%type
                                  , en_cfop_id                in cfop.id%type
                                  , en_estado_id_dest         in cfop.id%type
                                  , en_ncm_id                 in ncm.id%type
                                  , en_extipi_id              in ex_tipi.id%type
                                  , en_dm_orig_merc           in param_calc_icms_empr.dm_orig_merc%type
                                  , en_item_id                in item.id%type
                                  , en_natoper_id             in nat_oper.id%type
                                  , ev_cpf_cnpj               in varchar2
                                  , en_dm_calc_fisica         in param_calc_icms_empr.dm_calc_fisica%type
                                  , en_dm_calc_contr_isento   in param_calc_icms_empr.dm_calc_contr_isento%type
                                  , en_dm_calc_cons_final     in param_calc_icms_empr.dm_calc_cons_final%type
                                  , en_dm_calc_nao_contr      in param_calc_icms_empr.dm_calc_nao_contr%type
                                  , en_dm_emit_com_suframa    in param_calc_icms_empr.dm_emit_com_suframa%type
                                  , en_dm_dest_com_suframa    in param_calc_icms_empr.dm_dest_com_suframa%type
                                  ) return param_calc_icms_empr.id%type
is
   --
   vn_paramcalcicmsempr_id        param_calc_icms_empr.id%type;
   --
begin
   --
   vn_paramcalcicmsempr_id := NULL;
   --
   if trim(ed_dt_fin) is not null then
      --
       begin
          --
          select id
            into vn_paramcalcicmsempr_id
            from param_calc_icms_empr
           where empresa_id                = en_empresa_id
             and dt_ini                    = ed_dt_ini
             and dt_fin                    = ed_dt_fin
             and dm_tipo_param             = ev_dm_tipo_param
             and prioridade                = en_prioridade
             and ((cfop_id is null        and en_cfop_id is null)        or (cfop_id = en_cfop_id))
             and ((estado_id_dest is null and en_estado_id_dest is null) or (estado_id_dest = en_estado_id_dest))
             and ((ncm_id is null         and en_ncm_id is null)         or (ncm_id = en_ncm_id))
             and ((extipi_id is null      and en_extipi_id is null)      or (extipi_id = en_extipi_id))
             and ((dm_orig_merc is null   and en_dm_orig_merc is null)   or (dm_orig_merc = en_dm_orig_merc))
             and ((item_id is null        and en_item_id is null)        or (item_id = en_item_id))
             and ((natoper_id is null     and en_natoper_id is null)     or (natoper_id = en_natoper_id))
             and ((cpf_cnpj is null       and ev_cpf_cnpj is null)       or (cpf_cnpj = ev_cpf_cnpj))
             and dm_calc_fisica            = en_dm_calc_fisica
             and dm_calc_cons_final        = en_dm_calc_cons_final 
             and dm_calc_contr_isento      = en_dm_calc_contr_isento
             and dm_calc_nao_contr         = en_dm_calc_nao_contr    
             and dm_emit_com_suframa       = en_dm_emit_com_suframa
             and dm_dest_com_suframa       = en_dm_dest_com_suframa;
           --
       exception
         when others then
            return null;
       end;
      --
   else
      --
      begin
          --
          select id
            into vn_paramcalcicmsempr_id
            from param_calc_icms_empr
           where empresa_id                = en_empresa_id
             and dt_ini                    = ed_dt_ini
             and dt_fin                    is null
             and dm_tipo_param             = ev_dm_tipo_param
             and prioridade                = en_prioridade
             and ((cfop_id is null        and en_cfop_id is null)        or (cfop_id = en_cfop_id))
             and ((estado_id_dest is null and en_estado_id_dest is null) or (estado_id_dest = en_estado_id_dest))
             and ((ncm_id is null         and en_ncm_id is null)         or (ncm_id = en_ncm_id))
             and ((extipi_id is null      and en_extipi_id is null)      or (extipi_id = en_extipi_id))
             and ((dm_orig_merc is null   and en_dm_orig_merc is null)   or (dm_orig_merc = en_dm_orig_merc))
             and ((item_id is null        and en_item_id is null)        or (item_id = en_item_id))
             and ((natoper_id is null     and en_natoper_id is null)     or (natoper_id = en_natoper_id))
             and ((cpf_cnpj is null       and ev_cpf_cnpj is null)       or (cpf_cnpj = ev_cpf_cnpj))
             and dm_calc_fisica            = en_dm_calc_fisica
             and dm_calc_cons_final        = en_dm_calc_cons_final
             and dm_calc_contr_isento      = en_dm_calc_contr_isento                                                            
             and dm_calc_nao_contr         = en_dm_calc_nao_contr                                                               
             and dm_emit_com_suframa       = en_dm_emit_com_suframa
             and dm_dest_com_suframa       = en_dm_dest_com_suframa;
          --
       exception
         when others then
            return null;
       end;
      --
   end if;
   --
   return vn_paramcalcicmsempr_id;
   --
exception
  when others then
     return null;
end fkg_paramcalcicmsempr_id;

-------------------------------------------------------------------------------------------------------
--| Função de Retorno do ID da tabela de param_calc_icmsst_empr
function fkg_paramcalcicmsstempr_id ( en_empresa_id       in empresa.id%type
                                    , en_cfop_id          in cfop.id%type
                                    , en_estado_id_dest   in estado.id%type
                                    , ed_dt_ini           in param_calc_icmsst_empr.dt_ini%type   
                                    , ed_dt_fin           in param_calc_icmsst_empr.dt_fin%type
                                    , en_cest_id          in cest.id%type
                                    , en_ncm_id           in ncm.id%type
                                    , en_extipi_id        in ex_tipi.id%type
                                    , en_dm_orig_merc     in param_calc_icmsst_empr.dm_orig_merc%type
                                    , en_item_id          in item.id%type
                                    , ev_cpf_cnpj         in param_calc_icmsst_empr.cpf_cnpj%type
                                    , en_natoper_id       in nat_oper.id%type
                                    , en_dm_calc_fisica   in param_calc_icmsst_empr.dm_calc_fisica%type
                                    ) return param_calc_icmsst_empr.id%type
is
   --
   vn_paramcalcicmsstempr_id                                 param_calc_icmsst_empr.id%type;
   --
begin
   --
   vn_paramcalcicmsstempr_id := null;
   --
   begin
      --
      select id
        into vn_paramcalcicmsstempr_id
        from param_calc_icmsst_empr
       where empresa_id          = en_empresa_id
         and dt_ini              = ed_dt_ini
         and ((dt_fin is null         and ed_dt_fin is null)         or (dt_fin    = ed_dt_fin))
         and cfop_id             = en_cfop_id
         and estado_id_dest      = en_estado_id_dest
         and ((cest_id is null        and en_cest_id is null)        or (cest_id    = en_cest_id))
         and ((ncm_id is null         and en_ncm_id is null)         or (ncm_id     = en_ncm_id))
         and ((extipi_id is null      and en_extipi_id is null)      or (extipi_id    = en_extipi_id))
         and ((dm_orig_merc is null   and en_dm_orig_merc is null)   or (dm_orig_merc = en_dm_orig_merc))
         and ((item_id is null        and en_item_id is null)        or (item_id      = en_item_id))
         and ((natoper_id is null     and en_natoper_id is null)     or (natoper_id   = en_natoper_id))
         and ((cpf_cnpj is null       and ev_cpf_cnpj is null)       or (cpf_cnpj     = ev_cpf_cnpj))
         and ((dm_calc_fisica is null and en_dm_calc_fisica is null) or (dm_calc_fisica = en_dm_calc_fisica));
      --
   exception
    when no_data_found then
       return null;
   end;
   --
   return vn_paramcalcicmsstempr_id;
   --
exception
  when others then
     return null;
end fkg_paramcalcicmsstempr_id;

-------------------------------------------------------------------------------------------------------
--| Função de Retorno do ID da tabela de aliq_tipoimp_ncm_empresa
function fkg_aliqtipoimpncmempresa_id ( en_empresa_id          in empresa.id%type
                                      , ed_dt_ini              in aliq_tipoimp_ncm_empresa.dt_ini%type
                                      , ed_dt_fin              in aliq_tipoimp_ncm_empresa.dt_fin%type
                                      , ev_dm_tipo_param       in aliq_tipoimp_ncm_empresa.dm_tipo_param%type
                                      , en_prioridade          in aliq_tipoimp_ncm_empresa.prioridade%type
                                      , en_tipoimposto_id      in tipo_imposto.id%type
                                      , en_cfop_id             in cfop.id%type
                                      , en_ncm_id              in ncm.id%type
                                      , en_extipi_id           in ex_tipi.id%type
                                      , en_dm_orig_merc        in param_calc_icms.dm_orig_merc%type
                                      , en_item_id             in item.id%type
                                      , en_natoper_id          in nat_oper.id%type
                                      , ev_cpf_cnpj            in aliq_tipoimp_ncm_empresa.cpf_cnpj%type
                                      , en_dm_calc_cons_final  in aliq_tipoimp_ncm_empresa.dm_calc_cons_final%type
                                      ) return aliq_tipoimp_ncm_empresa.id%type
is
   --
   vn_aliqtipoimpncmempresa_id           aliq_tipoimp_ncm_empresa.id%type;
   --
begin
   --
   vn_aliqtipoimpncmempresa_id := 0;
   --
   begin
      --
      select id 
        into vn_aliqtipoimpncmempresa_id
        from aliq_tipoimp_ncm_empresa
       where empresa_id          = en_empresa_id
         and dt_ini              = ed_dt_ini
         and ((dt_fin is null         and ed_dt_fin is null)         or (dt_fin    = ed_dt_fin))
         and dm_tipo_param       = ev_dm_tipo_param
         and prioridade          = en_prioridade
         and tipoimposto_id      = en_tipoimposto_id
         and ((cfop_id is null        and en_cfop_id is null)        or (cfop_id = en_cfop_id))
         and ((ncm_id is null         and en_ncm_id is null)         or (ncm_id     = en_ncm_id))
         and ((extipi_id is null      and en_extipi_id is null)      or (extipi_id    = en_extipi_id))
         and ((dm_orig_merc is null   and en_dm_orig_merc is null)   or (dm_orig_merc = en_dm_orig_merc))
         and ((item_id is null        and en_item_id is null)        or (item_id      = en_item_id))
         and ((natoper_id is null     and en_natoper_id is null)     or (natoper_id   = en_natoper_id))
         and ((cpf_cnpj is null       and ev_cpf_cnpj is null)       or (cpf_cnpj     = ev_cpf_cnpj))
         and dm_calc_cons_final  = en_dm_calc_cons_final;
      --
   exception
    when no_data_found then
       return null;
   end;
   --
   return vn_aliqtipoimpncmempresa_id;
   --
exception
  when others then
     return null;
end fkg_aliqtipoimpncmempresa_id;

-------------------------------------------------------------------------------------------------------
--| Função de Retorno do ID da tabela de param_calc_retido
function fkg_paramcalcretido_id ( ed_dt_ini          in param_calc_retido.dt_ini%type
                                , ed_dt_fin          in param_calc_retido.dt_fin%type
                                , ev_dm_tipo_param   in param_calc_retido.dm_tipo_param%type
                                , en_prioridade      in param_calc_retido.prioridade%type
                                , en_tipoimposto_id  in tipo_imposto.id%type
                                , en_cfop_id         in cfop.id%type
                                , en_regtrib_id      in reg_trib.id%type
                                , en_formatrib_id    in forma_trib.id%type
                                , en_cnae_id         in cnae.id%type
                                , en_tiposervico_id  in tipo_servico.id%type
                                ) return param_calc_retido.id%type
is
   --
   vn_paramcalcretido_id    param_calc_retido.id%type;
   --
begin
   --
   vn_paramcalcretido_id := null;
   --
   if trim(ed_dt_fin) is not null then
      --
      begin
         --
          select id
            into vn_paramcalcretido_id
            from param_calc_retido
           where dt_ini                = ed_dt_ini
             and dt_fin                = ed_dt_fin
             and dm_tipo_param         = ev_dm_tipo_param
             and prioridade            = en_prioridade
             and tipoimposto_id        = en_tipoimposto_id
             and cfop_id               = en_cfop_id
             and ((regtrib_id is null     and en_regtrib_id is null)        or (regtrib_id     = en_regtrib_id))
             and ((formatrib_id is null   and en_formatrib_id is null)      or (formatrib_id   = en_formatrib_id))
             and ((cnae_id is null        and en_cnae_id is null)           or (cnae_id        = en_cnae_id))
             and ((tiposervico_id is null and en_tiposervico_id is null)    or (tiposervico_id = en_tiposervico_id));
         --
      exception
       when no_data_found then
          return null;
      end;
      --
   else
      --
      begin
         --
          select id
            into vn_paramcalcretido_id
            from param_calc_retido
           where dt_ini                = ed_dt_ini
             and dm_tipo_param         = ev_dm_tipo_param
             and prioridade            = en_prioridade
             and tipoimposto_id        = en_tipoimposto_id
             and cfop_id               = en_cfop_id
             and ((regtrib_id is null     and en_regtrib_id is null)        or (regtrib_id     = en_regtrib_id))
             and ((formatrib_id is null   and en_formatrib_id is null)      or (formatrib_id   = en_formatrib_id))
             and ((cnae_id is null        and en_cnae_id is null)           or (cnae_id        = en_cnae_id))
             and ((tiposervico_id is null and en_tiposervico_id is null)    or (tiposervico_id = en_tiposervico_id));
         --
      exception
       when no_data_found then
          return null;
      end;
      --
   end if;
   --
   return vn_paramcalcretido_id;
   --
exception
  when others then
     return null;
end fkg_paramcalcretido_id;

-------------------------------------------------------------------------------------------------------
--| Função de Retorno do ID da tabela de param_calc_iss
function fkg_paramcalciss_id ( ed_dt_ini              in param_calc_iss.dt_ini%type
                             , ed_dt_fin              in param_calc_iss.dt_fin%type
                             , en_cidade_id           in cidade.id%type
                             , en_dm_tipo_calc        in param_calc_iss.dm_tipo_calc%type
                             , en_cfop_id             in cfop.id%type
                             , en_regtrib_id          in reg_trib.id%type
                             , en_formatrib_id        in forma_trib.id%type
                             , en_cnae_id             in cnae.id%type
                             , en_codtribmunicipio_id in cod_trib_municipio.id%type
                             , en_tiposervico_id      in tipo_servico.id%type
                             ) return param_calc_iss.id%type
is
   --
   vn_paramcalciss_id         param_calc_iss.id%type;
   --
begin
   --
   vn_paramcalciss_id := null;
   --
   begin
      --
      select id
        into vn_paramcalciss_id
        from param_calc_iss
       where dt_ini                = ed_dt_ini
         and cidade_id             = en_cidade_id
         and dm_tipo_calc          = en_dm_tipo_calc
         and ((dt_fin              is null and ed_dt_fin       is null)        or (dt_fin              = ed_dt_fin))
         and ((cfop_id             is null and en_cfop_id      is null)        or (cfop_id             = en_cfop_id))
         and ((regtrib_id          is null and en_regtrib_id   is null)        or (regtrib_id          = en_regtrib_id))
         and ((formatrib_id        is null and en_formatrib_id is null)        or (formatrib_id        = en_formatrib_id))
         and ((cnae_id             is null and en_cnae_id      is null)        or (cnae_id             = en_cnae_id))
         and ((codtribmunicipio_id is null and en_codtribmunicipio_id is null) or (codtribmunicipio_id = en_codtribmunicipio_id))
         and ((tiposervico_id      is null and en_tiposervico_id      is null) or (tiposervico_id      = en_tiposervico_id));
      --
   exception
    when no_data_found then
       return null;
   end;
   --
exception
   when others then
      return sqlerrm;
end fkg_paramcalciss_id;
-------------------------------------------------------------------------------------------------------
--| Função de Retorno do ID da tabela de cfop_part_icms_estado
function fkg_cfopparticmsestado_id ( en_estado_id_orig in cfop_part_icms_estado.ESTADO_ID_ORIG%type
                                   , en_estado_id_dest in cfop_part_icms_estado.ESTADO_ID_ORIG%type
                                   , ed_dt_ini         in cfop_part_icms_estado.dt_ini%type
                                   , ed_dt_fin         in cfop_part_icms_estado.dt_fin%type
                                   , en_cfop_id        in cfop.id%type
                                   , en_ncm_id         in ncm.id%type
                                   ) return cfop_part_icms_estado.id%type
is
   --
   vn_cfopparticmsestado_id        cfop_part_icms_estado.id%type;
   --
begin
   --
   vn_cfopparticmsestado_id := null;
   --
   begin
      --
      select id
        into vn_cfopparticmsestado_id
        from cfop_part_icms_estado
       where estado_id_orig  = en_estado_id_orig
         and estado_id_dest  = en_estado_id_dest
         and dt_ini          = ed_dt_ini
         and ((dt_fin is null        and ed_dt_fin is null)        or (dt_fin = ed_dt_fin))
         and cfop_id               = en_cfop_id
         and ((ncm_id is null         and en_ncm_id is null)         or (ncm_id     = en_ncm_id));
      --
   exception
    when no_data_found then
       return null;
   end;
   --
   return vn_cfopparticmsestado_id;
   --
exception
   when others then
      return sqlerrm;
end fkg_cfopparticmsestado_id;

-------------------------------------------------------------------------------------------------------
--| Função de Retorno do ID da tabela de param_calc_icms
function fkg_paramcalcicms_id ( ed_dt_ini               in param_calc_icms.dt_ini%type
                              , ed_dt_fin               in param_calc_icms.dt_fin%type
                              , ev_dm_tipo_param        in param_calc_icms.dm_tipo_param%type
                              , en_prioridade           in param_calc_icms.prioridade%type
                              , en_cfop_id              in cfop.id%type
                              , en_regtrib_id           in reg_trib.id%type
                              , en_formatrib_id         in forma_trib.id%type
                              , en_estado_id_orig       in estado.id%type
                              , en_estado_id_dest       in estado.id%type
                              , en_cnae_id              in cnae.id%type
                              , en_ncm_id               in ncm.id%type
                              , en_extipi_id            in ex_tipi.id%type
                              , en_dm_orig_merc         in param_calc_icms.dm_orig_merc%type
                              , en_dm_calc_fisica       in param_calc_icms.dm_calc_fisica%type
                              , en_dm_calc_cons_final   in param_calc_icms.dm_calc_cons_final%type
                              , en_dm_calc_contr_isento in param_calc_icms.dm_calc_contr_isento%type
                              , en_dm_calc_nao_contr    in param_calc_icms.dm_calc_nao_contr%type
                              , en_dm_emit_com_suframa  in param_calc_icms.dm_emit_com_suframa%type
                              , en_dm_dest_com_suframa  in param_calc_icms.dm_dest_com_suframa%type
                              ) return param_calc_icms.id%type
is
   --
   vn_paramcalcicms_id        param_calc_icms.id%type;
   --
begin
   --
   vn_paramcalcicms_id := 0;
   --
   begin
      --
      select id
        into vn_paramcalcicms_id
        from param_calc_icms
       where dt_ini                = ed_dt_ini
         and ((dt_fin is null        and ed_dt_fin is null)        or (dt_fin = ed_dt_fin))
         and dm_tipo_param         = ev_dm_tipo_param
         and prioridade            = en_prioridade
         and ((cfop_id is null        and en_cfop_id is null)        or (cfop_id = en_cfop_id))
         and ((regtrib_id is null     and en_regtrib_id is null)        or (regtrib_id     = en_regtrib_id))
         and ((formatrib_id is null   and en_formatrib_id is null)      or (formatrib_id   = en_formatrib_id))
         and estado_id_orig        = en_estado_id_orig
         and ((estado_id_dest is null and en_estado_id_dest is null)      or (estado_id_dest    = en_estado_id_dest))
         and ((cnae_id is null        and en_cnae_id is null)           or (cnae_id        = en_cnae_id))
         and ((ncm_id is null         and en_ncm_id is null)         or (ncm_id     = en_ncm_id))
         and ((extipi_id is null      and en_extipi_id is null)      or (extipi_id    = en_extipi_id))
         and dm_orig_merc          = en_dm_orig_merc
         and dm_calc_fisica        = en_dm_calc_fisica
         and dm_calc_cons_final    = en_dm_calc_cons_final
         and dm_calc_contr_isento  = en_dm_calc_contr_isento
         and dm_calc_nao_contr     = en_dm_calc_nao_contr
         and dm_emit_com_suframa   = en_dm_emit_com_suframa
         and dm_dest_com_suframa   = en_dm_dest_com_suframa;
      --
   exception
     when no_data_found then
        null;
   end;
   --
   return vn_paramcalcicms_id;
   --
exception
   when others then
      return sqlerrm;
end fkg_paramcalcicms_id;

-------------------------------------------------------------------------------------------------------
--| Função de Retorno do ID da tabela de param_calc_icmsst
function fkg_paramcalcicmsst_id ( ed_dt_ini          in param_calc_icmsst.dt_ini%type
                                , ed_dt_fin          in param_calc_icmsst.dt_fin%type
                             --   , ev_dm_tipo_param   in param_calc_icmsst.dm_tipo_param%type
                             --   , en_prioridade      in param_calc_icmsst.prioridade%type
                                , en_cfop_id         in cfop.id%type
                                , en_regtrib_id      in reg_trib.id%type
                                , en_formatrib_id    in forma_trib.id%type
                                , en_estado_id_orig  in estado.id%type
                                , en_estado_id_dest  in estado.id%type
                                , en_cnae_id         in cnae.id%type
                                , en_cest_id         in cest.id%type
                                , en_ncm_id          in ncm.id%type
                                , en_extipi_id       in ex_tipi.id%type
                                , en_dm_orig_merc    in param_calc_icmsst.dm_tipo_param%type
                                , en_dm_calc_fisica  in param_calc_icmsst.DM_CALC_FISICA%type
                                ) return param_calc_icmsst.id%type
is
   --
   vn_paramcalcicmsst_id        param_calc_icmsst.id%type;
   --
begin
   --
   vn_paramcalcicmsst_id := 0;
   --
   begin
      --
      select id
        into vn_paramcalcicmsst_id
        from param_calc_icmsst
       where dt_ini               = ed_dt_ini
         and ((dt_fin is null        and ed_dt_fin is null)        or (dt_fin = ed_dt_fin))
        -- and dm_tipo_param        = ev_dm_tipo_param
        -- and prioridade           = en_prioridade
         and cfop_id              = en_cfop_id
         and ((regtrib_id is null     and en_regtrib_id is null)        or (regtrib_id     = en_regtrib_id))
         and ((formatrib_id is null   and en_formatrib_id is null)      or (formatrib_id   = en_formatrib_id))
         and estado_id_orig       = en_estado_id_orig
         and estado_id_dest       = en_estado_id_dest
         and ((cnae_id is null        and en_cnae_id is null)        or (cnae_id        = en_cnae_id))
         and ((cest_id is null        and en_cest_id is null)        or (cest_id    = en_cest_id))
         and ((ncm_id is null         and en_ncm_id is null)         or (ncm_id     = en_ncm_id))
         and ((extipi_id is null      and en_extipi_id is null)      or (extipi_id    = en_extipi_id))
         and ((dm_orig_merc is null   and en_dm_orig_merc is null)   or (dm_orig_merc  = en_dm_orig_merc))
         and ((dm_calc_fisica is null and en_dm_calc_fisica is null) or (dm_calc_fisica = en_dm_calc_fisica));
      --
   exception
    when no_data_found then
       return null;
   end;
   --
   return vn_paramcalcicmsst_id;
   --
exception
   when others then
      return sqlerrm;
end fkg_paramcalcicmsst_id;

-------------------------------------------------------------------------------------------------------
--| Função de Retorno do ID da tabela de ALIQ_TIPOIMP_NCM
function fkg_aliqtipoimpncm_id ( ed_dt_ini             in aliq_tipoimp_ncm.dt_ini%type
                               , ed_dt_fin             in aliq_tipoimp_ncm.dt_fin%type --
                               , en_tipoimposto_id     in tipo_imposto.id%type
                               , en_inctrib_id         in inc_trib.id%type             --
                               , en_regtrib_id         in reg_trib.id%type             --
                               , en_formatrib_id       in forma_trib.id%type           --
                               , en_cnae_id            in cnae.id%type                 --
                               , en_cfop_id            in cfop.id%type                 --
                               , en_ncm_id             in ncm.id%type             --
                               , en_extipi_id          in ex_tipi.id%type     --
                               , en_dm_orig_merc       in aliq_tipoimp_ncm.dm_orig_merc%type --
                               , en_dm_calc_cons_final in aliq_tipoimp_ncm.dm_calc_cons_final%type
                               ) return aliq_tipoimp_ncm.id%type
is
   --
   vn_aliqtipoimpncm_id        aliq_tipoimp_ncm.id%type;
   --
begin
   --
   vn_aliqtipoimpncm_id := null;
   --
   begin
      --
      select id
        into vn_aliqtipoimpncm_id
        from aliq_tipoimp_ncm  al
       where al.dt_ini = ed_dt_ini
         and ((dt_fin is null                and ed_dt_fin is null)        or (dt_fin = ed_dt_fin))
         and ((tipoimposto_id is null        and en_tipoimposto_id is null)        or (tipoimposto_id = en_tipoimposto_id)) 
         and ((al.inctrib_id is null         and en_inctrib_id is null)            or (al.inctrib_id = en_inctrib_id))
         and ((al.regtrib_id is null         and en_regtrib_id is null)            or (al.regtrib_id = en_regtrib_id))
         and ((al.formatrib_id is null         and en_formatrib_id is null)            or (al.formatrib_id = en_formatrib_id))
         and ((al.cnae_id is null         and en_cnae_id is null)            or (al.cnae_id = en_cnae_id))
         and ((al.cfop_id is null         and en_cfop_id is null)            or (al.cfop_id = en_cfop_id))
         and ((al.ncm_id is null          and en_ncm_id is null)             or (al.ncm_id = en_ncm_id))
         and ((al.extipi_id is null         and en_extipi_id is null)        or (al.extipi_id = en_extipi_id))
         and ((al.dm_orig_merc is null         and en_dm_orig_merc is null)            or (al.dm_orig_merc = en_dm_orig_merc))
          and en_dm_calc_cons_final                                                     = al.dm_calc_cons_final;
      --
   exception
     when no_data_found then
      return null;
   end;
   --
   return vn_aliqtipoimpncm_id;
   --
exception
   when others then
      return sqlerrm;
end fkg_aliqtipoimpncm_id;

-------------------------------------------------------------------------------------------------------
--| Função de Retorno o ID da tabela de CFOP_TIPOIMP
function fkg_cfoptipoimp_id ( en_cfop_id          in cfop.cd%type
                            , en_regtrib_id       in reg_trib.cd%type
                            , en_formatrib        in forma_trib.cd%type
                            , en_tipoimposto_id   in tipo_imposto.cd%type
                            , en_dm_tipo_calc     in cfop_tipoimp.dm_tipo_calc%type
                            ) return cfop_tipoimp.id%type
is
   --
   vn_cfoptipoimp_id        cfop_tipoimp.id%type;
   --
begin
   --
   vn_cfoptipoimp_id := null;
   --
   if nvl(en_cfop_id,0) > 0
    and nvl(en_regtrib_id,0) > 0
    and nvl(en_formatrib,0) > 0
    and nvl(en_tipoimposto_id,0) > 0
    and nvl(en_dm_tipo_calc,-1) >= 0 then
      --
      begin
         --
         select id
           into vn_cfoptipoimp_id
           from cfop_tipoimp ct
          where ct.cfop_id         = en_cfop_id
            and ct.regtrib_id      = en_regtrib_id
            and ct.formatrib_id    = en_formatrib
            and ct.tipoimposto_id  = en_tipoimposto_id
            and ct.dm_tipo_calc    = en_dm_tipo_calc;
         --
      exception
         when no_data_found then
           vn_cfoptipoimp_id := null;
      end;
      --
   elsif nvl(en_cfop_id,0) > 0
     and nvl(en_regtrib_id,0) <= 0
     and nvl(en_formatrib,0) > 0
     and nvl(en_regtrib_id,0) > 0
     and nvl(en_tipoimposto_id,0) > 0
     and nvl(en_dm_tipo_calc,-1) >= 0 then
      --
      begin
         --
         select id
           into vn_cfoptipoimp_id
           from cfop_tipoimp ct
          where ct.cfop_id         = en_cfop_id
            and ct.formatrib_id    = en_formatrib
            and ct.tipoimposto_id  = en_tipoimposto_id
            and ct.dm_tipo_calc    = en_dm_tipo_calc;
         --
      exception
         when no_data_found then
           vn_cfoptipoimp_id := null;
      end;
      --
   elsif nvl(en_cfop_id,0) > 0
     and nvl(en_regtrib_id,0) > 0
     and nvl(en_formatrib,0) <= 0
     and nvl(en_regtrib_id,0) > 0
     and nvl(en_tipoimposto_id,0) > 0
     and nvl(en_dm_tipo_calc,-1) >= 0 then
      --
      begin
         --
         select id
           into vn_cfoptipoimp_id
           from cfop_tipoimp ct
          where ct.cfop_id         = en_cfop_id
            and ct.regtrib_id      = en_regtrib_id
            and ct.tipoimposto_id  = en_tipoimposto_id
            and ct.dm_tipo_calc    = en_dm_tipo_calc;
         --
      exception
        when no_data_found then
          vn_cfoptipoimp_id := null;
      end;
      --
   else
      --
      begin
         --
         select id
           into vn_cfoptipoimp_id
           from cfop_tipoimp ct
          where ct.cfop_id         = en_cfop_id
            and ct.tipoimposto_id  = en_tipoimposto_id
            and ct.dm_tipo_calc    = en_dm_tipo_calc;
         --
      exception
        when no_data_found then
          vn_cfoptipoimp_id := null;
      end;
      --
   end if;
   --
   return vn_cfoptipoimp_id;
   --
exception
   when others then
      return null;
end fkg_cfoptipoimp_id;

-------------------------------------------------------------------------------------------------------

--| Função de retornar o ID da Observação Fiscal
function fkg_obsfiscal_id ( ev_cod_of  in obs_fiscal.cod_of%type )
         return obs_fiscal.id%type
is
   --
   vn_obsfiscal_id obs_fiscal.id%type;
   --
begin
   --
   select id
     into vn_obsfiscal_id
     from obs_fiscal
    where cod_of = ev_cod_of;
   --
   return vn_obsfiscal_id;
   --
exception
   when others then
      return null;
end fkg_obsfiscal_id;

-------------------------------------------------------------------------------------------------------

--| Função de retornar o registro da Observação Fiscal
function fkg_obsfiscal_row ( en_obsfiscal_id in obs_fiscal.id%type )
         return obs_fiscal%rowtype
is
   --
   vt_obs_fiscal obs_fiscal%rowtype;
   --
begin
   --
   select *
     into vt_obs_fiscal
     from obs_fiscal
    where id = en_obsfiscal_id;
   --
   return vt_obs_fiscal;
   --
exception
   when others then
      return null;
end fkg_obsfiscal_row;

-------------------------------------------------------------------------------------------------------

--| Função de retornar o código da Observação Fiscal
function fkg_obsfiscal_codof ( en_obsfiscal_id in obs_fiscal.id%type )
         return obs_fiscal.cod_of%type
is
   --
   vv_cod_of         obs_fiscal.cod_of%type;
   --
begin
   --
   begin
      --
      select cod_of
        into vv_cod_of
        from obs_fiscal
       where id = en_obsfiscal_id;
      --
   exception
     when others then
        return null;
   end;
   --
   return vv_cod_of;
   --
exception
 when others then
   return null;
end fkg_obsfiscal_codof;

-------------------------------------------------------------------------------------------------------

--| Função retorna TRUE se existe a Solicitacao de Calculo
function fkg_existe_solic_calc ( en_soliccalc_id in solic_calc.id%type )
         return boolean
is
   --
   vn_dummy number := 0;
   --
begin
   --
   begin
      --
      select 1 into vn_dummy
        from solic_calc
       where id = en_soliccalc_id;
      --
   exception
      when others then
         vn_dummy := 0;
   end;
   --
   return (vn_dummy > 0);
   --
exception
   when others then
      return false;
end fkg_existe_solic_calc;

-------------------------------------------------------------------------------------------------------

-- Função retorna a memoria do parametro de Partilha de ICMS nível Empresa
function fkg_mem_param_icms_inter_cf ( en_paramicmsintercf_id in param_icms_inter_cf.id%type )
         return varchar2
is
   --
   vv_memoria              varchar2(4000);
   vt_param_icms_inter_cf  param_icms_inter_cf%rowtype;
   vv_empresa              varchar2(255);
   --
begin
   --
   vv_memoria := null;
   --
   begin
      --
      select * into vt_param_icms_inter_cf
        from param_icms_inter_cf
       where id = en_paramicmsintercf_id;
      --
   exception
      when others then
         vt_param_icms_inter_cf := null;
   end;
   --
   if nvl(vt_param_icms_inter_cf.id,0) > 0 then
      --
      begin
         --
         select p.cod_part || '-' || p.nome
           into vv_empresa
           from empresa e
              , pessoa p
          where e.id = vt_param_icms_inter_cf.empresa_id
            and p.id = e.pessoa_id;
         --
      exception
         when others then
            vv_empresa := null;
      end;
      --
      -- Montagem da memoria
      vv_memoria := 'Parametro de Partilha de ICMS nivel da Empresa;';
      vv_memoria := vv_memoria || 'Identificador:;' || vt_param_icms_inter_cf.id || ';';
      vv_memoria := vv_memoria || 'Empresa:;' || vv_empresa || ';';
      vv_memoria := vv_memoria || ' Estado Destino:;' || pk_csf.fkg_Estado_id_sigla ( en_estado_id => vt_param_icms_inter_cf.estado_id ) || ';';
      vv_memoria := vv_memoria || ' Data Inicial:;' || to_char(vt_param_icms_inter_cf.dt_ini, 'dd/mm/rrrr') || ';';
      vv_memoria := vv_memoria || ' Data Final:;' || to_char(nvl(vt_param_icms_inter_cf.dt_fin, sysdate), 'dd/mm/rrrr') || ';';
      vv_memoria := vv_memoria || ' CFOP:;' || pk_csf.fkg_cfop_cd ( en_cfop_id => vt_param_icms_inter_cf.cfop_id ) || ';';
      vv_memoria := vv_memoria || ' NCM:;' || pk_csf.fkg_cod_ncm_id ( en_ncm_id => vt_param_icms_inter_cf.ncm_id ) || ';';
      vv_memoria := vv_memoria || ' Item (Produto):;' || pk_csf.fkg_Item_cod ( en_item_id => vt_param_icms_inter_cf.item_id ) || ';';
      --
   end if;
   --
   return vv_memoria;
   --
exception
   when others then
      return null;
end fkg_mem_param_icms_inter_cf;

-------------------------------------------------------------------------------------------------------

-- Função retorna a memoria do parametro de Partilha de ICMS nível Global
function fkg_mem_cfop_part_icms_estado ( en_cfopparticmsestado_id in cfop_part_icms_estado.id%type )
         return varchar2
is
   --
   vv_memoria                varchar2(4000);
   vt_cfop_part_icms_estado  cfop_part_icms_estado%rowtype;
   --
begin
   --
   vv_memoria := null;
   --
   begin
      --
      select * into vt_cfop_part_icms_estado
        from cfop_part_icms_estado
       where id = en_cfopparticmsestado_id;
      --
   exception
      when others then
         vt_cfop_part_icms_estado := null;
   end;
   --
   if nvl(vt_cfop_part_icms_estado.id,0) > 0 then
      --
      -- Montagem da memoria
      vv_memoria := 'Parametro de Partilha de ICMS nivel Global;';
      vv_memoria := vv_memoria || ' Identificador:;' || vt_cfop_part_icms_estado.id || ';';
      vv_memoria := vv_memoria || ' Estado Origem:;' || pk_csf.fkg_Estado_id_sigla ( en_estado_id => vt_cfop_part_icms_estado.estado_id_orig ) || ';';
      vv_memoria := vv_memoria || ' Estado Destino:;' || pk_csf.fkg_Estado_id_sigla ( en_estado_id => vt_cfop_part_icms_estado.estado_id_dest ) || ';';
      vv_memoria := vv_memoria || ' Data Inicial:;' || to_char(vt_cfop_part_icms_estado.dt_ini, 'dd/mm/rrrr') || ';';
      vv_memoria := vv_memoria || ' Data Final:;' || to_char(nvl(vt_cfop_part_icms_estado.dt_fin, sysdate), 'dd/mm/rrrr') || ';';
      vv_memoria := vv_memoria || ' CFOP:;' || pk_csf.fkg_cfop_cd ( en_cfop_id => vt_cfop_part_icms_estado.cfop_id ) || ';';
      vv_memoria := vv_memoria || ' NCM:;' || pk_csf.fkg_cod_ncm_id ( en_ncm_id => vt_cfop_part_icms_estado.ncm_id ) || ';';
      --
   end if;
   --
   return vv_memoria;
   --
exception
   when others then
      return null;
end fkg_mem_cfop_part_icms_estado;

-------------------------------------------------------------------------------------------------------

-- Função retorna a memoria de Parametro de Calculo de ICMS para Empresa
function fkg_mem_param_calc_icms_empr ( en_paramcalcicmsempr_id in param_calc_icms_empr.id%type )
         return varchar2
is
   --
   vv_memoria               imp_itemsc.memoria%type;
   vt_param_calc_icms_empr  param_calc_icms_empr%rowtype;
   vv_empresa              varchar2(255);
   --
begin
   --
   vv_memoria := null;
   --
   begin
      --
      select * into vt_param_calc_icms_empr
        from param_calc_icms_empr
       where id = en_paramcalcicmsempr_id;
      --
   exception
      when others then
         vt_param_calc_icms_empr := null;
   end;
   --
   if nvl(vt_param_calc_icms_empr.id,0) > 0 then
      --
      begin
         --
         select p.cod_part || '-' || p.nome
           into vv_empresa
           from empresa e
              , pessoa p
          where e.id = vt_param_calc_icms_empr.empresa_id
            and p.id = e.pessoa_id;
         --
      exception
         when others then
            vv_empresa := null;
      end;
      --
      vv_memoria := 'Parametro de Calculo de ICMS nivel Empresa;';
      vv_memoria := vv_memoria || 'Identificador;' || vt_param_calc_icms_empr.id || ';';
      vv_memoria := vv_memoria || 'Empresa;' || vv_empresa || ';';
      vv_memoria := vv_memoria || 'Tipo de Parametro;' || pk_csf.fkg_dominio('PARAM_CALC_ICMS_EMPR.DM_TIPO_PARAM', vt_param_calc_icms_empr.dm_tipo_param) || ';';
      vv_memoria := vv_memoria || 'Prioridade;' || vt_param_calc_icms_empr.prioridade || ';';
      vv_memoria := vv_memoria || 'Data Inicial:;' || to_char(vt_param_calc_icms_empr.dt_ini, 'dd/mm/rrrr') || ';';
      vv_memoria := vv_memoria || 'Data Final:;' || to_char(nvl(vt_param_calc_icms_empr.dt_fin, sysdate), 'dd/mm/rrrr') || ';';
      vv_memoria := vv_memoria || 'CFOP:;' || pk_csf.fkg_cfop_cd ( en_cfop_id => vt_param_calc_icms_empr.cfop_id ) || ';';
      vv_memoria := vv_memoria || 'Estado Destino:;' || pk_csf.fkg_Estado_id_sigla ( en_estado_id => vt_param_calc_icms_empr.estado_id_dest ) || ';';
      vv_memoria := vv_memoria || 'NCM:;' || pk_csf.fkg_cod_ncm_id ( en_ncm_id => vt_param_calc_icms_empr.ncm_id ) || ';';
      vv_memoria := vv_memoria || 'Ex-Tipi:;' || pk_csf.fkg_ex_tipi_cod ( en_extipi_id => vt_param_calc_icms_empr.extipi_id ) || ';';
      vv_memoria := vv_memoria || 'Origem Mercadoria;' || pk_csf.fkg_dominio('PARAM_CALC_ICMS_EMPR.DM_ORIG_MERC', vt_param_calc_icms_empr.dm_orig_merc) || ';';
      vv_memoria := vv_memoria || 'Item (Produto):;' || pk_csf.fkg_Item_cod ( en_item_id => vt_param_calc_icms_empr.item_id ) || ';';
      vv_memoria := vv_memoria || 'CPF/CNPJ Participante;' || vt_param_calc_icms_empr.cpf_cnpj || ';';
      vv_memoria := vv_memoria || 'Natureza de Operacao;' || pk_csf.fkg_cod_nat_id ( en_natoper_id => vt_param_calc_icms_empr.natoper_id ) || ';';
      vv_memoria := vv_memoria || 'Calcula Pessoa Fisica;' || pk_csf.fkg_dominio('PARAM_CALC_ICMS_EMPR.DM_CALC_FISICA', vt_param_calc_icms_empr.dm_calc_fisica) || ';';
      vv_memoria := vv_memoria || 'Calcula Consumidor Final;' || pk_csf.fkg_dominio('PARAM_CALC_ICMS_EMPR.DM_CALC_CONS_FINAL', vt_param_calc_icms_empr.dm_calc_cons_final) || ';';
      vv_memoria := vv_memoria || 'Calcula Contribuinte Isento;' || pk_csf.fkg_dominio('PARAM_CALC_ICMS_EMPR.DM_CALC_CONTR_ISENTO', vt_param_calc_icms_empr.dm_calc_contr_isento) || ';';
      vv_memoria := vv_memoria || 'Calcula Não Contribuinte;' || pk_csf.fkg_dominio('PARAM_CALC_ICMS_EMPR.DM_CALC_NAO_CONTR', vt_param_calc_icms_empr.dm_calc_nao_contr) || ';';
      vv_memoria := vv_memoria || 'Emitente com Suframa;' || pk_csf.fkg_dominio('PARAM_CALC_ICMS_EMPR.DM_EMIT_COM_SUFRAMA', vt_param_calc_icms_empr.dm_emit_com_suframa) || ';';
      vv_memoria := vv_memoria || 'Destinatário com Suframa;' || pk_csf.fkg_dominio('PARAM_CALC_ICMS_EMPR.DM_DEST_COM_SUFRAMA', vt_param_calc_icms_empr.dm_dest_com_suframa) || ';';
      --
   end if;
   --
   return vv_memoria;
   --
exception
   when others then
      return null;
end fkg_mem_param_calc_icms_empr;

-------------------------------------------------------------------------------------------------------

-- Função retorna a memoria de Parametros de Calculo de ICMS
function fkg_mem_param_calc_icms ( en_paramcalcicms_id in param_calc_icms.id%type )
         return varchar2
is
   --
   vv_memoria              imp_itemsc.memoria%type;
   vt_param_calc_icms      param_calc_icms%rowtype;
   vv_reg_trib             varchar2(100);
   vv_forma_trib           varchar2(100);
   --
begin
   --
   vv_memoria := null;
   --
   begin
      --
      select * into vt_param_calc_icms
        from param_calc_icms
       where id = en_paramcalcicms_id;
      --
   exception
      when others then
         vt_param_calc_icms := null;
   end;
   --
   if nvl(vt_param_calc_icms.id,0) > 0 then
      --
      vv_memoria := 'Parametro de Calculo de ICMS nivel Global;';
      vv_memoria := vv_memoria || 'Identificador;' || vt_param_calc_icms.id || ';';
      vv_memoria := vv_memoria || 'Tipo de Parametro;' || pk_csf.fkg_dominio('PARAM_CALC_ICMS.DM_TIPO_PARAM', vt_param_calc_icms.dm_tipo_param) || ';';
      vv_memoria := vv_memoria || 'Prioridade;' || vt_param_calc_icms.prioridade || ';';
      vv_memoria := vv_memoria || 'Data Inicial:;' || to_char(vt_param_calc_icms.dt_ini, 'dd/mm/rrrr') || ';';
      vv_memoria := vv_memoria || 'Data Final:;' || to_char(nvl(vt_param_calc_icms.dt_fin, sysdate), 'dd/mm/rrrr') || ';';
      --
      begin
         --
         select cd || '-' || descr
           into vv_reg_trib
           from reg_trib
          where id = vt_param_calc_icms.regtrib_id;
         --
      exception
         when others then
            vv_reg_trib := null;
      end;
      --
      begin
         --
         select cd || '-' || descr
           into vv_forma_trib
           from forma_trib
          where id = vt_param_calc_icms.formatrib_id;
         --
      exception
         when others then
            vv_forma_trib := null;
      end;
      --
      vv_memoria := vv_memoria || 'Regime Tributario:;' || vv_reg_trib || ';';
      vv_memoria := vv_memoria || 'Forma de Tributacao:;' || vv_forma_trib || ';';
      vv_memoria := vv_memoria || 'CNAE:;' || pk_csf.fkg_cd_cnae_id ( en_cnae_id => vt_param_calc_icms.cnae_id ) || ';';
      --
      vv_memoria := vv_memoria || 'CFOP:;' || pk_csf.fkg_cfop_cd ( en_cfop_id => vt_param_calc_icms.cfop_id ) || ';';
      vv_memoria := vv_memoria || 'Estado Origem:;' || pk_csf.fkg_Estado_id_sigla ( en_estado_id => vt_param_calc_icms.estado_id_orig ) || ';';
      vv_memoria := vv_memoria || 'Estado Destino:;' || pk_csf.fkg_Estado_id_sigla ( en_estado_id => vt_param_calc_icms.estado_id_dest ) || ';';
      vv_memoria := vv_memoria || 'NCM:;' || pk_csf.fkg_cod_ncm_id ( en_ncm_id => vt_param_calc_icms.ncm_id ) || ';';
      vv_memoria := vv_memoria || 'Ex-Tipi:;' || pk_csf.fkg_ex_tipi_cod ( en_extipi_id => vt_param_calc_icms.extipi_id ) || ';';
      vv_memoria := vv_memoria || 'Origem Mercadoria;' || pk_csf.fkg_dominio('PARAM_CALC_ICMS.DM_ORIG_MERC', vt_param_calc_icms.dm_orig_merc) || ';';
      vv_memoria := vv_memoria || 'Calcula Pessoa Fisica;' || pk_csf.fkg_dominio('PARAM_CALC_ICMS.DM_CALC_FISICA', vt_param_calc_icms.dm_calc_fisica) || ';';
      vv_memoria := vv_memoria || 'Calcula Consumidor Final;' || pk_csf.fkg_dominio('PARAM_CALC_ICMS.DM_CALC_CONS_FINAL', vt_param_calc_icms.dm_calc_cons_final) || ';';
      vv_memoria := vv_memoria || 'Calcula Contribuinte Isento;' || pk_csf.fkg_dominio('PARAM_CALC_ICMS.DM_CALC_CONTR_ISENTO', vt_param_calc_icms.dm_calc_contr_isento) || ';';
      vv_memoria := vv_memoria || 'Calcula Não Contribuinte;' || pk_csf.fkg_dominio('PARAM_CALC_ICMS.DM_CALC_NAO_CONTR', vt_param_calc_icms.dm_calc_nao_contr) || ';';
      vv_memoria := vv_memoria || 'Emitente com Suframa;' || pk_csf.fkg_dominio('PARAM_CALC_ICMS.DM_EMIT_COM_SUFRAMA', vt_param_calc_icms.dm_emit_com_suframa) || ';';
      vv_memoria := vv_memoria || 'Destinatário com Suframa;' || pk_csf.fkg_dominio('PARAM_CALC_ICMS.DM_DEST_COM_SUFRAMA', vt_param_calc_icms.dm_dest_com_suframa) || ';';
      --
   end if;
   --
   return vv_memoria;
   --
exception
   when others then
      return null;
end fkg_mem_param_calc_icms;

-------------------------------------------------------------------------------------------------------

-- Função retorna a memoria de Parametros de Calculo de ICMS-ST
function fkg_mem_param_calc_icmsst ( en_paramcalcicmsst_id in param_calc_icmsst.id%type )
         return varchar2
is
   --
   vv_memoria              imp_itemsc.memoria%type;
   vt_param_calc_icmsst    param_calc_icmsst%rowtype;
   vv_reg_trib             varchar2(100);
   vv_forma_trib           varchar2(100);
   --
begin
   --
   vv_memoria := null;
   --
   begin
      --
      select * into vt_param_calc_icmsst
        from param_calc_icmsst
       where id = en_paramcalcicmsst_id;
      --
   exception
      when others then
         vt_param_calc_icmsst := null;
   end;
   --
   if nvl(vt_param_calc_icmsst.id,0) > 0 then
      --
      vv_memoria := 'Parametro de Calculo de ICMS-ST nivel Global;';
      vv_memoria := vv_memoria || 'Identificador;' || vt_param_calc_icmsst.id || ';';
      vv_memoria := vv_memoria || 'Tipo de Parametro;' || pk_csf.fkg_dominio('PARAM_CALC_ICMSST.DM_TIPO_PARAM', vt_param_calc_icmsst.dm_tipo_param) || ';';
      vv_memoria := vv_memoria || 'Prioridade;' || vt_param_calc_icmsst.prioridade || ';';
      vv_memoria := vv_memoria || 'Data Inicial:;' || to_char(vt_param_calc_icmsst.dt_ini, 'dd/mm/rrrr') || ';';
      vv_memoria := vv_memoria || 'Data Final:;' || to_char(nvl(vt_param_calc_icmsst.dt_fin, sysdate), 'dd/mm/rrrr') || ';';
      --
      begin
         --
         select cd || '-' || descr
           into vv_reg_trib
           from reg_trib
          where id = vt_param_calc_icmsst.regtrib_id;
         --
      exception
         when others then
            vv_reg_trib := null;
      end;
      --
      begin
         --
         select cd || '-' || descr
           into vv_forma_trib
           from forma_trib
          where id = vt_param_calc_icmsst.formatrib_id;
         --
      exception
         when others then
            vv_forma_trib := null;
      end;
      --
      vv_memoria := vv_memoria || 'Regime Tributario:;' || vv_reg_trib || ';';
      vv_memoria := vv_memoria || 'Forma de Tributacao:;' || vv_forma_trib || ';';
      vv_memoria := vv_memoria || 'CNAE:;' || pk_csf.fkg_cd_cnae_id ( en_cnae_id => vt_param_calc_icmsst.cnae_id ) || ';';
      --
      vv_memoria := vv_memoria || 'CFOP:;' || pk_csf.fkg_cfop_cd ( en_cfop_id => vt_param_calc_icmsst.cfop_id ) || ';';
      vv_memoria := vv_memoria || 'Estado Origem:;' || pk_csf.fkg_Estado_id_sigla ( en_estado_id => vt_param_calc_icmsst.estado_id_orig ) || ';';
      vv_memoria := vv_memoria || 'Estado Destino:;' || pk_csf.fkg_Estado_id_sigla ( en_estado_id => vt_param_calc_icmsst.estado_id_dest ) || ';';
      vv_memoria := vv_memoria || 'CEST:;' || pk_csf.fkg_cd_cest_id ( en_cest_id => vt_param_calc_icmsst.cest_id ) || ';';
      vv_memoria := vv_memoria || 'NCM:;' || pk_csf.fkg_cod_ncm_id ( en_ncm_id => vt_param_calc_icmsst.ncm_id ) || ';';
      vv_memoria := vv_memoria || 'Ex-Tipi:;' || pk_csf.fkg_ex_tipi_cod ( en_extipi_id => vt_param_calc_icmsst.extipi_id ) || ';';
      vv_memoria := vv_memoria || 'Origem Mercadoria;' || pk_csf.fkg_dominio('PARAM_CALC_ICMSST.DM_ORIG_MERC', vt_param_calc_icmsst.dm_orig_merc) || ';';
      --
   end if;
   --
   return vv_memoria;
   --
exception
   when others then
      return null;
end fkg_mem_param_calc_icmsst;

-------------------------------------------------------------------------------------------------------

-- Função retorna a memoria de Parametro de Calculo de ICMS-ST para Empresa
function fkg_mem_param_calc_icmsst_empr ( en_paramcalcicmsstempr_id in param_calc_icmsst_empr.id%type )
         return varchar2
is
   --
   vv_memoria                 imp_itemsc.memoria%type;
   vt_param_calc_icmsst_empr  param_calc_icmsst_empr%rowtype;
   vv_empresa                 varchar2(255);
   --
begin
   --
   vv_memoria := null;
   --
   begin
      --
      select * into vt_param_calc_icmsst_empr
        from param_calc_icmsst_empr
       where id = en_paramcalcicmsstempr_id;
      --
   exception
      when others then
         vt_param_calc_icmsst_empr := null;
   end;
   --
   if nvl(vt_param_calc_icmsst_empr.id,0) > 0 then
      --
      begin
         --
         select p.cod_part || '-' || p.nome
           into vv_empresa
           from empresa e
              , pessoa p
          where e.id = vt_param_calc_icmsst_empr.empresa_id
            and p.id = e.pessoa_id;
         --
      exception
         when others then
            vv_empresa := null;
      end;
      --
      vv_memoria := 'Parametro de Calculo de ICMS nivel Empresa;';
      vv_memoria := vv_memoria || 'Identificador;' || vt_param_calc_icmsst_empr.id || ';';
      vv_memoria := vv_memoria || 'Empresa;' || vv_empresa || ';';
      vv_memoria := vv_memoria || 'Tipo de Parametro;' || pk_csf.fkg_dominio('PARAM_CALC_ICMSST_EMPR.DM_TIPO_PARAM', vt_param_calc_icmsst_empr.dm_tipo_param) || ';';
      vv_memoria := vv_memoria || 'Prioridade;' || vt_param_calc_icmsst_empr.prioridade || ';';
      vv_memoria := vv_memoria || 'Data Inicial:;' || to_char(vt_param_calc_icmsst_empr.dt_ini, 'dd/mm/rrrr') || ';';
      vv_memoria := vv_memoria || 'Data Final:;' || to_char(nvl(vt_param_calc_icmsst_empr.dt_fin, sysdate), 'dd/mm/rrrr') || ';';
      vv_memoria := vv_memoria || 'CFOP:;' || pk_csf.fkg_cfop_cd ( en_cfop_id => vt_param_calc_icmsst_empr.cfop_id ) || ';';
      vv_memoria := vv_memoria || 'Estado Destino:;' || pk_csf.fkg_Estado_id_sigla ( en_estado_id => vt_param_calc_icmsst_empr.estado_id_dest ) || ';';
      vv_memoria := vv_memoria || 'CEST:;' || pk_csf.fkg_cd_cest_id ( en_cest_id => vt_param_calc_icmsst_empr.cest_id ) || ';';
      vv_memoria := vv_memoria || 'NCM:;' || pk_csf.fkg_cod_ncm_id ( en_ncm_id => vt_param_calc_icmsst_empr.ncm_id ) || ';';
      vv_memoria := vv_memoria || 'Ex-Tipi:;' || pk_csf.fkg_ex_tipi_cod ( en_extipi_id => vt_param_calc_icmsst_empr.extipi_id ) || ';';
      vv_memoria := vv_memoria || 'Origem Mercadoria;' || pk_csf.fkg_dominio('PARAM_CALC_ICMSST_EMPR.DM_ORIG_MERC', vt_param_calc_icmsst_empr.dm_orig_merc) || ';';
      vv_memoria := vv_memoria || 'Item (Produto):;' || pk_csf.fkg_Item_cod ( en_item_id => vt_param_calc_icmsst_empr.item_id ) || ';';
      vv_memoria := vv_memoria || 'CPF/CNPJ Participante;' || vt_param_calc_icmsst_empr.cpf_cnpj || ';';
      vv_memoria := vv_memoria || 'Natureza de Operacao;' || pk_csf.fkg_cod_nat_id ( en_natoper_id => vt_param_calc_icmsst_empr.natoper_id ) || ';';
      --
   end if;
   --
   return vv_memoria;
   --
exception
   when others then
      return null;
end fkg_mem_param_calc_icmsst_empr;

-------------------------------------------------------------------------------------------------------

-- Função retorna a memoria de Parametros de Calculo Aliquota do Imposto por NCM: Tratar IPI, PIS e COFINS
function fkg_mem_aliq_tipoimp_ncm ( en_aliqtipoimpncm_id in aliq_tipoimp_ncm.id%type )
         return varchar2
is
   --
   vv_memoria              imp_itemsc.memoria%type;
   vt_aliq_tipoimp_ncm     aliq_tipoimp_ncm%rowtype;
   vv_reg_trib             varchar2(100);
   vv_forma_trib           varchar2(100);
   vv_imposto              varchar2(100);
   vv_inc_trib             varchar2(100);
   --
begin
   --
   vv_memoria := null;
   --
   begin
      --
      select * into vt_aliq_tipoimp_ncm
        from aliq_tipoimp_ncm
       where id = en_aliqtipoimpncm_id;
      --
   exception
      when others then
         vt_aliq_tipoimp_ncm := null;
   end;
   --
   if nvl(vt_aliq_tipoimp_ncm.id,0) > 0 then
      --
      vv_memoria := 'Parametro de Calculo de Aliquota do Imposto por NCM: Tratar IPI, PIS e COFINS nivel Global;';
      vv_memoria := vv_memoria || 'Identificador;' || vt_aliq_tipoimp_ncm.id || ';';
      vv_memoria := vv_memoria || 'Tipo de Parametro;' || pk_csf.fkg_dominio('ALIQ_TIPOIMP_NCM.DM_TIPO_PARAM', vt_aliq_tipoimp_ncm.dm_tipo_param) || ';';
      vv_memoria := vv_memoria || 'Prioridade;' || vt_aliq_tipoimp_ncm.prioridade || ';';
      --
      begin
         --
         select cd || '-' || descr
           into vv_imposto
           from tipo_imposto
          where id = vt_aliq_tipoimp_ncm.tipoimposto_id;
         --
      exception
         when others then
            vv_imposto := null;
      end;
      --
      vv_memoria := vv_memoria || 'Tipo de Imposto;' || vv_imposto || ';';
      vv_memoria := vv_memoria || 'Data Inicial:;' || to_char(vt_aliq_tipoimp_ncm.dt_ini, 'dd/mm/rrrr') || ';';
      vv_memoria := vv_memoria || 'Data Final:;' || to_char(nvl(vt_aliq_tipoimp_ncm.dt_fin, sysdate), 'dd/mm/rrrr') || ';';
      --
      begin
         --
         select cd || '-' || descr
           into vv_reg_trib
           from reg_trib
          where id = vt_aliq_tipoimp_ncm.regtrib_id;
         --
      exception
         when others then
            vv_reg_trib := null;
      end;
      --
      begin
         --
         select cd || '-' || descr
           into vv_forma_trib
           from forma_trib
          where id = vt_aliq_tipoimp_ncm.formatrib_id;
         --
      exception
         when others then
            vv_forma_trib := null;
      end;
      --
      begin
         --
         select cd || '-' || descr
           into vv_inc_trib
           from inc_trib
          where id = vt_aliq_tipoimp_ncm.inctrib_id;
         --
      exception
         when others then
            vv_inc_trib := null;
      end;
      --
      vv_memoria := vv_memoria || 'Incidencia Tributaria:;' || vv_inc_trib || ';';
      vv_memoria := vv_memoria || 'Regime Tributario:;' || vv_reg_trib || ';';
      vv_memoria := vv_memoria || 'Forma de Tributacao:;' || vv_forma_trib || ';';
      vv_memoria := vv_memoria || 'CNAE:;' || pk_csf.fkg_cd_cnae_id ( en_cnae_id => vt_aliq_tipoimp_ncm.cnae_id ) || ';';
      --
      vv_memoria := vv_memoria || 'CFOP:;' || pk_csf.fkg_cfop_cd ( en_cfop_id => vt_aliq_tipoimp_ncm.cfop_id ) || ';';
      vv_memoria := vv_memoria || 'NCM:;' || pk_csf.fkg_cod_ncm_id ( en_ncm_id => vt_aliq_tipoimp_ncm.ncm_id ) || ';';
      vv_memoria := vv_memoria || 'Ex-Tipi:;' || pk_csf.fkg_ex_tipi_cod ( en_extipi_id => vt_aliq_tipoimp_ncm.extipi_id ) || ';';
      vv_memoria := vv_memoria || 'Origem Mercadoria;' || pk_csf.fkg_dominio('ALIQ_TIPOIMP_NCM.DM_ORIG_MERC', vt_aliq_tipoimp_ncm.dm_orig_merc) || ';';
      vv_memoria := vv_memoria || 'Calcula Consumidor Final;' || pk_csf.fkg_dominio('ALIQ_TIPOIMP_NCM.DM_CALC_CONS_FINAL', vt_aliq_tipoimp_ncm.dm_calc_cons_final) || ';';
      --
   end if;
   --
   return vv_memoria;
   --
exception
   when others then
      return null;
end fkg_mem_aliq_tipoimp_ncm;

-------------------------------------------------------------------------------------------------------

-- Função retorna a memoria de Parametro de Calculo Aliquota do Imposto por NCM, detalhe por ITEM da Empresa: Tratar IPI, PIS e COFINS
function fkg_mem_aliq_tipoimp_ncm_empr ( en_aliqtipoimpncmempresa_id in aliq_tipoimp_ncm_empresa.id%type )
         return varchar2
is
   --
   vv_memoria                   imp_itemsc.memoria%type;
   vt_aliq_tipoimp_ncm_empresa  aliq_tipoimp_ncm_empresa%rowtype;
   vv_empresa                   varchar2(255);
   vv_imposto                   varchar2(100);
   --
begin
   --
   vv_memoria := null;
   --
   begin
      --
      select * into vt_aliq_tipoimp_ncm_empresa
        from aliq_tipoimp_ncm_empresa
       where id = en_aliqtipoimpncmempresa_id;
      --
   exception
      when others then
         vt_aliq_tipoimp_ncm_empresa := null;
   end;
   --
   if nvl(vt_aliq_tipoimp_ncm_empresa.id,0) > 0 then
      --
      begin
         --
         select p.cod_part || '-' || p.nome
           into vv_empresa
           from empresa e
              , pessoa p
          where e.id = vt_aliq_tipoimp_ncm_empresa.empresa_id
            and p.id = e.pessoa_id;
         --
      exception
         when others then
            vv_empresa := null;
      end;
      --
      vv_memoria := 'Parametro de Calculo de Aliquota do Imposto por NCM, detalhe por ITEM da Empresa: Tratar IPI, PIS e COFINS;';
      vv_memoria := vv_memoria || 'Identificador;' || vt_aliq_tipoimp_ncm_empresa.id || ';';
      vv_memoria := vv_memoria || 'Empresa;' || vv_empresa || ';';
      vv_memoria := vv_memoria || 'Tipo de Parametro;' || pk_csf.fkg_dominio('ALIQ_TIPOIMP_NCM_EMPRESA.DM_TIPO_PARAM', vt_aliq_tipoimp_ncm_empresa.dm_tipo_param) || ';';
      vv_memoria := vv_memoria || 'Prioridade;' || vt_aliq_tipoimp_ncm_empresa.prioridade || ';';
      --
      begin
         --
         select cd || '-' || descr
           into vv_imposto
           from tipo_imposto
          where id = vt_aliq_tipoimp_ncm_empresa.tipoimposto_id;
         --
      exception
         when others then
            vv_imposto := null;
      end;
      --
      vv_memoria := vv_memoria || 'Tipo de Imposto;' || vv_imposto || ';';
      vv_memoria := vv_memoria || 'Data Inicial:;' || to_char(vt_aliq_tipoimp_ncm_empresa.dt_ini, 'dd/mm/rrrr') || ';';
      vv_memoria := vv_memoria || 'Data Final:;' || to_char(nvl(vt_aliq_tipoimp_ncm_empresa.dt_fin, sysdate), 'dd/mm/rrrr') || ';';
      vv_memoria := vv_memoria || 'CFOP:;' || pk_csf.fkg_cfop_cd ( en_cfop_id => vt_aliq_tipoimp_ncm_empresa.cfop_id ) || ';';
      vv_memoria := vv_memoria || 'NCM:;' || pk_csf.fkg_cod_ncm_id ( en_ncm_id => vt_aliq_tipoimp_ncm_empresa.ncm_id ) || ';';
      vv_memoria := vv_memoria || 'Ex-Tipi:;' || pk_csf.fkg_ex_tipi_cod ( en_extipi_id => vt_aliq_tipoimp_ncm_empresa.extipi_id ) || ';';
      vv_memoria := vv_memoria || 'Origem Mercadoria;' || pk_csf.fkg_dominio('ALIQ_TIPOIMP_NCM_EMPRESA.DM_ORIG_MERC', vt_aliq_tipoimp_ncm_empresa.dm_orig_merc) || ';';
      vv_memoria := vv_memoria || 'Item (Produto):;' || pk_csf.fkg_Item_cod ( en_item_id => vt_aliq_tipoimp_ncm_empresa.item_id ) || ';';
      vv_memoria := vv_memoria || 'CPF/CNPJ Participante;' || vt_aliq_tipoimp_ncm_empresa.cpf_cnpj || ';';
      vv_memoria := vv_memoria || 'Natureza de Operacao;' || pk_csf.fkg_cod_nat_id ( en_natoper_id => vt_aliq_tipoimp_ncm_empresa.natoper_id ) || ';';
      vv_memoria := vv_memoria || 'Calcula Consumidor Final;' || pk_csf.fkg_dominio('ALIQ_TIPOIMP_NCM_EMPRESA.DM_CALC_CONS_FINAL', vt_aliq_tipoimp_ncm_empresa.dm_calc_cons_final) || ';';
      --
   end if;
   --
   return vv_memoria;
   --
exception
   when others then
      return null;
end fkg_mem_aliq_tipoimp_ncm_empr;

-------------------------------------------------------------------------------------------------------

-- Função retorno 0-Não ou 1-Sim, para utilização da Calculadora Fiscal para Emissão Propria
function fkg_empr_util_epropria ( en_empresa_id  in empresa.id%type )
         return param_empr_calc_fiscal.dm_util_epropria%type
is
   --
   vn_dm_util_epropria  param_empr_calc_fiscal.dm_util_epropria%type;
   --
begin
   --
   select dm_util_epropria
     into vn_dm_util_epropria
     from param_empr_calc_fiscal
    where empresa_id = en_empresa_id;
   --
   return vn_dm_util_epropria;
   --
exception
   when others then
      return 0;
end fkg_empr_util_epropria;

-------------------------------------------------------------------------------------------------------

-- Função retorno 0-Não ou 1-Sim, para utilização da Calculadora Fiscal para Emissão Terceiro
function fkg_empr_util_eterceiro ( en_empresa_id  in empresa.id%type )
         return param_empr_calc_fiscal.dm_util_eterceiro%type
is
   --
   vn_dm_util_eterceiro  param_empr_calc_fiscal.dm_util_eterceiro%type;
   --
begin
   --
   select dm_util_eterceiro
     into vn_dm_util_eterceiro
     from param_empr_calc_fiscal
    where empresa_id = en_empresa_id;
   --
   return vn_dm_util_eterceiro;
   --
exception
   when others then
      return 0;
end fkg_empr_util_eterceiro;

-------------------------------------------------------------------------------------------------------

-- Função retorna a memoria de Parametros de Calculo de ISS
function fkg_mem_param_calc_iss ( en_paramcalciss_id in param_calc_iss.id%type )
         return varchar2
is
   --
   vv_memoria              imp_itemsc.memoria%type;
   vt_param_calc_iss       param_calc_iss%rowtype;
   vv_reg_trib             varchar2(100);
   vv_forma_trib           varchar2(100);
   --
begin
   --
   vv_memoria := null;
   --
   begin
      --
      select * into vt_param_calc_iss
        from param_calc_iss
       where id = en_paramcalciss_id;
      --
   exception
      when others then
         vt_param_calc_iss := null;
   end;
   --
   if nvl(vt_param_calc_iss.id,0) > 0 then
      --
      vv_memoria := 'Parametro de Calculo de ISS nivel Global;';
      vv_memoria := vv_memoria || 'Identificador;' || vt_param_calc_iss.id || ';';
      vv_memoria := vv_memoria || 'Tipo de Parametro;' || pk_csf.fkg_dominio('PARAM_CALC_ISS.DM_TIPO_PARAM', vt_param_calc_iss.dm_tipo_param) || ';';
      vv_memoria := vv_memoria || 'Prioridade;' || vt_param_calc_iss.prioridade || ';';
      vv_memoria := vv_memoria || 'Data Inicial:;' || to_char(vt_param_calc_iss.dt_ini, 'dd/mm/rrrr') || ';';
      vv_memoria := vv_memoria || 'Data Final:;' || to_char(nvl(vt_param_calc_iss.dt_fin, sysdate), 'dd/mm/rrrr') || ';';
      vv_memoria := vv_memoria || 'Cidade:;' || pk_csf.fkg_cidade_descr ( en_cidade_id => vt_param_calc_iss.cidade_id ) || ';';
      --
      begin
         --
         select cd || '-' || descr
           into vv_reg_trib
           from reg_trib
          where id = vt_param_calc_iss.regtrib_id;
         --
      exception
         when others then
            vv_reg_trib := null;
      end;
      --
      begin
         --
         select cd || '-' || descr
           into vv_forma_trib
           from forma_trib
          where id = vt_param_calc_iss.formatrib_id;
         --
      exception
         when others then
            vv_forma_trib := null;
      end;
      --
      vv_memoria := vv_memoria || 'Regime Tributario:;' || vv_reg_trib || ';';
      vv_memoria := vv_memoria || 'Forma de Tributacao:;' || vv_forma_trib || ';';
      vv_memoria := vv_memoria || 'CNAE:;' || pk_csf.fkg_cd_cnae_id ( en_cnae_id => vt_param_calc_iss.cnae_id ) || ';';
      --
      vv_memoria := vv_memoria || 'CFOP:;' || pk_csf.fkg_cfop_cd ( en_cfop_id => vt_param_calc_iss.cfop_id ) || ';';
      vv_memoria := vv_memoria || 'Tipo Serviço:;' || pk_csf.fkg_Tipo_Servico_cod ( en_tpservico_id => vt_param_calc_iss.tiposervico_id ) || ';';
      --
   end if;
   --
   return vv_memoria;
   --
exception
   when others then
      return null;
end fkg_mem_param_calc_iss;

-------------------------------------------------------------------------------------------------------

-- Função retorna a memoria de Parametros de Calculo de ISS conforme Natureza de Operação
function fkg_mem_param_calc_iss_nop ( en_paramimpnatoperserv_id in param_imp_nat_oper_serv.id%type )
         return varchar2
is
   --
   vv_memoria              imp_itemsc.memoria%type;
   --
   vv_cod_nat              nat_oper.cod_nat%type;
   vn_item_id              item.id%type;
   vt_row_param_imp_nat_oper_serv param_imp_nat_oper_serv%rowtype;
   --
begin
   --
   vv_memoria := null;
   --
   begin
      --
      select nop.cod_nat
           , s.item_id
        into vv_cod_nat
           , vn_item_id
        from param_imp_nat_oper_serv p
           , nat_oper_serv           s
           , nat_oper                nop
       where 1 = 1
         and p.id    = en_paramimpnatoperserv_id
         and s.id    = p.natoperserv_id
         and nop.id  = s.natoper_id;
      --
   exception
      when others then
         vv_cod_nat := null;
         vn_item_id := null;
   end;
   --
   begin
      --
      select p.*
        into vt_row_param_imp_nat_oper_serv
        from param_imp_nat_oper_serv p
       where p.id = en_paramimpnatoperserv_id;
      --
   exception
      when others then
         vt_row_param_imp_nat_oper_serv := null;
   end;
   --
   if nvl(vt_row_param_imp_nat_oper_serv.id,0) > 0 then
      --
      vv_memoria := 'Parametro de Calculo de ISS/Retido nivel Empresa;';
      vv_memoria := vv_memoria || 'Cód. Natureza Operação;' || vv_cod_nat || ';';
      vv_memoria := vv_memoria || 'Item;' || pk_csf.fkg_Item_cod ( en_item_id => vn_item_id ) || ';';
      --
   end if;
   --
   return vv_memoria;
   --
exception
   when others then
      return null;
end fkg_mem_param_calc_iss_nop;

-------------------------------------------------------------------------------------------------------

-- Função retorna a memoria de Parametros de Calculo de Retido
function fkg_mem_param_calc_retido ( en_paramcalcretido_id in param_calc_retido.id%type )
         return varchar2
is
   --
   vv_memoria              imp_itemsc.memoria%type;
   vt_param_calc_retido    param_calc_retido%rowtype;
   vv_reg_trib             varchar2(100);
   vv_forma_trib           varchar2(100);
   --
begin
   --
   vv_memoria := null;
   --
   begin
      --
      select * into vt_param_calc_retido
        from param_calc_retido
       where id = en_paramcalcretido_id;
      --
   exception
      when others then
         vt_param_calc_retido := null;
   end;
   --
   if nvl(vt_param_calc_retido.id,0) > 0 then
      --
      vv_memoria := 'Parametro de Calculo de Retido nivel Global;';
      vv_memoria := vv_memoria || 'Identificador;' || vt_param_calc_retido.id || ';';
      vv_memoria := vv_memoria || 'Tipo de Parametro;' || pk_csf.fkg_dominio('PARAM_CALC_ISS.DM_TIPO_PARAM', vt_param_calc_retido.dm_tipo_param) || ';';
      vv_memoria := vv_memoria || 'Prioridade;' || vt_param_calc_retido.prioridade || ';';
      vv_memoria := vv_memoria || 'Tipo de Imposto;' || pk_csf.fkg_Tipo_Imp_Sigla ( en_id => vt_param_calc_retido.tipoimposto_id ) || ';';
      vv_memoria := vv_memoria || 'Data Inicial:;' || to_char(vt_param_calc_retido.dt_ini, 'dd/mm/rrrr') || ';';
      vv_memoria := vv_memoria || 'Data Final:;' || to_char(nvl(vt_param_calc_retido.dt_fin, sysdate), 'dd/mm/rrrr') || ';';
      vv_memoria := vv_memoria || 'CFOP:;' || pk_csf.fkg_cfop_cd ( en_cfop_id => vt_param_calc_retido.cfop_id ) || ';';
      --
      begin
         --
         select cd || '-' || descr
           into vv_reg_trib
           from reg_trib
          where id = vt_param_calc_retido.regtrib_id;
         --
      exception
         when others then
            vv_reg_trib := null;
      end;
      --
      begin
         --
         select cd || '-' || descr
           into vv_forma_trib
           from forma_trib
          where id = vt_param_calc_retido.formatrib_id;
         --
      exception
         when others then
            vv_forma_trib := null;
      end;
      --
      vv_memoria := vv_memoria || 'Regime Tributario:;' || vv_reg_trib || ';';
      vv_memoria := vv_memoria || 'Forma de Tributacao:;' || vv_forma_trib || ';';
      vv_memoria := vv_memoria || 'CNAE:;' || pk_csf.fkg_cd_cnae_id ( en_cnae_id => vt_param_calc_retido.cnae_id ) || ';';
      --

      vv_memoria := vv_memoria || 'Tipo Serviço:;' || pk_csf.fkg_Tipo_Servico_cod ( en_tpservico_id => vt_param_calc_retido.tiposervico_id ) || ';';
      --
   end if;
   --
   return vv_memoria;
   --
exception
   when others then
      return null;
end fkg_mem_param_calc_retido;
--
-- ======================================================================================================= --
-- Função retorna A-Arredondamento ou T-Trunc, para utilização da Calculadora Fiscal, conforme tabela de parametrização e multorg
function fkg_dmindregra ( en_empresa_id        in empresa.id%type
                        , ev_objeto_referencia in param_calc_regra_arred.objeto_referencia%type 
                        , en_id_referencia     in param_calc_regra_arred.id_referencia%type )
         return param_calc_regra_arred.dm_ind_regra%type is
   --
   vv_dm_ind_regra  param_calc_regra_arred.dm_ind_regra%type;
   --
begin
   --
   select nvl(pc.dm_ind_regra,'A')  dm_ind_regra
     into vv_dm_ind_regra
     from param_calc_regra_arred pc
    where pc.multorg_id        = pk_csf.fkg_multorg_id_empresa(en_empresa_id)
      and pc.objeto_referencia = ev_objeto_referencia
      and pc.id_referencia     = en_id_referencia;
   --
   return vv_dm_ind_regra;
   --
exception
   when others then
      return 'A';
end fkg_dmindregra;
--
-- ======================================================================================================= --
--
end pk_csf_calc_fiscal;
/
