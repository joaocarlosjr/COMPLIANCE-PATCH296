create or replace package body csf_own.pk_csf_ciap is

-------------------------------------------------------------------------------------------------------
-- Corpo do pacote de funções de CIAP
-------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------
-- Função retorna o ID do Bem do Ativo Imobilizado
-------------------------------------------------------------------------------------------------------
function fkg_bemativoimob_id ( en_empresa_id   in  empresa.id%type
                             , ev_cod_ind_bem  in  bem_ativo_imob.cod_ind_bem%type
                             )
         return bem_ativo_imob.id%type
is
   --
   vn_bemativoimob_id  bem_ativo_imob.id%type := 0;
   --
begin
   --
   select max(bai.id)
     into vn_bemativoimob_id
     from bem_ativo_imob   bai
    where bai.empresa_id   = en_empresa_id
      and bai.cod_ind_bem  = trim(ev_cod_ind_bem);
   --
   return vn_bemativoimob_id;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_bemativoimob_id:' || sqlerrm);
end fkg_bemativoimob_id;

-------------------------------------------------------------------------------------------------------
-- Função retorna o ID do Movimento do Bem do Ativo Imobilizado
-------------------------------------------------------------------------------------------------------
function fkg_icmsatpermciap_id ( en_empresa_id   in  empresa.id%type
                               , ed_dt_ini  in  icms_atperm_ciap.dt_ini%type
                               , ed_dt_fin  in  icms_atperm_ciap.dt_fin%type
                             )
         return icms_atperm_ciap.id%type
is
   --
   vn_icmsatpermciap_id  icms_atperm_ciap.id%type := null;
   --
begin
   --
   if nvl(en_empresa_id, 0) > 0
      and ed_dt_ini is not null
      and ed_dt_fin is not null then
      --
      select a.id
        into vn_icmsatpermciap_id
        from icms_atperm_ciap a
       where a.empresa_id = en_empresa_id
         and a.dt_ini     = ed_dt_ini
         and a.dt_fin     = ed_dt_fin;
   --
   end if;
   --
   return vn_icmsatpermciap_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_icmsatpermciap_id:' || sqlerrm);
end fkg_icmsatpermciap_id;

-------------------------------------------------------------------------------------------------------
-- Função retorna o True se existe Movimento do Bem do Ativo Imobilizado e false se não.
-------------------------------------------------------------------------------------------------------
function fkg_existe_ciap ( en_icmsatpermciap_id   in  icms_atperm_ciap.id%type )
        return boolean
is
   --
   vn_existe  number := 0;
   --
begin
   --
   if nvl(en_icmsatpermciap_id, 0) > 0 then
      --
      select 1
        into vn_existe
        from icms_atperm_ciap a
       where a.id  = en_icmsatpermciap_id;
   --
   end if;
   --
   return true;
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_ciap:' || sqlerrm);
end fkg_existe_ciap;

-------------------------------------------------------------------------------------------------------
-- Função retorna o dm_st_proc do Movimento do CIAP.
-------------------------------------------------------------------------------------------------------
function fkg_dm_st_proc_ciap ( en_icmsatpermciap_id   in  icms_atperm_ciap.id%type )
        return icms_atperm_ciap.dm_st_proc%type
is
   --
   vn_dm_st_proc  number := 0;
   --
begin
   --
   if nvl(en_icmsatpermciap_id, 0) > 0 then
      --
      select dm_st_proc
        into vn_dm_st_proc
        from icms_atperm_ciap a
       where a.id  = en_icmsatpermciap_id;
   --
   end if;
   --
   return vn_dm_st_proc;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_dm_st_proc_ciap:' || sqlerrm);
end fkg_dm_st_proc_ciap;

-------------------------------------------------------------------------------------------------------
-- Função retorna o calculo ind_per_sai do Movimento do CIAP.
-------------------------------------------------------------------------------------------------------
function fkg_ind_per_sai_calc ( en_icmsatpermciap_id   in  icms_atperm_ciap.id%type )
        return icms_atperm_ciap.ind_per_sai%type
is
   --
   vn_ind_per_sai  number := 0;
   --
begin
   --
   if nvl(en_icmsatpermciap_id,0) > 0 then
      --
--      select round((ciap.vl_trib_exp/decode(ciap.vl_total, 0, 1, ciap.vl_total)), 8)
      select decode(nvl(ciap.vl_total,0), 0, 1, round((ciap.vl_trib_exp / ciap.vl_total), 8))
        into vn_ind_per_sai
        from icms_atperm_ciap ciap
       where ciap.id  = en_icmsatpermciap_id;
   --
   end if;
   --
   return vn_ind_per_sai;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_ind_per_sai_calc:' || sqlerrm);
end fkg_ind_per_sai_calc;

-------------------------------------------------------------------------------------------------------
-- Função retorna o codigo do Bem do Ativo Imobilizado
-------------------------------------------------------------------------------------------------------
function fkg_bemativoimob_cd ( en_bemativoimob_id  bem_ativo_imob.id%type)
         return bem_ativo_imob.cod_ind_bem%type
is
   --
   vv_cod_ind_bem  bem_ativo_imob.cod_ind_bem%type := 0;
   --
begin
   --
   if nvl(en_bemativoimob_id, 0) > 0 then
      --
      select b.cod_ind_bem
        into vv_cod_ind_bem
        from bem_ativo_imob b
       where b.id = en_bemativoimob_id;
      --
   end if;
   --
   return vv_cod_ind_bem;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_bemativoimob_cd:' || sqlerrm);
end fkg_bemativoimob_cd;

-------------------------------------------------------------------------------------------------------
-- Função retorno se um Imobilizado é bem ou Componente Através do ID
-------------------------------------------------------------------------------------------------------
function fkg_bemativoimob_ind ( en_bemativoimob_id  bem_ativo_imob.id%type)
         return bem_ativo_imob.dm_ident_merc%type
is
   --
   vn_dm_ident_merc  bem_ativo_imob.dm_ident_merc%type := 0;
   --
begin
   --
   if nvl(en_bemativoimob_id, 0) > 0 then
      --
      select b.dm_ident_merc
        into vn_dm_ident_merc
        from bem_ativo_imob b
       where b.id = en_bemativoimob_id;
      --
   end if;
   --
   return vn_dm_ident_merc;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_bemativoimob_ind:' || sqlerrm);
end fkg_bemativoimob_ind;

-------------------------------------------------------------------------------------------------------
-- Função retorno da quantidade de parcelas que um Imobilizado pode tomar crédito
-------------------------------------------------------------------------------------------------------
function fkg_bemativoimob_par ( en_bemativoimob_id  bem_ativo_imob.id%type)
         return bem_ativo_imob.nr_parc%type
is
   --
   vn_nr_parc  bem_ativo_imob.nr_parc%type := 0;
   --
begin
   --
   if nvl(en_bemativoimob_id, 0) > 0 then
      --
      select b.nr_parc
        into vn_nr_parc
        from bem_ativo_imob b
       where b.id = en_bemativoimob_id;
      --
   end if;
   --
   return vn_nr_parc;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_bemativoimob_par:' || sqlerrm);
end fkg_bemativoimob_par;

-------------------------------------------------------------------------------------------------------
-- Função retorno da quantidade de registros de movimento por periodo de apuração
-------------------------------------------------------------------------------------------------------
function fkg_movatperm_qtde ( en_icmsatpermciap_id icms_atperm_ciap.id%type
                            , en_bemativoimob_id  bem_ativo_imob.id%type)
         return number
is
   --
   vn_qtde number := 0;
   --
begin
   --
   if nvl(en_bemativoimob_id, 0) > 0
      and nvl(en_icmsatpermciap_id, 0) > 0 then
      --
      select count(m.id)
        into vn_qtde
        from mov_atperm m
       where m.icmsatpermciap_id = en_icmsatpermciap_id
         and m.bemativoimob_id   = en_bemativoimob_id;
      --
   end if;
   --
   return vn_qtde;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_movatperm_qtde:' || sqlerrm);
end fkg_movatperm_qtde;

-------------------------------------------------------------------------------------------------------
-- Função retorno 1 se existe registro de baixa no período de apuração e zero caso não haja.
-------------------------------------------------------------------------------------------------------
function fkg_existe_mov_ciap ( en_icmsatpermciap_id in icms_atperm_ciap.id%type
                             , en_bemativoimob_id   in bem_ativo_imob.id%type
                             , ev_dm_tipo_mov       in mov_atperm.dm_tipo_mov%type)
         return number
is
   --
   vn_qtde number := 0;
   --
begin
   --
   if nvl(en_bemativoimob_id, 0) > 0
      and nvl(en_icmsatpermciap_id, 0) > 0
      and trim(ev_dm_tipo_mov) is not null then
      --
      select 1
        into vn_qtde
        from mov_atperm m
       where m.icmsatpermciap_id = en_icmsatpermciap_id
         and m.bemativoimob_id   = en_bemativoimob_id
         and m.dm_tipo_mov       = trim(ev_dm_tipo_mov);
      --
   end if;
   --
   return vn_qtde;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_mov_ciap:' || sqlerrm);
end fkg_existe_mov_ciap;

-------------------------------------------------------------------------------------------------------
-- Função retorna o calculo ind_per_sai dos Outros Créditos do Ciap.
-------------------------------------------------------------------------------------------------------
function fkg_ind_per_out_cred ( en_outrocredciap_id   in  outro_cred_ciap.id%type )
        return outro_cred_ciap.ind_per_sai%type
is
   --
   vn_ind_per_sai  number := 0;
   --
begin
   --
   if nvl(en_outrocredciap_id, 0) > 0 then
      --
 select round((ciap.vl_trib_oc/decode(ciap.vl_total, 0, 1, ciap.vl_total)), 8)
        into vn_ind_per_sai
        from outro_cred_ciap ciap
       where ciap.id  = en_outrocredciap_id;
   --
   end if;
   --
   return vn_ind_per_sai;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_ind_per_out_cred:' || sqlerrm);
end fkg_ind_per_out_cred;

-------------------------------------------------------------------------------------------------------
-- Função retorna o True se existe Documento Fiscais para o Bem ou Componente Imobilizado
-------------------------------------------------------------------------------------------------------
function fkg_existe_doc_fiscal_ciap ( en_movatperm_id in  mov_atperm.id%type )
        return boolean
is
   --
   vn_existe  number := 0;
   --
begin
   --
   if nvl(en_movatperm_id, 0) > 0 then
      --
      select count(a.id)
        into vn_existe
        from mov_atperm_doc_fiscal a
       where a.movatperm_id  = en_movatperm_id;
   --
   end if;
   --
   return true;
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Chave do Movimento: ' || en_movatperm_id || ' Erro na fkg_existe_doc_fiscal_ciap:' || sqlerrm);
end fkg_existe_doc_fiscal_ciap;

-------------------------------------------------------------------------------------------------------
-- Função retorno da quantidade de registros de movimento por periodo de apuração
-------------------------------------------------------------------------------------------------------
function fkg_movatpermdocfiscal_qtde ( en_icmsatpermciap_id in icms_atperm_ciap.id%type
                                     , en_bemativoimob_id   in bem_ativo_imob.id%type )
         return number
is
   --
   vn_qtde number := 0;
   --
begin
   --
   if nvl(en_icmsatpermciap_id, 0) > 0
      and nvl(en_bemativoimob_id, 0) > 0 then
      --
      select distinct count(a.movatperm_id) qtde
        Into vn_qtde
        from mov_atperm_doc_fiscal a,
             mov_atperm c
       where c.icmsatpermciap_id = en_icmsatpermciap_id
         and c.bemativoimob_id   = en_bemativoimob_id
         and a.movatperm_id      = c.id
         and exists (select b.*
                from mov_atperm_doc_fiscal b
                where b.dm_ind_emit = a.dm_ind_emit
                  and b.pessoa_id   = a.pessoa_id
                  and b.modfiscal_id = a.modfiscal_id
                  and ((b.serie = a.serie) or (b.serie is null and a.serie is null))
                  and b.num_doc = a.num_doc
                  and ((b.chv_nfe_cte = a.chv_nfe_cte) or (b.chv_nfe_cte is null and a.chv_nfe_cte is null))
                  and b.dt_doc = a.dt_doc);
      --
   end if;
   --
   return vn_qtde;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_movatpermdocfiscal_qtde:' || sqlerrm);
end fkg_movatpermdocfiscal_qtde;

-------------------------------------------------------------------------------------------------------
-- Função retorna o True se existe Item do Documento Fiscais para o Bem ou Componente Imobilizado
-------------------------------------------------------------------------------------------------------
function fkg_existe_itemdocfiscal_ciap ( en_movatpermdocfiscal_id in  mov_atperm_doc_fiscal_item.id%type )
        return boolean
is
   --
   vn_existe  number := 0;
   --
begin
   --
   if nvl(en_movatpermdocfiscal_id, 0) > 0 then
      --
      select 1
        into vn_existe
        from mov_atperm_doc_fiscal_item p
       where p.movatpermdocfiscal_id = en_movatpermdocfiscal_id
         and rownum                  = 1;
      --
   end if;
   --
   return true;
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_itemdocfiscal_ciap:' || sqlerrm);
end fkg_existe_itemdocfiscal_ciap;

-------------------------------------------------------------------------------------------------------
-- Função retorna id da utilização do bem através do id do ativo imobilizado
-------------------------------------------------------------------------------------------------------
function fkg_inforutilbem_id ( en_bemativoimob_id  bem_ativo_imob.id%type)
         return infor_util_bem.id%type
is
   --
   vn_inforutilbem_id  infor_util_bem.id%type := 0;
   --
begin
   --
   if nvl(en_bemativoimob_id, 0) > 0 then
      --
      select b.id
        into vn_inforutilbem_id
        from infor_util_bem b
       where b.bemativoimob_id = en_bemativoimob_id;
      --
   end if;
   --
   return vn_inforutilbem_id;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_inforutilbem_id:' || sqlerrm);
end fkg_inforutilbem_id;

-------------------------------------------------------------------------------------------------------
-- Função retorna o True se existe Informação da Utilização do Bem através do id
-------------------------------------------------------------------------------------------------------
function fkg_existe_inforutilbem_id ( en_bemativoimob_id  bem_ativo_imob.id%type)
        return boolean
is
   --
   vn_existe  number := 0;
   --
begin
   --
   if nvl(en_bemativoimob_id, 0) > 0 then
      --
      select count(b.id)
        into vn_existe
        from infor_util_bem b
       where b.bemativoimob_id = en_bemativoimob_id;
   --
   end if;
   --
   return true;
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_inforutilbem_id:' || sqlerrm);
end fkg_existe_inforutilbem_id;

---------------------------------------------------------------------------------------------------------------------------------
-- Função retorna True se a empresa obriga validação do documento fiscal relacionado ao CIAP através do identificador da empresa
---------------------------------------------------------------------------------------------------------------------------------
function fkg_valdocfiscciap_empresa ( en_empresa_id in empresa.id%type )
        return boolean
is
   --
   vn_valida  number := 1; -- 0-não, 1-sim
   --
begin
   --
   if nvl(en_empresa_id,0) > 0 then
      --
      begin
         select pe.dm_val_docfisc_ciap
           into vn_valida
           from param_efd_icms_ipi pe
          where pe.empresa_id = en_empresa_id;
      exception
         when no_data_found then
            vn_valida := 1; -- sim
         when others then
            raise_application_error(-20101, 'Problemas em pk_csf_ciap.fkg_valdocfiscciap_empresa(1). Erro = '||sqlerrm);
      end;
      --
   else
      --
      vn_valida := 1; -- sim
      --
   end if;
   --
   if vn_valida = 0 then
      return false;
   else
      return true;
   end if;
   --
exception
   when others then
      raise_application_error(-20101, 'Problemas em pk_csf_ciap.fkg_valdocfiscciap_empresa(2). Erro = '||sqlerrm);
end fkg_valdocfiscciap_empresa;

-------------------------------------------------------------------------------------------------------
-- Função retorna o id do registro de baixa no período de apuração 
-------------------------------------------------------------------------------------------------------
function fkg_movatper_id ( en_icmsatpermciap_id   in icms_atperm_ciap.id%type
                         , en_bemativoimob_id     in bem_ativo_imob.id%type
                         , ev_dm_tipo_mov         in mov_atperm.dm_tipo_mov%type)
         return number
is
   --
   vn_movatoerm_id     mov_atperm.id%type;
   --
begin
   --
   if nvl(en_bemativoimob_id, 0) > 0
      and nvl(en_icmsatpermciap_id, 0) > 0
      and trim(ev_dm_tipo_mov) is not null then
      --
      select m.id
        into vn_movatoerm_id
        from mov_atperm m
       where m.icmsatpermciap_id = en_icmsatpermciap_id
         and m.bemativoimob_id   = en_bemativoimob_id
         and m.dm_tipo_mov       = trim(ev_dm_tipo_mov);
      --
   end if;
   --
   return vn_movatoerm_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_movatper_id:' || sqlerrm);
end fkg_movatper_id;

-------------------------------------------------------------------------------------------------------
-- Função retorna o id dos outros creditos do CIAP
-------------------------------------------------------------------------------------------------------
function fkg_outrocredciap_id ( en_movatperm_id   in mov_atperm.id%type
                              , ed_dt_ini         in outro_cred_ciap.dt_ini%type
                              , ed_dt_fim         in outro_cred_ciap.dt_fim%type
                              , en_num_parc       in outro_cred_ciap.num_parc%type )
         return number
is
   --
   vn_outrocredciap_id   outro_cred_ciap.id%type;
   --
begin
   --  
   if nvl(en_movatperm_id, 0) > 0 and
      ed_dt_ini is not null and 
      ed_dt_fim is not null and      
      nvl(en_num_parc,0) > 0 then
      --
      select o.id
        into vn_outrocredciap_id
        from outro_cred_ciap o          
       where o.movatperm_id  = en_movatperm_id
         and o.dt_ini        = ed_dt_ini 
         and o.dt_fim        = ed_dt_fim
         and o.num_parc      = en_num_parc;
      --
   end if;   
   --
   return vn_outrocredciap_id;
   --    
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_outrocredciap_id:' || sqlerrm);
end fkg_outrocredciap_id;

-------------------------------------------------------------------------------------------------------
-- Função retorna o id do documento fiscal do registro de baixa no período de apuração 
-------------------------------------------------------------------------------------------------------
function fkg_movatperdocfiscal_id ( en_movatperm_id   in mov_atperm.id%type
                                  , en_dm_ind_emit    in mov_atperm_doc_fiscal.dm_ind_emit%type
                                  , en_pessoa_id      in mov_atperm_doc_fiscal.pessoa_id%type
                                  , en_modfiscal_id   in mov_atperm_doc_fiscal.modfiscal_id%type
                                  , ev_serie          in mov_atperm_doc_fiscal.serie%type
                                  , en_num_doc        in mov_atperm_doc_fiscal.num_doc%type                                  								  
                                  , en_chv_nfe_cte    in mov_atperm_doc_fiscal.chv_nfe_cte%type )
         return number
is
   --
   vn_movatpermdocfiscal_id   mov_atperm_doc_fiscal.id%type;
   --
begin
   --  
   if nvl(en_movatperm_id, 0) > 0 and
      nvl(en_dm_ind_emit, 0) > 0 and
      nvl(en_pessoa_id,0) > 0 and
      nvl(en_modfiscal_id,0) > 0 and
      nvl(en_num_doc,0) > 0 then
      --
      select a.id
        into vn_movatpermdocfiscal_id
        from mov_atperm_doc_fiscal a          
       where a.movatperm_id          = en_movatperm_id
         and a.dm_ind_emit           = en_dm_ind_emit
         and a.pessoa_id             = en_pessoa_id 
         and a.modfiscal_id          = en_modfiscal_id
         and nvl(a.serie, '#')       = nvl(ev_serie, '#') 
         and a.num_doc               = en_num_doc
         and nvl(a.chv_nfe_cte, '#') = nvl(en_chv_nfe_cte, '#');
      --
   end if;   
   --
   return vn_movatpermdocfiscal_id;
   --    
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_movatperdocfiscal_id:' || sqlerrm);
end fkg_movatperdocfiscal_id;
   
-------------------------------------------------------------------------------------------------------
-- Função retorna o id do item do documento fiscal do registro de baixa no período de apuração 
-------------------------------------------------------------------------------------------------------
function fkg_movatperdocfiscalitem_id ( en_movatpermdocfiscal_id   in mov_atperm_doc_fiscal.id%type
                                      , en_num_item                in mov_atperm_doc_fiscal_item.num_item%type
                                      , en_item_id                 in mov_atperm_doc_fiscal_item.item_id%type )
         return number
is
   --
   vn_movatpermdocfiscalitem_id   mov_atperm_doc_fiscal_item.id%type;
   --
begin
   --  
   if nvl(en_movatpermdocfiscal_id, 0) > 0 and
      nvl(en_num_item, 0) > 0 and	  
      nvl(en_item_id,0) > 0 then
      --
      select a.id
        into vn_movatpermdocfiscalitem_id
        from mov_atperm_doc_fiscal_item a          
       where a.movatpermdocfiscal_id = en_movatpermdocfiscal_id
         and a.num_item              = en_num_item
         and a.item_id               = en_item_id;
      --
   end if;   
   --
   return vn_movatpermdocfiscalitem_id;
   --    
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_movatperdocfiscalitem_id:' || sqlerrm);
end fkg_movatperdocfiscalitem_id;

-------------------------------------------------------------------------------------------------------
--Função valida se há registro na tabela icms_atperm_ciap no mesmo mes/ano.
-------------------------------------------------------------------------------------------------------
function fkg_icmsatpermciap_mes ( en_empresa_id   in  empresa.id%type
                                , ed_dt_ini  in  icms_atperm_ciap.dt_ini%type
                                ) return integer is
vn_count integer;
begin
  ----  
  vn_count:=0;
  --
  begin
     select count(1) into vn_count
     from icms_atperm_ciap 
     where empresa_id = en_empresa_id 
       and to_char(dt_ini,'mm/rrrr') = to_char(ed_dt_ini,'mm/rrrr');
  exception
    when others then   
      vn_count:=0;  
  end;
  return vn_count;
  ----
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_movatperdocfiscalitem_id:' || sqlerrm);   
end fkg_icmsatpermciap_mes;
-------------------------------------------------------------------------------------------------------

end pk_csf_ciap;
/
