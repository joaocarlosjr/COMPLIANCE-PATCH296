create or replace package body csf_own.pk_csf_efd_pc is

-------------------------------------------------------------------------------------------------------
-- Corpo do pacote geral de processos e funções da EFD PIS/COFINS
-------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------
-- Função retorna o ID do Registro do Bloco da EFD Pis/Cofins conforme código do bloco
function fkg_registr_efd_pc_id ( ev_cd  in  registr_efd_pc.cd%type )
         return registr_efd_pc.id%type
is
   --
   vv_registrefdpc_id registr_efd_pc.id%type := null;
   --
begin
   --
   select id
     into vv_registrefdpc_id
     from registr_efd_pc
    where cd = ev_cd;
   --
   return vv_registrefdpc_id;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error (-20101, 'Erro na fkg_registr_efd_pc_id: ' || sqlerrm );
end fkg_registr_efd_pc_id;

-------------------------------------------------------------------------------------------------------
-- Função retorna o ID da tabela Base de Cálculo de Crédito
function fkg_Base_Calc_Cred_Pc_id ( ev_cd in Base_Calc_Cred_Pc.cd%TYPE )
         return Base_Calc_Cred_Pc.id%TYPE
is
   --
   vn_basecalccredpc_id Base_Calc_Cred_Pc.id%TYPE;
   --
begin
   --
   if trim(ev_cd) is not null then
      --
      select bc.id
        into vn_basecalccredpc_id
        from Base_Calc_Cred_Pc bc
       where bc.cd = ev_cd;
      --
    end if;
   --
   return vn_basecalccredpc_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Base_Calc_Cred_Pc_id:' || sqlerrm);
end fkg_Base_Calc_Cred_Pc_id;

-------------------------------------------------------------------------------------------------------
-- Função retorna o CD da tabela Base de Cálculo de Crédito, conforme ID
function fkg_base_calc_cred_pc_cd ( en_id in base_calc_cred_pc.id%type )
         return base_calc_cred_pc.cd%type
is
   --
   vv_basecalccredpc_cd Base_Calc_Cred_Pc.cd%TYPE;
   --
begin
   --
   if nvl(en_id,0) > 0 then
      --
      select bc.cd
        into vv_basecalccredpc_cd
        from base_calc_cred_pc bc
       where bc.id = en_id;
      --
    end if;
   --
   return vv_basecalccredpc_cd;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Base_Calc_Cred_Pc_cd:' || sqlerrm);
end fkg_base_calc_cred_pc_cd;

-------------------------------------------------------------------------------------------------------
-- Função confirma o ID da tabela Base de Cálculo de Crédito
function fkg_id_base_calc_cred_pc_id ( en_id in base_calc_cred_pc.id%type )
         return base_calc_cred_pc.id%type
is
   --
   vn_basecalccredpc_id base_calc_cred_pc.id%type;
   --
begin
   --
   begin
      select bc.id
        into vn_basecalccredpc_id
        from base_calc_cred_pc bc
       where bc.id = en_id;
   exception
      when others then
         vn_basecalccredpc_id := null;
   end;
   --
   return vn_basecalccredpc_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_id_base_calc_cred_pc_id:' || sqlerrm);
end fkg_id_base_calc_cred_pc_id;

-------------------------------------------------------------------------------------------------------
-- Função que recupera a descrição do "Código da Base de Cálculo do Crédito" através do identificador
function fkg_descr_basecalccredpc ( en_basecalccredpc_id in base_calc_cred_pc.id%type )
         return base_calc_cred_pc.descr%type
is
   --
   vv_descr base_calc_cred_pc.descr%type;
   --
begin
   --
   begin
      select bc.descr
        into vv_descr
        from base_calc_cred_pc bc
       where bc.id = en_basecalccredpc_id;
   exception
      when others then
         vv_descr := null;
   end;
   --
   return vv_descr;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_descr_basecalccredpc:' || sqlerrm);
end fkg_descr_basecalccredpc;

-------------------------------------------------------------------------------------------------------
-- Função retorna o ID do Código do Grupo por Marca Comercial/Refrigerantes
function fkg_id_item_marca_comerc ( en_item_id in item.id%type )
         return item_marca_comerc.id%Type
is
   --
   vn_itemmarcacomerc_id item_marca_comerc.id%Type := null;
   --
begin
   --
   select id
     into vn_itemmarcacomerc_id
     from item_marca_comerc
    where item_id = en_item_id;
   --
   return vn_itemmarcacomerc_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_id_item_marca_comerc: ' || sqlerrm);
end fkg_id_item_marca_comerc;

-------------------------------------------------------------------------------------------------------
-- Função retorna o Tipo de credito padrão para documentos com o CST de 60 a 66

function fkg_tipo_cred_grupo_cst_60  ( en_empresa_id  in  empresa.id%type								  
                                     )
         return number
is
   --
   vn_multorg_id      number := 0;
   vn_modulo_id       number := 0;
   vn_grupo_id        number := 0;
   vn_vlr_param       number := 0; 
   vn_dm_tipo_pessoa  pessoa.dm_tipo_pessoa%type;
   --
begin
   --
   -- MODULO DO SISTEMA --   
   begin
      --    
      select ms.id
        into vn_modulo_id
        from modulo_sistema ms
       where ms.cod_modulo = 'OBRIG_FEDERAL';
      --	   
   exception
      when no_data_found then
         vn_modulo_id := 0;
      when others then
         vn_modulo_id := 0;	  
   end;
   --
   -- GRUPO DO SISTEMA --
   begin
      --   
      select gs.id
        into vn_grupo_id
        from grupo_sistema gs
       where gs.modulo_id = vn_modulo_id
         and gs.cod_grupo = 'EFD_CONTRIB';
      -- 		 
    exception
       when no_data_found then
          vn_grupo_id := 0;
       when others then
          vn_grupo_id := 0;
   end;
   --
   -- MULT_ORG da empresa
   begin
      --
      select e.multorg_id
        into vn_multorg_id
       from empresa e
      where e.id = en_empresa_id;
      --
   exception
      when no_data_found then
         vn_multorg_id := 0;
      when others then
         vn_multorg_id := 0;
   end;		 
   -- 
   select pgs.vlr_param
     into vn_vlr_param
     from param_geral_sistema pgs  
    where pgs.multorg_id = vn_multorg_id		  
      and pgs.modulo_id  = vn_modulo_id
      and pgs.grupo_id   = vn_grupo_id
      and pgs.param_name = 'TIPO_CRED_GRUPO_CST_60';
   --
   return vn_vlr_param;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na pk_csf_gia.fkg_tipo_cred_grupo_cst_60: ' || sqlerrm);
end fkg_tipo_cred_grupo_cst_60;

---------------------------------------------------------------------------------------------------------------
-- Função retorna o identificador do tipo de crédito para os impostos PIS/PASEP e COFINS através de parâmetros
function fkg_relac_tipo_cred_pc_id ( en_empresa_id        in empresa.id%type      -- identificador da empresa
                                   , en_tipoimp_id        in tipo_imposto.id%type -- identificador do tipo de imposto (pis ou cofins)
                                   , en_codst_id          in cod_st.id%type       -- identificador do código ST
                                   , en_ncm_id            in ncm.id%type          -- identificador do código ncm
                                   , en_cfop_id           in cfop.id%type         -- identificador do código cfop
                                   , en_ind_orig_cred     in number               -- indicador de crédito 0-Oper.Mercado Interno, 1-Oper.Importação
                                   , en_vl_aliq           in number               -- valor de alíquota dos impostos: identificar básica ou diferenciada
                                   , en_qt_bc_imp         in number               -- valor da base de cálculo - por unidade de produto
                                   , en_vl_bc_imp         in number               -- valor da base de cálculo - por valor
                                   , en_seq_lancto        in number               -- sequência de lançamento
                                   , en_basecalccredpc_id in number               -- identificador da base de cálculo de crédito para Bloco F150
                                   , en_pessoa_id         in pessoa.id%type )     -- identificador da pessoa do documento fiscal							  
         return tipo_cred_pc.id%type
is
/*
Parâmetros de entrada: tipo de imposto, ST, NCM, CFOP, indicador de origem, vlr da alíquota, vlr da bc em qtde, vlr da bc, e, vlr de imposto
valores de alíquotas ->    pis = 1,65(não-cumulativa) e 0,65(cumulativa)
valores de alíquotas -> cofins = 7,60(não cumulativa) e 3,00(cumulativa)
valores de alíquotas zeradas -> considerar como básica
*/
   --
   vn_fase                      number               := 0;
   vv_cd_codst                  cod_st.cod_st%type   := null;
   vv_aliq_basica               varchar2(1)          := null;
   vv_cd_tpcred                 tipo_cred_pc.cd%type := null;
   vv_embal                     varchar2(1)          := null;
   vn_cd_cfop                   cfop.cd%type         := null;
   vn_tipocredpc_id             tipo_cred_pc.id%type := null;
   vn_dm_util_proc_emb_tipocred empresa.dm_util_proc_emb_tipocred%type := null;
   vn_param_tp_cred_60          number               := null; 
   vv_valor_tp_param_cd         valor_tipo_param.cd%type;  
   --
begin
   --
   vn_fase := 1;
   --
   -- Função para recuperar parãmetro que indica se a empresa compõe o tipo de código de crédito através do tipo de embalagem.
   vn_dm_util_proc_emb_tipocred := pk_csf.fkg_dmutilprocemb_tpcred_empr( en_empresa_id => en_empresa_id );
   --
   vn_fase := 2;
   -- Recuperar o Código da ST através do identificador (id)
   if en_ind_orig_cred = 0 then -- Operação no Mercado Interno
      vv_cd_codst := pk_csf.fkg_cod_st_cod( en_id_st => en_codst_id );
   else -- en_ind_orig_cred = 0 then -- Operação de Importação
      vv_cd_codst := 'II';
   end if;
   --
   vn_fase := 2;
   --
   -- Recuperar a Sigla do Tipo de Imposto através do ID e verifica se a alíquota é básica ou diferenciada
   if nvl(en_vl_aliq,0) = 0 then
      vv_aliq_basica := 'S';
   elsif pk_csf.fkg_tipo_imp_sigla( en_id => en_tipoimp_id ) = 'PIS' and nvl(en_vl_aliq,0) in (1.65, 0.65) then
         vv_aliq_basica := 'S';
   elsif pk_csf.fkg_tipo_imp_sigla( en_id => en_tipoimp_id ) = 'PIS' and nvl(en_vl_aliq,0) not in (1.65, 0.65) then
         vv_aliq_basica := 'N';
   elsif pk_csf.fkg_tipo_imp_sigla( en_id => en_tipoimp_id ) = 'COFINS' and nvl(en_vl_aliq,0) in (7.6, 3) then
         vv_aliq_basica := 'S';
   elsif pk_csf.fkg_tipo_imp_sigla( en_id => en_tipoimp_id ) = 'COFINS' and nvl(en_vl_aliq,0) not in (7.6, 3) then
         vv_aliq_basica := 'N';
   end if;
   --
   vn_fase := 3;
   --
   -- Recupera o código NCM através do identificador (id) e verifica se o produto é ou não embalagem
   if substr(pk_csf.fkg_cod_ncm_id( en_ncm_id => nvl(en_ncm_id,0) ),1,4) in ('3923', '4819') then
      vv_embal := 'S';
   else
      vv_embal := 'N';
   end if;
   --
   vn_fase := 4;
   --
   -- Recupera o código Cfop através do identificador (id)
   if nvl(en_cfop_id,0) = 0 then
      vn_cd_cfop := 1; -- devido aos processo dos arquivos F100, F120, F130 e F150 -> 1-merc.interno, 2-interestadual, 3-exportação
   else
      vn_cd_cfop := pk_csf.fkg_cfop_cd( en_cfop_id => en_cfop_id );
   end if;
   --
   vn_fase := 5;
   --
   -- Recuperar o código do tipo de crédito de acordo com os parâmetros de entrada
   vv_cd_tpcred := null;
   --
   vn_fase := 6;
   --
   if vv_cd_codst = '50' then -- Operação com Direito a Crédito - Vinculada Exclusivamente a Receita Tributada no Mercado Interno
      -- caso não atenda as condições desse bloco, manter:
      vv_cd_tpcred := 199; -- Crédito vinculado à receita tributada no mercado interno - Outros
      --
      if substr(vn_cd_cfop,1,1) = 3 then
         vv_cd_tpcred := 108; -- Crédito vinculado à receita tributada no mercado interno - Importação
      else
         if nvl(en_vl_bc_imp,0) <> 0 then
            if vv_aliq_basica = 'S' then
               vv_cd_tpcred := 101; -- Crédito vinculado à receita tributada no mercado interno - Alíquota Básica
            else
               vv_cd_tpcred := 102; -- Crédito vinculado à receita tributada no mercado interno - Alíquotas Diferenciadas
            end if;
         elsif nvl(en_qt_bc_imp,0) <> 0 then
               vv_cd_tpcred := 103; -- Crédito vinculado à receita tributada no mercado interno - Alíquota por Unidade de Produto
         elsif nvl(en_vl_aliq,0) = 0 and nvl(en_qt_bc_imp,0) = 0 then -- Inclusão do teste referente a ficha HD 66673.
               vv_cd_tpcred := 102; -- Crédito vinculado à receita tributada no mercado interno - Alíquotas Diferenciadas
         end if;
         --
         if vn_dm_util_proc_emb_tipocred = 1 then -- 0-não, 1-sim
            if vv_embal = 'S' and
               vn_cd_cfop in (1102,2102,3102) then
               vv_cd_tpcred := 105; -- Crédito vinculado à receita tributada no mercado interno - Aquisição Embalagens para revenda
            end if;
         end if;
      end if;
   end if;
   --
   vn_fase := 7;
   --
   if vv_cd_codst = '51' then -- Operação com Direito a Crédito - Vinculada Exclusivamente a Receita Não Tributada no Mercado Interno
      -- caso não atenda as condições desse bloco, manter:
      vv_cd_tpcred := 299; -- Crédito vinculado à receita não tributada no mercado interno - Outros
      --
      if substr(vn_cd_cfop,1,1) = 3 then
         vv_cd_tpcred := 208; -- Crédito vinculado à receita não tributada no mercado interno - Importação
      else
         if nvl(en_vl_bc_imp,0) <> 0 then
            if vv_aliq_basica = 'S' then
               vv_cd_tpcred := 201; -- Crédito vinculado à receita não tributada no mercado interno - Alíquota Básica
            else
               vv_cd_tpcred := 202; -- Crédito vinculado à receita não tributada no mercado interno - Alíquotas Diferenciadas
            end if;
         elsif nvl(en_qt_bc_imp,0) <> 0 then
               vv_cd_tpcred := 203; -- Crédito vinculado à receita não tributada no mercado interno - Alíquota por Unidade de Produto
         elsif nvl(en_vl_aliq,0) = 0 and nvl(en_qt_bc_imp,0) = 0 then -- Inclusão do teste referente a ficha HD 66673.
               vv_cd_tpcred := 202; -- Crédito vinculado à receita não tributada no mercado interno - Alíquotas Diferenciadas
         end if;
         --
         if vn_dm_util_proc_emb_tipocred = 1 then -- 0-não, 1-sim
            if vv_embal = 'S' and
               vn_cd_cfop in (1102,2102,3102) then
               vv_cd_tpcred := 205; -- Crédito vinculado à receita não tributada no mercado interno - Aquisição Embalagens para revenda
            end if;
         end if;
      end if;
   end if;
   --
   vn_fase := 8;
   --
   if vv_cd_codst = '52' then -- Operação com Direito a Crédito - Vinculada Exclusivamente a Receita de Exportação
      -- caso não atenda as condições desse bloco, manter:
      vv_cd_tpcred := 399; -- Crédito vinculado à receita de exportação - Outros
      --
      if substr(vn_cd_cfop,1,1) = 3 then
         vv_cd_tpcred := 308; -- Crédito vinculado à receita de exportação - Importação
      else
         if nvl(en_vl_bc_imp,0) <> 0 then
            if vv_aliq_basica = 'S' then
               vv_cd_tpcred := 301; -- Crédito vinculado à receita de exportação - Alíquota Básica
            else
               vv_cd_tpcred := 302; -- Crédito vinculado à receita de exportação - Alíquotas Diferenciadas
            end if;
         elsif nvl(en_qt_bc_imp,0) <> 0 then
               vv_cd_tpcred := 303; -- Crédito vinculado à receita de exportação - Alíquota por Unidade de Produto
         elsif nvl(en_vl_aliq,0) = 0 and nvl(en_qt_bc_imp,0) = 0 then -- Inclusão do teste referente a ficha HD 66673.
               vv_cd_tpcred := 302; -- Crédito vinculado à receita de exportação - Alíquotas Diferenciadas
         end if;
         --
         if vn_dm_util_proc_emb_tipocred = 1 then -- 0-não, 1-sim
            if vv_embal = 'S' and
               vn_cd_cfop in (1102,2102,3102) then
               vv_cd_tpcred := 305; -- Crédito vinculado à receita de exportação - Aquisição Embalagens para revenda
            end if;
         end if;
      end if;
   end if;
   --
   vn_fase := 9;
   --
   if vv_cd_codst = '53' then -- Operação com Direito a Crédito - Vinculada a Receitas Tributadas e Não-Tributadas no Mercado Interno
      --
      vn_fase := 9.1;
      --
      if en_seq_lancto = 1 then
         --
         vv_cd_tpcred := 199; -- Crédito vinculado à receita tributada no mercado interno - Outros
         --
         if substr(vn_cd_cfop,1,1) = 3 then
            vv_cd_tpcred := 108; -- Crédito vinculado à receita tributada no mercado interno - Importação
         else
            if nvl(en_vl_bc_imp,0) <> 0 then
               if vv_aliq_basica = 'S' then
                  vv_cd_tpcred := 101; -- Crédito vinculado à receita tributada no mercado interno - Alíquota Básica
               else
                  vv_cd_tpcred := 102; -- Crédito vinculado à receita tributada no mercado interno - Alíquotas Diferenciadas
               end if;
            elsif nvl(en_qt_bc_imp,0) <> 0 then
                  vv_cd_tpcred := 103; -- Crédito vinculado à receita tributada no mercado interno - Alíquota por Unidade de Produto
            elsif nvl(en_vl_aliq,0) = 0 and nvl(en_qt_bc_imp,0) = 0 then -- Inclusão do teste referente a ficha HD 66673.
                  vv_cd_tpcred := 102; -- Crédito vinculado à receita tributada no mercado interno - Alíquotas Diferenciadas
            end if;
            --
            if vn_dm_util_proc_emb_tipocred = 1 then -- 0-não, 1-sim
               if vv_embal = 'S' and
                  vn_cd_cfop in (1102,2102,3102) then
                  vv_cd_tpcred := 105; -- Crédito vinculado à receita tributada no mercado interno - Aquisição Embalagens para revenda
               end if;
            end if;
         end if;
      end if;
      --
      vn_fase := 9.2;
      --
      if en_seq_lancto = 2 then
         --
         vv_cd_tpcred := 299; -- Crédito vinculado à receita não tributada no mercado interno - Outros
         --
         if substr(vn_cd_cfop,1,1) = 3 then
            vv_cd_tpcred := 208; -- Crédito vinculado à receita não tributada no mercado interno - Importação
         else
            if nvl(en_vl_bc_imp,0) <> 0 then
               if vv_aliq_basica = 'S' then
                  vv_cd_tpcred := 201; -- Crédito vinculado à receita não tributada no mercado interno - Alíquota Básica
               else
                  vv_cd_tpcred := 202; -- Crédito vinculado à receita não tributada no mercado interno - Alíquotas Diferenciadas
               end if;
            elsif nvl(en_qt_bc_imp,0) <> 0 then
                  vv_cd_tpcred := 203; -- Crédito vinculado à receita não tributada no mercado interno - Alíquota por Unidade de Produto
            elsif nvl(en_vl_aliq,0) = 0 and nvl(en_qt_bc_imp,0) = 0 then -- Inclusão do teste referente a ficha HD 66673.
                  vv_cd_tpcred := 202; -- Crédito vinculado à receita não tributada no mercado interno - Alíquotas Diferenciadas
            end if;
            --
            if vn_dm_util_proc_emb_tipocred = 1 then -- 0-não, 1-sim
               if vv_embal = 'S' and
                  vn_cd_cfop in (1102,2102,3102) then
                  vv_cd_tpcred := 205; -- Crédito vinculado à receita não tributada no mercado interno - Aquisição Embalagens para revenda
               end if;
            end if;
         end if;
      end if;
      --
   end if;
   --
   vn_fase := 10;
   --
   if vv_cd_codst = '54' then -- Operação com Direito a Crédito - Vinculada a Receitas Tributadas no Mercado Interno e de Exportação
      --
      vn_fase := 10.1;
      --
      if en_seq_lancto = 1 then
         --
         vv_cd_tpcred := 199; -- Crédito vinculado à receita tributada no mercado interno - Outros
         --
         if substr(vn_cd_cfop,1,1) = 3 then
            vv_cd_tpcred := 108; -- Crédito vinculado à receita tributada no mercado interno - Importação
         else
            if nvl(en_vl_bc_imp,0) <> 0 then
               if vv_aliq_basica = 'S' then
                  vv_cd_tpcred := 101; -- Crédito vinculado à receita tributada no mercado interno - Alíquota Básica
               else
                  vv_cd_tpcred := 102; -- Crédito vinculado à receita tributada no mercado interno - Alíquotas Diferenciadas
               end if;
            elsif nvl(en_qt_bc_imp,0) <> 0 then
                  vv_cd_tpcred := 103; -- Crédito vinculado à receita tributada no mercado interno - Alíquota por Unidade de Produto
            elsif nvl(en_vl_aliq,0) = 0 and nvl(en_qt_bc_imp,0) = 0 then -- Inclusão do teste referente a ficha HD 66673.
                  vv_cd_tpcred := 102; -- Crédito vinculado à receita tributada no mercado interno - Alíquotas Diferenciadas
            end if;
            --
            if vn_dm_util_proc_emb_tipocred = 1 then -- 0-não, 1-sim
               if vv_embal = 'S' and
                  vn_cd_cfop in (1102,2102,3102) then
                  vv_cd_tpcred := 105; -- Crédito vinculado à receita tributada no mercado interno - Aquisição Embalagens para revenda
               end if;
            end if;
         end if;
         --
      end if;
      --
      vn_fase := 10.2;
      --
      if en_seq_lancto = 2 then
         --
         vv_cd_tpcred := 399; -- Crédito vinculado à receita de exportação - Outros
         --
         if substr(vn_cd_cfop,1,1) = 3 then
            vv_cd_tpcred := 308; -- Crédito vinculado à receita de exportação - Importação
         else
            if nvl(en_vl_bc_imp,0) <> 0 then
               if vv_aliq_basica = 'S' then
                  vv_cd_tpcred := 301; -- Crédito vinculado à receita de exportação - Alíquota Básica
               else
                  vv_cd_tpcred := 302; -- Crédito vinculado à receita de exportação - Alíquotas Diferenciadas
               end if;
            elsif nvl(en_qt_bc_imp,0) <> 0 then
                  vv_cd_tpcred := 303; -- Crédito vinculado à receita de exportação - Alíquota por Unidade de Produto
            elsif nvl(en_vl_aliq,0) = 0 and nvl(en_qt_bc_imp,0) = 0 then -- Inclusão do teste referente a ficha HD 66673.
                  vv_cd_tpcred := 302; -- Crédito vinculado à receita de exportação - Alíquotas Diferenciadas
            end if;
            --
            if vn_dm_util_proc_emb_tipocred = 1 then -- 0-não, 1-sim
               if vv_embal = 'S' and
                  vn_cd_cfop in (1102,2102,3102) then
                  vv_cd_tpcred := 305; -- Crédito vinculado à receita de exportação - Aquisição Embalagens para revenda
               end if;
            end if;
            --
         end if;
      end if;
      --
   end if;
   --
   vn_fase := 11;
   --
   if vv_cd_codst = '55' then -- Operação com Direito a Crédito - Vinculada a Receitas Não-Tributadas no Mercado Interno e de Exportação
      --
      vn_fase := 11.1;
      --
      if en_seq_lancto = 1 then
         --
         vv_cd_tpcred := 299; -- Crédito vinculado à receita não tributada no mercado interno - Outros
         --
         if substr(vn_cd_cfop,1,1) = 3 then
            vv_cd_tpcred := 208; -- Crédito vinculado à receita não tributada no mercado interno - Importação
         else
            if nvl(en_vl_bc_imp,0) <> 0 then
               if vv_aliq_basica = 'S' then
                  vv_cd_tpcred := 201; -- Crédito vinculado à receita não tributada no mercado interno - Alíquota Básica
               else
                  vv_cd_tpcred := 202; -- Crédito vinculado à receita não tributada no mercado interno - Alíquotas Diferenciadas
               end if;
            elsif nvl(en_qt_bc_imp,0) <> 0 then
                  vv_cd_tpcred := 203; -- Crédito vinculado à receita não tributada no mercado interno - Alíquota por Unidade de Produto
            elsif nvl(en_vl_aliq,0) = 0 and nvl(en_qt_bc_imp,0) = 0 then -- Inclusão do teste referente a ficha HD 66673.
                  vv_cd_tpcred := 202; -- Crédito vinculado à receita não tributada no mercado interno - Alíquotas Diferenciadas
            end if;
            --
            if vn_dm_util_proc_emb_tipocred = 1 then -- 0-não, 1-sim
               if vv_embal = 'S' and
                  vn_cd_cfop in (1102,2102,3102) then
                  vv_cd_tpcred := 205; -- Crédito vinculado à receita não tributada no mercado interno - Aquisição Embalagens para revenda
               end if;
            end if;
            --
         end if;
      end if;
      --
      vn_fase := 11.2;
      --
      if en_seq_lancto = 2 then
         --
         vv_cd_tpcred := 399; -- Crédito vinculado à receita de exportação - Outros
         --
         if substr(vn_cd_cfop,1,1) = 3 then
            vv_cd_tpcred := 308; -- Crédito vinculado à receita de exportação - Importação
         else
            if nvl(en_vl_bc_imp,0) <> 0 then
               if vv_aliq_basica = 'S' then
                  vv_cd_tpcred := 301; -- Crédito vinculado à receita de exportação - Alíquota Básica
               else
                  vv_cd_tpcred := 302; -- Crédito vinculado à receita de exportação - Alíquotas Diferenciadas
               end if;
            elsif nvl(en_qt_bc_imp,0) <> 0 then
                  vv_cd_tpcred := 303; -- Crédito vinculado à receita de exportação - Alíquota por Unidade de Produto
            elsif nvl(en_vl_aliq,0) = 0 and nvl(en_qt_bc_imp,0) = 0 then -- Inclusão do teste referente a ficha HD 66673.
                  vv_cd_tpcred := 302; -- Crédito vinculado à receita de exportação - Alíquotas Diferenciadas
            end if;
            --
            if vn_dm_util_proc_emb_tipocred = 1 then -- 0-não, 1-sim
               if vv_embal = 'S' and
                  vn_cd_cfop in (1102,2102,3102) then
                  vv_cd_tpcred := 305; -- Crédito vinculado à receita de exportação - Aquisição Embalagens para revenda
               end if;
            end if;
            --
         end if;
      end if;
      --
   end if;
   --
   vn_fase := 12;
   --
   if vv_cd_codst = '56' then -- Operação com Direito a Crédito - Vinculada a Receitas Tributadas e Não-Tributadas no Mercado Interno, e de Exportação
      --
      vn_fase := 12.1;
      --
      if en_seq_lancto = 1 then
         --
         vv_cd_tpcred := 199; -- Crédito vinculado à receita tributada no mercado interno - Outros
         --
         if substr(vn_cd_cfop,1,1) = 3 then
            vv_cd_tpcred := 108; -- Crédito vinculado à receita tributada no mercado interno - Importação
         else
            if nvl(en_vl_bc_imp,0) <> 0 then
               if vv_aliq_basica = 'S' then
                  vv_cd_tpcred := 101; -- Crédito vinculado à receita tributada no mercado interno - Alíquota Básica
               else
                  vv_cd_tpcred := 102; -- Crédito vinculado à receita tributada no mercado interno - Alíquotas Diferenciadas
               end if;
            elsif nvl(en_qt_bc_imp,0) <> 0 then
                  vv_cd_tpcred := 103; -- Crédito vinculado à receita tributada no mercado interno - Alíquota por Unidade de Produto
            elsif nvl(en_vl_aliq,0) = 0 and nvl(en_qt_bc_imp,0) = 0 then -- Inclusão do teste referente a ficha HD 66673.
                  vv_cd_tpcred := 102; -- Crédito vinculado à receita tributada no mercado interno - Alíquotas Diferenciadas
            end if;
            --
            if vn_dm_util_proc_emb_tipocred = 1 then -- 0-não, 1-sim
               if vv_embal = 'S' and
                  vn_cd_cfop in (1102,2102,3102) then
                  vv_cd_tpcred := 105; -- Crédito vinculado à receita tributada no mercado interno - Aquisição Embalagens para revenda
               end if;
            end if;
            --
         end if;
         --
      end if;
      --
      vn_fase := 12.2;
      --
      if en_seq_lancto = 2 then
         --
         vv_cd_tpcred := 299; -- Crédito vinculado à receita não tributada no mercado interno - Outros
         --
         if substr(vn_cd_cfop,1,1) = 3 then
            vv_cd_tpcred := 208; -- Crédito vinculado à receita não tributada no mercado interno - Importação
         else
            if nvl(en_vl_bc_imp,0) <> 0 then
               if vv_aliq_basica = 'S' then
                  vv_cd_tpcred := 201; -- Crédito vinculado à receita não tributada no mercado interno - Alíquota Básica
               else
                  vv_cd_tpcred := 202; -- Crédito vinculado à receita não tributada no mercado interno - Alíquotas Diferenciadas
               end if;
            elsif nvl(en_qt_bc_imp,0) <> 0 then
                  vv_cd_tpcred := 203; -- Crédito vinculado à receita não tributada no mercado interno - Alíquota por Unidade de Produto
            elsif nvl(en_vl_aliq,0) = 0 and nvl(en_qt_bc_imp,0) = 0 then -- Inclusão do teste referente a ficha HD 66673.
                  vv_cd_tpcred := 202; -- Crédito vinculado à receita não tributada no mercado interno - Alíquotas Diferenciadas
            end if;
            --
            if vn_dm_util_proc_emb_tipocred = 1 then -- 0-não, 1-sim
               if vv_embal = 'S' and
                  vn_cd_cfop in (1102,2102,3102) then
                  vv_cd_tpcred := 205; -- Crédito vinculado à receita não tributada no mercado interno - Aquisição Embalagens para revenda
               end if;
            end if;
            --
         end if;
      end if;
      --
      vn_fase := 12.3;
      --
      if en_seq_lancto = 3 then
         --
         vv_cd_tpcred := 399; -- Crédito vinculado à receita de exportação - Outros
         --
         if substr(vn_cd_cfop,1,1) = 3 then
            vv_cd_tpcred := 308; -- Crédito vinculado à receita de exportação - Importação
         else
            if nvl(en_vl_bc_imp,0) <> 0 then
               if vv_aliq_basica = 'S' then
                  vv_cd_tpcred := 301; -- Crédito vinculado à receita de exportação - Alíquota Básica
               else
                  vv_cd_tpcred := 302; -- Crédito vinculado à receita de exportação - Alíquotas Diferenciadas
               end if;
            elsif nvl(en_qt_bc_imp,0) <> 0 then
                  vv_cd_tpcred := 303; -- Crédito vinculado à receita de exportação - Alíquota por Unidade de Produto
            elsif nvl(en_vl_aliq,0) = 0 and nvl(en_qt_bc_imp,0) = 0 then -- Inclusão do teste referente a ficha HD 66673.
                  vv_cd_tpcred := 302; -- Crédito vinculado à receita de exportação - Alíquotas Diferenciadas
            end if;
            --
            if vn_dm_util_proc_emb_tipocred = 1 then -- 0-não, 1-sim
               if vv_embal = 'S' and
                  vn_cd_cfop in (1102,2102,3102) then
                  vv_cd_tpcred := 305; -- Crédito vinculado à receita de exportação - Aquisição Embalagens para revenda
               end if;
            end if;
            --
         end if;
      end if;
      --
   end if;
   --
   vn_fase := 13;
   --
   if vv_cd_codst in ('60','61','62','63','64','65','66') then
      --  
      vn_param_tp_cred_60 := fkg_tipo_cred_grupo_cst_60 ( en_empresa_id  =>  en_empresa_id );
      --
      vv_valor_tp_param_cd := pk_csf.fkg_pessoa_valortipoparam_cd ( ev_tipoparam_cd => '4'  -- Produtor Rural
                                                                  , en_pessoa_id    => en_pessoa_id );
      --
      if nvl(vn_param_tp_cred_60,0) <> 0 and vv_valor_tp_param_cd = '1' then -- Pessoa é Produtor Rural
         --	
         vn_param_tp_cred_60 := 0;
         --		 
      end if;		 
      --	  
      if nvl(vn_param_tp_cred_60,0) = 0 then  -- Crédito Presumido da Agroindustria
         -- 
         vn_fase := 13.1;
         --		 
         if vv_cd_codst = '60' then -- Crédito Presumido - Operação de Aquisição Vinculada Exclusivamente a Receita Tributada no Mercado Interno
            vv_cd_tpcred := 106; -- Crédito vinculado à receita tributada no mercado interno - Presumido da Agroindústria
         elsif vv_cd_codst = '61' then -- Crédito Presumido - Operação de Aquisição Vinculada Exclusivamente a Receita Não-Tributada no Mercado Interno
               vv_cd_tpcred := 206; -- Crédito vinculado à receita não tributada no mercado interno - Presumido da Agroindústria
         elsif vv_cd_codst = '62' then -- Crédito Presumido - Operação de Aquisição Vinculada Exclusivamente a Receita de Exportação
               vv_cd_tpcred := 306; -- Crédito vinculado à receita de exportação - Presumido da Agroindústria
         elsif vv_cd_codst = '63' then -- Crédito Presumido - Operação de Aquisição Vinculada a Receitas Tributadas e Não-Tributadas no Mercado Interno
               if en_seq_lancto = 1 then
                  vv_cd_tpcred := 106; -- Crédito vinculado à receita tributada no mercado interno - Presumido da Agroindústria
               elsif en_seq_lancto = 2 then
                     vv_cd_tpcred := 206; -- Crédito vinculado à receita não tributada no mercado interno - Presumido da Agroindústria
               end if;
         elsif vv_cd_codst = '64' then -- Crédito Presumido - Operação de Aquisição Vinculada a Receitas Tributadas no Mercado Interno e de Exportação
               if en_seq_lancto = 1 then
                  vv_cd_tpcred := 106; -- Crédito vinculado à receita tributada no mercado interno - Presumido da Agroindústria
               elsif en_seq_lancto = 2 then
                     vv_cd_tpcred := 306; -- Crédito vinculado à receita de exportação - Presumido da Agroindústria
               end if;
         elsif vv_cd_codst = '65' then -- Crédito Presumido - Operação de Aquisição Vinculada a Receitas Não-Tributadas no Mercado Interno e de Exportação
               if en_seq_lancto = 1 then
                  vv_cd_tpcred := 206; -- Crédito vinculado à receita não tributada no mercado interno - Presumido da Agroindústria
               elsif en_seq_lancto = 2 then
                     vv_cd_tpcred := 306; -- Crédito vinculado à receita de exportação - Presumido da Agroindústria
               end if;
         elsif vv_cd_codst = '66' then -- Crédito Presumido - Operação de Aquisição Vinculada a Receitas Tributadas e Não-Tributadas no Mercado Interno, e de Exportação
               if en_seq_lancto = 1 then
                  vv_cd_tpcred := 106; -- Crédito vinculado à receita tributada no mercado interno - Presumido da Agroindústria
               elsif en_seq_lancto = 2 then
                     vv_cd_tpcred := 206; -- Crédito vinculado à receita não tributada no mercado interno - Presumido da Agroindústria
               elsif en_seq_lancto = 3 then
                     vv_cd_tpcred := 306; -- Crédito vinculado à receita de exportação - Presumido da Agroindústria
               end if;
         end if;
         --
      else  -- Serviços de Transporte  e   Outros 
         -- 
         vn_fase := 13.2;
         --		 
         if vv_cd_codst = '60' then -- Crédito Presumido - Operação de Aquisição Vinculada Exclusivamente a Receita Tributada no Mercado Interno
            vv_cd_tpcred := 107; -- Crédito vinculado à receita tributada no mercado interno - Outros Créditos Presumidos
         elsif vv_cd_codst = '61' then -- Crédito Presumido - Operação de Aquisição Vinculada Exclusivamente a Receita Não-Tributada no Mercado Interno
               vv_cd_tpcred := 207; -- CCrédito vinculado à receita não tributada no mercado interno - Outros Créditos Presumidos
         elsif vv_cd_codst = '62' then -- Crédito Presumido - Operação de Aquisição Vinculada Exclusivamente a Receita de Exportação
               vv_cd_tpcred := 307; -- Crédito vinculado à receita de exportação  Demais Créditos Presumidos
         elsif vv_cd_codst = '63' then -- Crédito Presumido - Operação de Aquisição Vinculada a Receitas Tributadas e Não-Tributadas no Mercado Interno
               if en_seq_lancto = 1 then
                  vv_cd_tpcred := 107; -- Crédito vinculado à receita tributada no mercado interno - Outros Créditos Presumidos
               elsif en_seq_lancto = 2 then
                     vv_cd_tpcred := 207; -- Crédito vinculado à receita não tributada no mercado interno - Outros Créditos Presumidos
               end if;
         elsif vv_cd_codst = '64' then -- Crédito Presumido - Operação de Aquisição Vinculada a Receitas Tributadas no Mercado Interno e de Exportação
               if en_seq_lancto = 1 then
                  vv_cd_tpcred := 107; -- Crédito vinculado à receita tributada no mercado interno - Outros Créditos Presumidos
               elsif en_seq_lancto = 2 then
                     vv_cd_tpcred := 307; -- Crédito vinculado à receita de exportação  Demais Créditos Presumidos
               end if;
         elsif vv_cd_codst = '65' then -- Crédito Presumido - Operação de Aquisição Vinculada a Receitas Não-Tributadas no Mercado Interno e de Exportação
               if en_seq_lancto = 1 then
                  vv_cd_tpcred := 207; -- Crédito vinculado à receita não tributada no mercado interno - Outros Créditos Presumidos
               elsif en_seq_lancto = 2 then
                     vv_cd_tpcred := 307; -- Crédito vinculado à receita de exportação  Demais Créditos Presumidos
               end if;
         elsif vv_cd_codst = '66' then -- Crédito Presumido - Operação de Aquisição Vinculada a Receitas Tributadas e Não-Tributadas no Mercado Interno, e de Exportação
               if en_seq_lancto = 1 then
                  vv_cd_tpcred := 107; -- Crédito vinculado à receita tributada no mercado interno - Outros Créditos Presumidos
               elsif en_seq_lancto = 2 then
                     vv_cd_tpcred := 207; -- Crédito vinculado à receita não tributada no mercado interno - Outros Créditos Presumidos
               elsif en_seq_lancto = 3 then
                     vv_cd_tpcred := 307; -- Crédito vinculado à receita de exportação  Demais Créditos Presumidos
               end if;
         end if;
         --
      end if;
      --	  
   end if;   
   --   
   vn_fase := 14;
   --
   if vv_cd_codst = 'II' then -- Crédito de origem Importação
      if substr(vn_cd_cfop,1,1) <> 3 then -- CFOP com início 3 se refere a exportação, não deve atender esse item - somente do grupo interno
         if nvl(en_vl_bc_imp,0) <> 0 then
            --vv_cd_tpcred := 108; -- Crédito vinculado à receita tributada no mercado interno - Importação
            if en_seq_lancto = 1 then
               vv_cd_tpcred := 108; -- Crédito vinculado à receita tributada no mercado interno - Importação
            elsif en_seq_lancto = 2 then
                  vv_cd_tpcred := 208; -- Crédito vinculado à receita não tributada no mercado interno - Importação
            elsif en_seq_lancto = 3 then
                  vv_cd_tpcred := 308; -- Crédito vinculado à receita de exportação - Importação
            end if;
         elsif nvl(en_qt_bc_imp,0) <> 0 then
               vv_cd_tpcred := 208; -- Crédito vinculado à receita não tributada no mercado interno - Importação
         end if;
      elsif substr(vn_cd_cfop,1,1) = 3 then -- CFOP com início 3 se refere a exportação, não deve atender esse item - somente do grupo interno
            vv_cd_tpcred := 308; -- Crédito vinculado à receita de exportação - Importação
      end if;
   end if;
   --
   vn_fase := 15;
   --
   -- O tipo de crédito 109-Atividade Imobiliária, seria referente aos registros F205 e F210,
   -- esses não foram gerados, devido aos tipos de clientes existentes no momento.
   --
   -- Os tipos de crédito referentes ao estoque de abertura (104, 204 e 304), são gerados no processo específico para os mesmos.
   if pk_csf_efd_pc.fkg_base_calc_cred_pc_cd(nvl(en_basecalccredpc_id,0)) = '18' then -- Estoque de abertura de bens - Origem do Bloco F150
      --
      if vv_cd_codst = '50' then -- Operação com Direito a Crédito - Vinculada Exclusivamente a Receita Tributada no Mercado Interno
         --
         vv_cd_tpcred := 104; -- Crédito vinculado à receita tributada no mercado interno - Estoque de Abertura
         --
      elsif vv_cd_codst = '51' then -- Operação com Direito a Crédito - Vinculada Exclusivamente a Receita Não Tributada no Mercado Interno
            --
            vv_cd_tpcred := 204; -- Crédito vinculado à receita não tributada no mercado interno - Estoque de Abertura
            --
      elsif vv_cd_codst = '52' then -- Operação com Direito a Crédito - Vinculada Exclusivamente a Receita de Exportação
            --
            vv_cd_tpcred := 304; -- Crédito vinculado à receita de exportação - Estoque de Abertura
            --
      elsif vv_cd_codst = '53' then -- Operação com Direito a Crédito - Vinculada a Receitas Tributadas e Não-Tributadas no Mercado Interno
            --
            if en_seq_lancto = 1 then
               vv_cd_tpcred := 104; -- Crédito vinculado à receita tributada no mercado interno - Estoque de Abertura
            elsif en_seq_lancto = 2 then
                  vv_cd_tpcred := 204; -- Crédito vinculado à receita não tributada no mercado interno - Estoque de Abertura
            end if;
            --
      elsif vv_cd_codst = '54' then -- Operação com Direito a Crédito - Vinculada a Receitas Tributadas no Mercado Interno e de Exportação
            --
            if en_seq_lancto = 1 then
               vv_cd_tpcred := 104; -- Crédito vinculado à receita tributada no mercado interno - Estoque de Abertura
            elsif en_seq_lancto = 2 then
                  vv_cd_tpcred := 304; -- Crédito vinculado à receita de exportação - Estoque de Abertura
            end if;
            --
      elsif vv_cd_codst = '55' then -- Operação com Direito a Crédito - Vinculada a Receitas Não-Tributadas no Mercado Interno e de Exportação
            --
            if en_seq_lancto = 1 then
               vv_cd_tpcred := 204; -- Crédito vinculado à receita não tributada no mercado interno - Estoque de Abertura
            elsif en_seq_lancto = 2 then
                  vv_cd_tpcred := 304; -- Crédito vinculado à receita de exportação - Estoque de Abertura
            end if;
            --
      elsif vv_cd_codst = '56' then -- Operação com Direito a Crédito - Vinculada a Receitas Tributadas e Não-Tributadas no Mercado Interno, e de Exportação
            --
            if en_seq_lancto = 1 then
               vv_cd_tpcred := 104; -- Crédito vinculado à receita tributada no mercado interno - Estoque de Abertura
            elsif en_seq_lancto = 2 then
                  vv_cd_tpcred := 204; -- Crédito vinculado à receita não tributada no mercado interno - Estoque de Abertura
            elsif en_seq_lancto = 3 then
                  vv_cd_tpcred := 304; -- Crédito vinculado à receita de exportação - Estoque de Abertura
            end if;
            --
      end if;
      --
   end if;
   --
   -- Recuperar o identificador do tipo de crédito através do código (cd)
   vn_tipocredpc_id := fkg_tipo_cred_pc_id( ev_cd => vv_cd_tpcred);
   --
   vn_fase := 16;
   --
   return(vn_tipocredpc_id);
   --
exception
   when others then
      raise_application_error(-20101, 'Problemas em fkg_relac_tipo_cred_pc_id (fase='||vn_fase||'). Erro = '||sqlerrm);
end fkg_relac_tipo_cred_pc_id;

-------------------------------------------------------------------------------------------------------
-- Função para retornar o identificador do tipo de crédito para os impostos pis/cofins
function fkg_tipo_cred_pc_id ( ev_cd in tipo_cred_pc.cd%type )
         return tipo_cred_pc.id%type
is
   --
   vn_tipocredpc_id tipo_cred_pc.id%type;
   --
begin
   --
   begin
      select tc.id
        into vn_tipocredpc_id
        from tipo_cred_pc tc
       where tc.cd = ev_cd;
   exception
      when others then
         vn_tipocredpc_id := null;
   end;
   --
   return(vn_tipocredpc_id);
   --
exception
   when others then
      return(null);
end fkg_tipo_cred_pc_id;

-------------------------------------------------------------------------------------------------------
-- Função para retornar o código do identificador do tipo de crédito para os impostos pis/cofins
function fkg_cd_tipo_cred_pc ( en_tipocredpc_id in tipo_cred_pc.id%type )
         return tipo_cred_pc.cd%type
is
   --
   vv_cd tipo_cred_pc.cd%type;
   --
begin
   --
   begin
      select tc.cd
        into vv_cd
        from tipo_cred_pc tc
       where tc.id = en_tipocredpc_id;
   exception
      when others then
         vv_cd := null;
   end;
   --
   return(vv_cd);
   --
exception
   when others then
      return(null);
end fkg_cd_tipo_cred_pc;

--------------------------------------------------------------------------------------------------------------
-- Função para retornar a descrição do código do identificador do tipo de crédito para os impostos pis/cofins
function fkg_descr_tipo_cred_pc ( en_tipocredpc_id in tipo_cred_pc.id%type )
         return tipo_cred_pc.descr%type
is
   --
   vv_descr tipo_cred_pc.descr%type;
   --
begin
   --
   begin
      select tc.descr
        into vv_descr
        from tipo_cred_pc tc
       where tc.id = en_tipocredpc_id;
   exception
      when others then
         vv_descr := null;
   end;
   --
   return(vv_descr);
   --
exception
   when others then
      return(null);
end fkg_descr_tipo_cred_pc;

-------------------------------------------------------------------------------------------------------
-- Função para retornar o código do identificador da Contribuição Social para o Imposto PIS
function fkg_cd_contr_soc_apur_pc ( en_contrsocapurpc_id in contr_soc_apur_pc.id%type )
         return contr_soc_apur_pc.cd%type
is
   --
   vv_cd contr_soc_apur_pc.cd%type;
   --
begin
   --
   begin
      select cs.cd
        into vv_cd
        from contr_soc_apur_pc cs
       where cs.id = en_contrsocapurpc_id;
   exception
      when others then
         vv_cd := null;
   end;
   --
   return(vv_cd);
   --
exception
   when others then
      return(null);
end fkg_cd_contr_soc_apur_pc;

-------------------------------------------------------------------------------------------------------
-- Função para retornar o identificador do Código de Contribuição Social para o imposto pis
function fkg_contr_soc_apur_pc_id ( ev_cd in contr_soc_apur_pc.cd%type )
         return contr_soc_apur_pc.id%type
is
   --
   vn_contrsocapurpc_id contr_soc_apur_pc.id%type;
   --
begin
   --
   begin
      select cs.id
        into vn_contrsocapurpc_id
        from contr_soc_apur_pc cs
       where cs.cd = ev_cd;
   exception
      when others then
         vn_contrsocapurpc_id := null;
   end;
   --
   return(vn_contrsocapurpc_id);
   --
exception
   when others then
      return(null);
end fkg_contr_soc_apur_pc_id;

---------------------------------------------------------------------------------------------------------------
-- Função retorna o código de contribuição social através de parâmetros
function fkg_relac_cons_contr_id ( en_tipoimp_id      in tipo_imposto.id%type -- identificador do tipo de imposto (pis ou cofins)
                                 , en_ind_orig_cred   in number               -- indicador de crédito 0-Oper.Mercado Interno, 1-Oper.Importação
                                 , en_codst_id        in cod_st.id%type       -- identificador do código ST
                                 , en_vl_aliq         in number               -- valor de alíquota em percentual
                                 , en_vl_aliq_quant   in number               -- valor da alíquota por unidade de produto
                                 , en_dm_cod_inc_trib in abertura_efd_pc_regime.dm_cod_inc_trib%type -- indicador da incidência tributária
                                 , ev_bloco           in varchar2 default null ) -- código do bloco a ser processado
         return contr_soc_apur_pc.id%type
is
/*
Parâmetros de entrada: ST, vlr da alíquota em percentual, vlr da alíquota em qtde
valores de alíquotas ->    pis = 1,65(não-cumulativa) e 0,65(cumulativa)
valores de alíquotas -> cofins = 7,60(não cumulativa) e 3,00(cumulativa)
valores de alíquotas zeradas -> considerar como básica
*/
   --
   vn_fase              number               := 0;
   vv_cd_codst          cod_st.cod_st%type   := null;
   vv_cod_cont          contr_soc_apur_pc.cd%type := null;
   vn_contrsocapurpc_id contr_soc_apur_pc.id%type := null;
   --
begin
   --
   vn_fase := 1;
   --
   -- Recuperar o Código da ST através do identificador (id)
   if en_ind_orig_cred = 0 then -- Operação no Mercado Interno
      vv_cd_codst := pk_csf.fkg_cod_st_cod( en_id_st => en_codst_id );
   else -- en_ind_orig_cred = 0 then -- Operação de Importação
      vv_cd_codst := 'II';
   end if;
   --
   vn_fase := 2;
   --
   if vv_cd_codst = '01' then -- Operação Tributável (base de cálculo = valor da operação alíquota normal (cumulativo/não cumulativo))
      if pk_csf.fkg_tipo_imp_sigla( en_id => en_tipoimp_id ) = 'PIS' then
         if en_dm_cod_inc_trib in (1,3) and
            (nvl(en_vl_aliq,0) = 1.65 or nvl(en_vl_aliq,0) = 0) and
            nvl(en_vl_aliq_quant,0) = 0 then
            if nvl(ev_bloco,' ') = 'F200' then
               vv_cod_cont := '04';
            else
               vv_cod_cont := '01';
            end if;
         elsif en_dm_cod_inc_trib in (2,3) and
               (nvl(en_vl_aliq,0) = 0.65 or nvl(en_vl_aliq,0) = 0) and
               nvl(en_vl_aliq_quant,0) = 0 then
               if nvl(ev_bloco,' ') = 'F200' then
                  vv_cod_cont := '54';
               else
                  vv_cod_cont := '51';
               end if;
         else
            vv_cod_cont := 'XX';
         end if;
      elsif pk_csf.fkg_tipo_imp_sigla( en_id => en_tipoimp_id ) = 'COFINS' then
            if en_dm_cod_inc_trib in (1,3) and
               (nvl(en_vl_aliq,0) = 7.60 or nvl(en_vl_aliq,0) = 0) and
               nvl(en_vl_aliq_quant,0) = 0 then
               if nvl(ev_bloco,' ') = 'F200' then
                  vv_cod_cont := '04';
               else
                  vv_cod_cont := '01';
               end if;
            elsif en_dm_cod_inc_trib in (2,3) and
                  (nvl(en_vl_aliq,0) = 3.00 or nvl(en_vl_aliq,0) = 0) and
                  nvl(en_vl_aliq_quant,0) = 0 then
                  if nvl(ev_bloco,' ') = 'F200' then
                     vv_cod_cont := '54';
                  else
                     vv_cod_cont := '51';
                  end if;
            else
               vv_cod_cont := 'XX';
            end if;
      else
         vv_cod_cont := 'XX';
      end if;
   end if;
   --
   vn_fase := 3;
   --
   if vv_cd_codst = '02' then -- Operação Tributável (base de cálculo = valor da operação (alíquota diferenciada))
      if pk_csf.fkg_tipo_imp_sigla( en_id => en_tipoimp_id ) = 'PIS' then
         if en_dm_cod_inc_trib in (1,3) and
            (nvl(en_vl_aliq,0) <> 1.65 and nvl(en_vl_aliq,0) <> 0) and
            nvl(en_vl_aliq_quant,0) = 0 then
            vv_cod_cont := '02';
         elsif en_dm_cod_inc_trib in (2) then
               vv_cod_cont := '52';
         else
            vv_cod_cont := 'XX';
         end if;
      elsif pk_csf.fkg_tipo_imp_sigla( en_id => en_tipoimp_id ) = 'COFINS' then
            if en_dm_cod_inc_trib in (1,3) and
               (nvl(en_vl_aliq,0) <> 7.60 and nvl(en_vl_aliq,0) <> 0) and
               nvl(en_vl_aliq_quant,0) = 0 then
               vv_cod_cont := '02';
            elsif en_dm_cod_inc_trib in (2) then
                  vv_cod_cont := '52';
            else
               vv_cod_cont := 'XX';
            end if;
      else
         vv_cod_cont := 'XX';
      end if;
   end if;
   --
   vn_fase := 4;
   --
   if vv_cd_codst = '03' then -- Operação Tributável (base de cálculo = quantidade vendida x alíquota por unidade de produto)
      if en_dm_cod_inc_trib in (1,3) and
         nvl(en_vl_aliq,0) = 0 and
         nvl(en_vl_aliq_quant,0) > 0 then
         vv_cod_cont := '03';
      elsif en_dm_cod_inc_trib in (2) then
            vv_cod_cont := '53';
      else
         vv_cod_cont := 'XX';
      end if;
   end if;
   --
   vn_fase := 5;
   --
   if vv_cd_codst = '05' then -- Operação Tributável (substituição tributária)
      if pk_csf.fkg_tipo_imp_sigla( en_id => en_tipoimp_id ) = 'PIS' then
         if nvl(en_vl_aliq,0) = 0.65 and
            nvl(en_vl_aliq_quant,0) = 0 then
            vv_cod_cont := '31';
         elsif (nvl(en_vl_aliq,0) <> 0.65 and nvl(en_vl_aliq,0) <> 0) and
               nvl(en_vl_aliq_quant,0) > 0 then
               vv_cod_cont := '32';
         else
            vv_cod_cont := 'XX';
         end if;
      elsif pk_csf.fkg_tipo_imp_sigla( en_id => en_tipoimp_id ) = 'COFINS' then
            if nvl(en_vl_aliq,0) = 3.00 and
               nvl(en_vl_aliq_quant,0) = 0 then
               vv_cod_cont := '31';
            elsif (nvl(en_vl_aliq,0) <> 3.00 and nvl(en_vl_aliq,0) <> 0) and
                  nvl(en_vl_aliq_quant,0) > 0 then
                  vv_cod_cont := '32';
            else
               vv_cod_cont := 'XX';
            end if;
      else
         vv_cod_cont := 'XX';
      end if;
   end if;
   --
   vn_fase := 6;
   --
   -- Os códigos de contribuição social: 4, 54 e 70, não estão sendo tratados, pois não possuem código de ST correspondente,
   -- e são de código de incidência referente a Atividade Imobiliária.
   -- O código de contribuição social: 99, não está sendo tratado, pois não possui código de ST correspondente, e é de código de
   -- incidência referente a Folha de Salários.
   -- Os códigos de contribuição social: 71 e 72, não estão sendo tratados, pois não possuem código de ST e nem código de
   -- incidência, correspondentes.
   --
   -- Recuperar o identificador do Código de Contribuição Social através do código (cd)
   vn_contrsocapurpc_id := fkg_contr_soc_apur_pc_id( ev_cd => vv_cod_cont);
   --
   vn_fase := 7;
   --
   return(vn_contrsocapurpc_id);
   --
exception
   when others then
      raise_application_error(-20101, 'Problemas em fkg_relac_cons_contr_id (fase='||vn_fase||'). Erro = '||sqlerrm);
end fkg_relac_cons_contr_id;

------------------------------------------------------------------------------------------------------------------------
-- Função retorna o código de contribuição social através de parâmetros para ajustes automáticos dos blocos M200 e M600
function fkg_ajuste_cons_contr_id ( en_tipoimp_id      in tipo_imposto.id%type                        -- identificador do tipo de imposto (pis ou cofins)
                                  , en_dm_ind_ativ     in abertura_efd_pc.dm_ind_ativ%type            -- indicador de atividade
                                  , en_dm_cod_inc_trib in abertura_efd_pc_regime.dm_cod_inc_trib%type -- indicador da incidência tributária
                                  , en_cd_codst        in cod_st.cod_st%type                          -- código ST
                                  , en_aliq            in imp_itemnf.aliq_apli%type )                 -- valor de alíquota em percentual
         return contr_soc_apur_pc.id%type
is
/*
Parâmetros de entrada: ST, vlr da alíquota em percentual
valores de alíquotas ->    pis = 1,65(não-cumulativa) e 0,65(cumulativa)
valores de alíquotas -> cofins = 7,60(não cumulativa) e 3,00(cumulativa)
valores de alíquotas zeradas -> considerar como básica
*/
   --
   vn_fase              number                    := 0;
   vv_cd_contrsocapurpc contr_soc_apur_pc.cd%type := null;
   vn_contrsocapurpc_id contr_soc_apur_pc.id%type := null;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_aliq,0) in (1.65,7.60) and
      en_dm_cod_inc_trib in (1,3) and -- Indicador da incidência tributária - Escrituração no regime: 1-Não-cumulativo, 2-Cumulativo, 3-Não-cumulativo e Cumulativo
      en_dm_ind_ativ <> 4 and -- Abertura não é de atividade imobiliária
      en_cd_codst <> '75' then -- Operação de Aquisição por Substituição Tributária
      --
      vn_fase := 2;
      vv_cd_contrsocapurpc := '01'; -- Contribuição não-cumulativa apurada a alíquota básica
      --
   elsif nvl(en_aliq,0) in (0.65,3.00) and
         en_dm_cod_inc_trib in (2,3) and -- Indicador da incidência tributária - Escrituração no regime: 1-Não-cumulativo, 2-Cumulativo, 3-Não-cumulativo e Cumulativo
         en_dm_ind_ativ <> 4 and -- Abertura não é de atividade imobiliária
         en_cd_codst <> '75' then -- Operação de Aquisição por Substituição Tributária
         --
         vn_fase := 3;
         vv_cd_contrsocapurpc := '51'; -- Contribuição cumulativa apurada a alíquota básica
         --
   elsif nvl(en_aliq,0) not in (1.65,0.65,7.60,3.00) and
         en_dm_cod_inc_trib in (1,3) and -- Indicador da incidência tributária - Escrituração no regime: 1-Não-cumulativo, 2-Cumulativo, 3-Não-cumulativo e Cumulativo
         en_dm_ind_ativ <> 4 and -- Abertura não é de atividade imobiliária
         en_cd_codst <> '75' then -- Operação de Aquisição por Substituição Tributária
         --
         vn_fase := 4;
         vv_cd_contrsocapurpc := '02'; -- Contribuição não-cumulativa apurada a alíquotas diferenciadas
         --
   elsif nvl(en_aliq,0) not in (1.65,0.65,7.60,3.00) and
         en_dm_cod_inc_trib in (2) and -- Indicador da incidência tributária - Escrituração no regime: 1-Não-cumulativo, 2-Cumulativo, 3-Não-cumulativo e Cumulativo
         en_dm_ind_ativ <> 4 and -- Abertura não é de atividade imobiliária
         en_cd_codst <> '75' then -- Operação de Aquisição por Substituição Tributária
         --
         vn_fase := 5;
         vv_cd_contrsocapurpc := '52'; -- Contribuição cumulativa apurada a alíquotas diferenciadas
         --
   elsif nvl(en_aliq,0) in (0.65,3.00) and
         en_dm_ind_ativ <> 4 and -- Abertura não é de atividade imobiliária
         en_cd_codst = '75' then -- Operação de Aquisição por Substituição Tributária
         --
         vn_fase := 6;
         vv_cd_contrsocapurpc := '31'; -- Contribuição apurada por substituição tributária
         --
   elsif nvl(en_aliq,0) not in (0.65,3.00) and
         en_dm_ind_ativ <> 4 and -- Abertura não é de atividade imobiliária
         en_cd_codst = '75' then -- Operação de Aquisição por Substituição Tributária
         --
         vn_fase := 7;
         vv_cd_contrsocapurpc := '32'; -- Contribuição apurada por substituição tributária - Vendas à Zona Franca de Manaus
         --
   elsif nvl(en_aliq,0) in (1.65,7.60) and
         en_dm_cod_inc_trib in (1,3) and -- Indicador da incidência tributária - Escrituração no regime: 1-Não-cumulativo, 2-Cumulativo, 3-Não-cumulativo e Cumulativo
         en_dm_ind_ativ = 4 and -- Abertura é de atividade imobiliária
         en_cd_codst <> '75' then -- Operação de Aquisição por Substituição Tributária
         --
         vn_fase := 8;
         vv_cd_contrsocapurpc := '04'; -- Contribuição não-cumulativa apurada a alíquota básica - Atividade Imobiliária
         --
   elsif nvl(en_aliq,0) in (0.65,3.00) and
         en_dm_cod_inc_trib in (2,3) and -- Indicador da incidência tributária - Escrituração no regime: 1-Não-cumulativo, 2-Cumulativo, 3-Não-cumulativo e Cumulativo
         en_dm_ind_ativ = 4 and -- Abertura é de atividade imobiliária
         en_cd_codst <> '75' then -- Operação de Aquisição por Substituição Tributária
         --
         vn_fase := 9;
         vv_cd_contrsocapurpc := '54'; -- Contribuição cumulativa apurada a alíquota básica - Atividade Imobiliária
         --
   else
      --
      vn_fase := 10;
      vv_cd_contrsocapurpc := '00'; -- Processo inválido
      --
   end if;
   --
   vn_fase := 11;
   -- Recuperar o identificador do Código de Contribuição Social através do código (cd)
   vn_contrsocapurpc_id := fkg_contr_soc_apur_pc_id( ev_cd => vv_cd_contrsocapurpc);
   --
   vn_fase := 12;
   --
   return(vn_contrsocapurpc_id);
   --
exception
   when others then
      raise_application_error(-20101, 'Problemas em pk_csf_efd_pc.fkg_ajuste_cons_contr_id (fase='||vn_fase||'). Erro = '||sqlerrm);
end fkg_ajuste_cons_contr_id;

-----------------------------------------------------------------------------------------------------------------------------------
-- Função para retornar o identificador da Natureza de Receita Conforme Código de Situação Tributária, Alíquotas e Tipo de Imposto
function fkg_nat_rec_pc_id ( en_multorg_id in nat_rec_pc.multorg_id%type
                           , en_codst_id   in cod_st.id%type
                           , en_aliq_apli  in number
                           , en_aliq_qtde  in number
                           , en_ncm_id     in number   default 0
                           , ev_cod_ncm    in varchar2 default null
                           )
         return nat_rec_pc.id%type
is
   --
   vn_id      nat_rec_pc.id%type;
   vn_dm_tipo nat_rec_pc.dm_tipo%type;
   --
begin
   --
   if pk_csf.fkg_cod_st_cod( en_id_st => en_codst_id ) = '04' then
      if en_aliq_qtde <> 0 then -- alíquota por unidade de medida de produto
         vn_dm_tipo := 1;
      else -- alíquota zerada e diferenciada
         vn_dm_tipo := 0;
      end if;
   elsif pk_csf.fkg_cod_st_cod( en_id_st => en_codst_id ) = '05' and
         en_aliq_apli = 0 then -- alíquota zerada
         vn_dm_tipo := 2;
   elsif pk_csf.fkg_cod_st_cod( en_id_st => en_codst_id ) = '06' and
         en_aliq_apli = 0 then -- alíquota zerada
         vn_dm_tipo := 3;
   elsif pk_csf.fkg_cod_st_cod( en_id_st => en_codst_id ) = '07' then
         vn_dm_tipo := 4;
   elsif pk_csf.fkg_cod_st_cod( en_id_st => en_codst_id ) = '08' then
         vn_dm_tipo := 5;
   elsif pk_csf.fkg_cod_st_cod( en_id_st => en_codst_id ) = '09' then
         vn_dm_tipo := 6;
   else -- alíquota zerada e diferenciada
      vn_dm_tipo := 0;
   end if;
   --
   begin
      --
      if nvl(en_ncm_id,0) <> 0 then
         --
         select nr.id
           into vn_id
           from nat_rec_pc nr
          where nr.codst_id = en_codst_id
            and nr.dm_tipo  = vn_dm_tipo
            and nr.multorg_id = en_multorg_id
            and exists (select nn.natrecpc_id
                          from ncm_nat_rec_pc nn
                         where nn.natrecpc_id = nr.id
                           and nn.ncm_id      = en_ncm_id)
            and rownum = 1;
         --
      elsif ev_cod_ncm is not null then
            --
            select nr.id
              into vn_id
              from nat_rec_pc nr
             where nr.codst_id = en_codst_id
               and nr.dm_tipo  = vn_dm_tipo
               and nr.multorg_id = en_multorg_id
               and exists (select nn.natrecpc_id
                             from ncm_nat_rec_pc nn
                                , ncm            nc
                            where nn.natrecpc_id = nr.id
                              and nc.id          = nn.ncm_id
                              and nc.cod_ncm     = ev_cod_ncm)
               and rownum = 1;
            --
      end if;
      --
   exception
      when others then
         vn_id := null;
   end;
   --
   return(vn_id);
   --
exception
   when others then
      return(null);
end fkg_nat_rec_pc_id;

------------------------------------------------------------------------------------------------------------------
-- Função para confirmar o identificador da Natureza de Receita
function fkg_conf_id_nat_rec_pc ( en_natrecpc_id in nat_rec_pc.id%type )
         return nat_rec_pc.id%type
is
   --
   vn_id nat_rec_pc.id%type;
   --
begin
   --
   begin
      select nr.id
        into vn_id
        from nat_rec_pc nr
       where nr.id = en_natrecpc_id;
   exception
      when others then
         vn_id := null;
   end;
   --
   return(vn_id);
   --
exception
   when others then
      return(null);
end fkg_conf_id_nat_rec_pc;

------------------------------------------------------------------------------------------------------------------
-- Função para retorar o "código" da Natureza da Receita do Pis/COFINS
function fkg_cod_id_nat_rec_pc ( en_natrecpc_id in nat_rec_pc.id%type )
         return nat_rec_pc.cod%type
is
   --
   vn_cod nat_rec_pc.cod%type;
   --
begin
   --
   begin
      select nr.cod
        into vn_cod
        from nat_rec_pc nr
       where nr.id = en_natrecpc_id;
   exception
      when others then
         vn_cod := null;
   end;
   --
   return(vn_cod);
   --
exception
   when others then
      return(null);
end fkg_cod_id_nat_rec_pc;

------------------------------------------------------------------------------------------------------------------
-- Função para retorar o "ID" da Natureza da Receita do Pis/COFINS pelo Cod_st e cod
function fkg_codst_id_nat_rec_pc ( en_multorg_id        in nat_rec_pc.multorg_id%type
                                 , en_natrecpc_codst_id in nat_rec_pc.codst_id%type
                                 , en_natrecpc_cod      in nat_rec_pc.cod%type
                                 )
         return nat_rec_pc.id%type
is
   --
   vn_id  nat_rec_pc.id%type;
   --
begin
   --
   begin
      select min(nr.id)
        into vn_id
        from nat_rec_pc nr
       where nr.codst_id = en_natrecpc_codst_id
         and nr.cod = en_natrecpc_cod
         and nr.multorg_id = en_multorg_id;
   exception
      when others then
         vn_id := null;
   end;
   --
   if nvl(vn_id,0) <= 0 then
      --
      begin
         select min(nr.id)
           into vn_id
           from nat_rec_pc nr
          where nr.cod = en_natrecpc_cod
            and nr.multorg_id = en_multorg_id;
      exception
         when others then
            vn_id := null;
      end;
      --
   end if;
   --
   return(vn_id);
   --
exception
   when others then
      return(null);
end fkg_codst_id_nat_rec_pc;

------------------------------------------------------------------------------------------------------
-- Função para retornar a situação da apuração de crédito para o imposto PIS
function fkg_sit_apur_pis ( en_apurcredpis_id in apur_cred_pis.id%type )
         return apur_cred_pis.dm_situacao%type
is
   --
   vn_dm_situacao apur_cred_pis.dm_situacao%type;
   --
begin
   --
   begin
      select ac.dm_situacao
        into vn_dm_situacao
        from apur_cred_pis ac
       where ac.id = en_apurcredpis_id;
   exception
      when others then
         vn_dm_situacao := null;
   end;
   --
   return(vn_dm_situacao);
   --
exception
   when others then
      return(null);
end fkg_sit_apur_pis;

------------------------------------------------------------------------------------------------------
-- Função para retornar a quantidade de registros relacionados ao período da apuração de crédito - PIS
function fkg_qtde_apur_pis ( en_perapurcredpis_id in per_apur_cred_pis.id%type )
         return number
is
   --
   vn_qtde number := 0;
   --
begin
   --
   begin
      select count(*)
        into vn_qtde
        from apur_cred_pis ac
       where ac.perapurcredpis_id = en_perapurcredpis_id;
   exception
      when others then
         vn_qtde := 0;
   end;
   --
   return(vn_qtde);
   --
exception
   when others then
      return(null);
end fkg_qtde_apur_pis;

------------------------------------------------------------------------------------------------------
-- Função para retornar a quantidade de registros relacionados a apuração de crédito - PIS
function fkg_qtde_det_apur_pis ( en_apurcredpis_id in apur_cred_pis.id%type )
         return number
is
   --
   vn_qtde number := 0;
   --
begin
   --
   begin
      select count(*)
        into vn_qtde
        from det_apur_cred_pis da
       where da.apurcredpis_id = en_apurcredpis_id;
   exception
      when others then
         vn_qtde := 0;
   end;
   --
   return(vn_qtde);
   --
exception
   when others then
      return(null);
end fkg_qtde_det_apur_pis;

---------------------------------------------------------------------------------------------------------
-- Função para retornar a quantidade de registros relacionados ao período da consolidação do imposto PIS
function fkg_qtde_cons_pis ( en_perconscontrpis_id in per_cons_contr_pis.id%type )
         return number
is
   --
   vn_qtde number := 0;
   --
begin
   --
   begin
      select count(*)
        into vn_qtde
        from cons_contr_pis cc
       where cc.perconscontrpis_id = en_perconscontrpis_id;
   exception
      when others then
         vn_qtde := 0;
   end;
   --
   return(vn_qtde);
   --
exception
   when others then
      return(null);
end fkg_qtde_cons_pis;

------------------------------------------------------------------------------------------------------
-- Função para retornar a quantidade de registros relacionados a consolidação do imposto PIS
function fkg_qtde_det_cons_pis ( en_conscontrpis_id in cons_contr_pis.id%type )
         return number
is
   --
   vn_qtde number := 0;
   --
begin
   --
   begin
      select count(*)
        into vn_qtde
        from det_cons_contr_pis dc
       where dc.conscontrpis_id = en_conscontrpis_id;
   exception
      when others then
         vn_qtde := 0;
   end;
   --
   return(vn_qtde);
   --
exception
   when others then
      return(null);
end fkg_qtde_det_cons_pis;

------------------------------------------------------------------------------------------------------
-- Função para retornar a quantidade de registros relacionados ao período das receitas isentas - PIS
function fkg_qtde_per_rec_pis ( en_perrecisentapis_id in per_rec_isenta_pis.id%type )
         return number
is
   --
   vn_qtde number := 0;
   --
begin
   --
   begin
      select count(*)
        into vn_qtde
        from rec_isenta_pis ri
       where ri.perrecisentapis_id = en_perrecisentapis_id;
   exception
      when others then
         vn_qtde := 0;
   end;
   --
   return(vn_qtde);
   --
exception
   when others then
      return(null);
end fkg_qtde_per_rec_pis;

------------------------------------------------------------------------------------------------------
-- Função para retornar a quantidade de registros relacionados a receitas isentas do imposto PIS
function fkg_qtde_det_rec_pis ( en_recisentapis_id in rec_isenta_pis.id%type )
         return number
is
   --
   vn_qtde number := 0;
   --
begin
   --
   begin
      select count(*)
        into vn_qtde
        from det_rec_isenta_pis dr
       where dr.recisentapis_id = en_recisentapis_id;
   exception
      when others then
         vn_qtde := 0;
   end;
   --
   return(vn_qtde);
   --
exception
   when others then
      return(null);
end fkg_qtde_det_rec_pis;

------------------------------------------------------------------------------------------------------
-- Função para retornar a situação da apuração de crédito para o impost COFINS
function fkg_sit_apur_cofins ( en_apurcredcofins_id in apur_cred_cofins.id%type )
         return apur_cred_cofins.dm_situacao%type
is
   --
   vn_dm_situacao apur_cred_cofins.dm_situacao%type;
   --
begin
   --
   begin
      select ac.dm_situacao
        into vn_dm_situacao
        from apur_cred_cofins ac
       where ac.id = en_apurcredcofins_id;
   exception
      when others then
         vn_dm_situacao := null;
   end;
   --
   return(vn_dm_situacao);
   --
exception
   when others then
      return(null);
end fkg_sit_apur_cofins;

----------------------------------------------------------------------------------------------------------
-- Função para retornar a quantidade de registros relacionados ao período da apuração de crédito - COFINS
function fkg_qtde_apur_cofins ( en_perapurcredcofins_id in per_apur_cred_cofins.id%type )
         return number
is
   --
   vn_qtde number := 0;
   --
begin
   --
   begin
      select count(*)
        into vn_qtde
        from apur_cred_cofins ac
       where ac.perapurcredcofins_id = en_perapurcredcofins_id;
   exception
      when others then
         vn_qtde := 0;
   end;
   --
   return(vn_qtde);
   --
exception
   when others then
      return(null);
end fkg_qtde_apur_cofins;

------------------------------------------------------------------------------------------------------
-- Função para retornar a quantidade de registros relacionados a apuração de crédito - COFINS
function fkg_qtde_det_apur_cofins ( en_apurcredcofins_id in apur_cred_cofins.id%type )
         return number
is
   --
   vn_qtde number := 0;
   --
begin
   --
   begin
      select count(*)
        into vn_qtde
        from det_apur_cred_cofins da
       where da.apurcredcofins_id = en_apurcredcofins_id;
   exception
      when others then
         vn_qtde := 0;
   end;
   --
   return(vn_qtde);
   --
exception
   when others then
      return(null);
end fkg_qtde_det_apur_cofins;

------------------------------------------------------------------------------------------------------------
-- Função para retornar a quantidade de registros relacionados ao período de consolidação do imposto COFINS
function fkg_qtde_cons_cofins ( en_perconscontrcofins_id in per_cons_contr_cofins.id%type )
         return number
is
   --
   vn_qtde number := 0;
   --
begin
   --
   begin
      select count(*)
        into vn_qtde
        from cons_contr_cofins cc
       where cc.perconscontrcofins_id = en_perconscontrcofins_id;
   exception
      when others then
         vn_qtde := 0;
   end;
   --
   return(vn_qtde);
   --
exception
   when others then
      return(null);
end fkg_qtde_cons_cofins;

------------------------------------------------------------------------------------------------------
-- Função para retornar a quantidade de registros relacionados a consolidação do imposto COFINS
function fkg_qtde_det_cons_cofins ( en_conscontrcofins_id in cons_contr_cofins.id%type )
         return number
is
   --
   vn_qtde number := 0;
   --
begin
   --
   begin
      select count(*)
        into vn_qtde
        from det_cons_contr_cofins dc
       where dc.conscontrcofins_id = en_conscontrcofins_id;
   exception
      when others then
         vn_qtde := 0;
   end;
   --
   return(vn_qtde);
   --
exception
   when others then
      return(null);
end fkg_qtde_det_cons_cofins;

------------------------------------------------------------------------------------------------------
-- Função para retornar a quantidade de registros relacionados ao período das receitas isentas - COFINS
function fkg_qtde_per_rec_cofins ( en_perrecisentacofins_id in per_rec_isenta_cofins.id%type )
         return number
is
   --
   vn_qtde number := 0;
   --
begin
   --
   begin
      select count(*)
        into vn_qtde
        from rec_isenta_cofins ri
       where ri.perrecisentacofins_id = en_perrecisentacofins_id;
   exception
      when others then
         vn_qtde := 0;
   end;
   --
   return(vn_qtde);
   --
exception
   when others then
      return(null);
end fkg_qtde_per_rec_cofins;

------------------------------------------------------------------------------------------------------
-- Função para retornar a quantidade de registros relacionados a receitas isentas do imposto COFINS
function fkg_qtde_det_rec_cofins ( en_recisentacofins_id in rec_isenta_cofins.id%type )
         return number
is
   --
   vn_qtde number := 0;
   --
begin
   --
   begin
      select count(*)
        into vn_qtde
        from det_rec_isenta_cofins dr
       where dr.recisentacofins_id = en_recisentacofins_id;
   exception
      when others then
         vn_qtde := 0;
   end;
   --
   return(vn_qtde);
   --
exception
   when others then
      return(null);
end fkg_qtde_det_rec_cofins;

-------------------------------------------------------------------------------------------------------
-- Função retorna o CD da tabela Orig_Proc
function fkg_cd_orig_proc ( en_origproc_id  in orig_proc.id%type )
         return orig_proc.cd%type
is
   --
   vn_cd  orig_proc.cd%type;
   --
begin
   --
   begin
      select op.cd
        into vn_cd
        from orig_proc op
       where op.id = en_origproc_id;
   exception
      when others then
         vn_cd := 0;
   end;
   --
   return vn_cd;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_cd_orig_proc:' || sqlerrm);
end fkg_cd_orig_proc;

-------------------------------------------------------------------------------------------------------
-- Função confirma o ID da tabela Plano de Conta
function fkg_id_plano_conta_id ( en_id in plano_conta.id%type )
         return plano_conta.id%type
is
   --
   vn_planoconta_id plano_conta.id%type;
   --
begin
   --
   begin
      select pc.id
        into vn_planoconta_id
        from plano_conta pc
       where pc.id = en_id;
   exception
      when others then
         vn_planoconta_id := 0;
   end;
   --
   return vn_planoconta_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_id_plano_conta_id:' || sqlerrm);
end fkg_id_plano_conta_id;

-------------------------------------------------------------------------------------------------------
-- Função confirma o ID da tabela Centro de Custo
function fkg_id_centro_custo_id ( en_id in centro_custo.id%type )
         return centro_custo.id%type
is
   --
   vn_centrocusto_id centro_custo.id%type;
   --
begin
   --
   begin
      select cc.id
        into vn_centrocusto_id
        from centro_custo cc
       where cc.id = en_id;
   exception
      when others then
         vn_centrocusto_id := 0;
   end;
   --
   return vn_centrocusto_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_id_centro_custo_id:' || sqlerrm);
end fkg_id_centro_custo_id;

--------------------------------------------------------------------------------------
-- Procedimento para gravar o log/alteração das notas fiscais de serviços contínuos --
--------------------------------------------------------------------------------------
procedure pkb_inclui_log_nf_serv_cont( en_notafiscal_id in nota_fiscal.id%type
                                     , ev_resumo        in log_nf_serv_cont.resumo%type
                                     , ev_mensagem      in log_nf_serv_cont.mensagem%type
                                     , en_usuario_id    in neo_usuario.id%type
                                     , ev_maquina       in varchar2 ) is
   --
   pragma   autonomous_transaction;
   --
begin
   --
   insert into log_nf_serv_cont( id
                               , notafiscal_id
                               , dt_hr_log
                               , resumo
                               , mensagem
                               , usuario_id
                               , maquina )
                         values( lognfservcont_seq.nextval
                               , en_notafiscal_id
                               , sysdate
                               , ev_resumo
                               , ev_mensagem
                               , en_usuario_id
                               , ev_maquina );
   --
   commit;
   --
exception
   when others then
      raise_application_error (-20101, 'Problemas ao incluir log/alteração - pkb_inclui_log_nf_serv_cont (notafiscal_id = '||en_notafiscal_id||
                                       '). Erro = '||sqlerrm);
end pkb_inclui_log_nf_serv_cont;

-------------------------------------------------------------------------------------------------------
-- Função verifica se o CFOP gera receita isenta para a empresa
-- O sistema busca na empresa, seja filial, ou busca na matriz -> 0-não, 1-sim -> valor default 1-sim
function fkg_gera_recisen_cfop_empr ( en_empresa_id      in param_cfop_empresa.empresa_id%type
                                    , en_cfop_id         in param_cfop_empresa.cfop_id%type
                                    , en_codst_id_pis    in param_cfop_empr_cst.codst_id_pis%type    default null
                                    , en_codst_id_cofins in param_cfop_empr_cst.codst_id_cofins%type default null
                                    )
         return param_cfop_empresa.dm_gera_receita%type
is
   --
   vn_fase              number := 0;
   vn_dm_gera_receita   param_cfop_empresa.dm_gera_receita%type;
   vn_empresa_id_matriz empresa.id%type;
   --
begin
   --
   vn_fase := 1;
   -- Busca na empresa informada com parametrização de PIS e COFINS
   if nvl(en_codst_id_pis,0) > 0 and
      nvl(en_codst_id_cofins,0) > 0 then
      --
      begin
         select pc.dm_gera_receita
           into vn_dm_gera_receita
           from param_cfop_empresa  pc
              , param_cfop_empr_cst pe
          where pc.empresa_id          = en_empresa_id
            and pc.cfop_id             = en_cfop_id
            and pe.paramcfopempresa_id = pc.id
            and pe.codst_id_pis        = en_codst_id_pis
            and pe.codst_id_cofins     = en_codst_id_cofins;
      exception
         when others then
            vn_dm_gera_receita := null;
      end;
      --
   end if;
   --
   vn_fase := 1.1;
   -- Busca na empresa informada com parametrização de PIS
   if vn_dm_gera_receita is null and
      nvl(en_codst_id_pis,0) > 0 then
      --
      begin
         select pc.dm_gera_receita
           into vn_dm_gera_receita
           from param_cfop_empresa  pc
              , param_cfop_empr_cst pe
          where pc.empresa_id          = en_empresa_id
            and pc.cfop_id             = en_cfop_id
            and pe.paramcfopempresa_id = pc.id
            and pe.codst_id_pis        = en_codst_id_pis;
      exception
         when others then
            vn_dm_gera_receita := null;
      end;
      --
   end if;
   --
   vn_fase := 1.2;
   -- Busca na empresa informada com parametrização de COFINS
   if vn_dm_gera_receita is null and
      nvl(en_codst_id_cofins,0) > 0 then
      --
      begin
         select pc.dm_gera_receita
           into vn_dm_gera_receita
           from param_cfop_empresa  pc
              , param_cfop_empr_cst pe
          where pc.empresa_id          = en_empresa_id
            and pc.cfop_id             = en_cfop_id
            and pe.paramcfopempresa_id = pc.id
            and pe.codst_id_cofins     = en_codst_id_cofins;
      exception
         when others then
            vn_dm_gera_receita := null;
      end;
      --
   end if;
   --
   vn_fase := 1.3;
   -- Se não encontrou, busca na empresa informada sem parametrização de PIS / COFINS
   if vn_dm_gera_receita is null then
      --
      begin
         select pc.dm_gera_receita
           into vn_dm_gera_receita
           from param_cfop_empresa pc
          where pc.empresa_id = en_empresa_id
            and pc.cfop_id    = en_cfop_id
            and not exists (select 1 from param_cfop_empr_cst pe where pe.paramcfopempresa_id = pc.id);
      exception
         when others then
            vn_dm_gera_receita := null;
      end;
      --
   end if;
   --
   vn_fase := 2;
   -- Se não encontrou pela Empresa, busca pela Matriz da Empresa
   if vn_dm_gera_receita is null then
      --
      vn_fase := 3;
      -- Busca a empresa matriz para novas consultas
      vn_empresa_id_matriz := pk_csf.fkg_empresa_id_matriz ( en_empresa_id );
      --
      vn_fase := 4;
      --
      if nvl(vn_empresa_id_matriz,0) = nvl(en_empresa_id,0) then
         -- Não é necessário fazer a busca pois as empresas são iguais.
         vn_dm_gera_receita := 0; -- valor default 0-não
         --
      else
         --
         vn_fase := 5;
         -- Busca na empresa matriz com parametrização de PIS e COFINS
         if nvl(en_codst_id_pis,0) > 0 and
            nvl(en_codst_id_cofins,0) > 0 then
            --
            begin
               select pc.dm_gera_receita
                 into vn_dm_gera_receita
                 from param_cfop_empresa  pc
                    , param_cfop_empr_cst pe
                where pc.empresa_id          = vn_empresa_id_matriz
                  and pc.cfop_id             = en_cfop_id
                  and pe.paramcfopempresa_id = pc.id
                  and pe.codst_id_pis        = en_codst_id_pis
                  and pe.codst_id_cofins     = en_codst_id_cofins;
            exception
               when others then
                  vn_dm_gera_receita := null;
            end;
            --
         end if;
         --
         vn_fase := 5.1;
         -- Busca na empresa matriz com parametrização de PIS
         if vn_dm_gera_receita is null and
            nvl(en_codst_id_pis,0) > 0 then
            --
            begin
               select pc.dm_gera_receita
                 into vn_dm_gera_receita
                 from param_cfop_empresa  pc
                    , param_cfop_empr_cst pe
                where pc.empresa_id          = vn_empresa_id_matriz
                  and pc.cfop_id             = en_cfop_id
                  and pe.paramcfopempresa_id = pc.id
                  and pe.codst_id_pis        = en_codst_id_pis;
            exception
               when others then
                  vn_dm_gera_receita := null;
            end;
            --
         end if;
         --
         vn_fase := 5.2;
         -- Busca na empresa matriz com parametrização de COFINS
         if vn_dm_gera_receita is null and
            nvl(en_codst_id_cofins,0) > 0 then
            --
            begin
               select pc.dm_gera_receita
                 into vn_dm_gera_receita
                 from param_cfop_empresa  pc
                    , param_cfop_empr_cst pe
                where pc.empresa_id          = vn_empresa_id_matriz
                  and pc.cfop_id             = en_cfop_id
                  and pe.paramcfopempresa_id = pc.id
                  and pe.codst_id_cofins     = en_codst_id_cofins;
            exception
               when others then
                  vn_dm_gera_receita := null;
            end;
            --
         end if;
         --
         vn_fase := 5.3;
         --
         if vn_dm_gera_receita is null then
            -- Se não encontrou, busca a matriz informada sem parametrização de PIS / COFINS
            begin
               select pc.dm_gera_receita
                 into vn_dm_gera_receita
                 from param_cfop_empresa pc
                where pc.empresa_id = vn_empresa_id_matriz
                  and pc.cfop_id    = en_cfop_id
                  and not exists (select 1 from param_cfop_empr_cst pe where pe.paramcfopempresa_id = pc.id);
            exception
               when others then
                  vn_dm_gera_receita := 0; -- valor default 0-não
            end;
            --
         end if;
         --
      end if; -- nvl(vn_empresa_id_matriz,0) = nvl(en_empresa_id,0) then
      --
   end if;
   --
   return vn_dm_gera_receita;
   --
EXCEPTION
   when others then
      raise_application_error(-20101, 'Problemas em fkg_gera_recisen_cfop_empr, fase '||vn_fase||'. Erro = '||sqlerrm);
end fkg_gera_recisen_cfop_empr;

-------------------------------------------------------------------------------------------------------
-- Função verifica se o CFOP gerou crédito de pis/cofins para nota fiscal de entrada de pessoa física e não deveria
-- O sistema busca na empresa, seja filial, ou busca na matriz -> 0-não, 1-sim -> valor default 0-não
function fkg_gera_cred_nfpc_cfop_empr ( en_empresa_id      in param_cfop_empresa.empresa_id%type
                                      , en_cfop_id         in param_cfop_empresa.cfop_id%type
                                      , en_codst_id_pis    in param_cfop_empr_cst.codst_id_pis%type    default null
                                      , en_codst_id_cofins in param_cfop_empr_cst.codst_id_cofins%type default null
                                      )
         return param_cfop_empresa.dm_gera_cred_pf_pc%type
is
   --
   vn_fase               number := 0;
   vn_dm_gera_cred_pf_pc param_cfop_empresa.dm_gera_cred_pf_pc%type;
   vn_empresa_id_matriz  empresa.id%type;
   --
begin
   --
   vn_fase := 1;
   -- Busca na empresa informada com parametrização de PIS e COFINS
   if nvl(en_codst_id_pis,0) > 0 and
      nvl(en_codst_id_cofins,0) > 0 then
      --
      begin
         select pc.dm_gera_cred_pf_pc
           into vn_dm_gera_cred_pf_pc
           from param_cfop_empresa  pc
              , param_cfop_empr_cst pe
          where pc.empresa_id          = en_empresa_id
            and pc.cfop_id             = en_cfop_id
            and pe.paramcfopempresa_id = pc.id
            and pe.codst_id_pis        = en_codst_id_pis
            and pe.codst_id_cofins     = en_codst_id_cofins;
      exception
         when others then
            vn_dm_gera_cred_pf_pc := null;
      end;
      --
   end if;
   --
   vn_fase := 1.1;
   -- Busca na empresa informada com parametrização de PIS
   if vn_dm_gera_cred_pf_pc is null and
      nvl(en_codst_id_pis,0) > 0 then
      --
      begin
         select pc.dm_gera_cred_pf_pc
           into vn_dm_gera_cred_pf_pc
           from param_cfop_empresa  pc
              , param_cfop_empr_cst pe
          where pc.empresa_id          = en_empresa_id
            and pc.cfop_id             = en_cfop_id
            and pe.paramcfopempresa_id = pc.id
            and pe.codst_id_pis        = en_codst_id_pis;
      exception
         when others then
            vn_dm_gera_cred_pf_pc := null;
      end;
      --
   end if;
   --
   vn_fase := 1.2;
   -- Busca na empresa informada com parametrização de COFINS
   if vn_dm_gera_cred_pf_pc is null and
      nvl(en_codst_id_cofins,0) > 0 then
      --
      begin
         select pc.dm_gera_cred_pf_pc
           into vn_dm_gera_cred_pf_pc
           from param_cfop_empresa  pc
              , param_cfop_empr_cst pe
          where pc.empresa_id          = en_empresa_id
            and pc.cfop_id             = en_cfop_id
            and pe.paramcfopempresa_id = pc.id
            and pe.codst_id_cofins     = en_codst_id_cofins;
      exception
         when others then
            vn_dm_gera_cred_pf_pc := null;
      end;
      --
   end if;
   --
   vn_fase := 1.3;
   -- Se não encontrou, busca na empresa informada sem parametrização de PIS / COFINS
   if vn_dm_gera_cred_pf_pc is null then
      --
      begin
         select pc.dm_gera_cred_pf_pc
           into vn_dm_gera_cred_pf_pc
           from param_cfop_empresa pc
          where pc.empresa_id = en_empresa_id
            and pc.cfop_id    = en_cfop_id
            and not exists (select 1 from param_cfop_empr_cst pe where pe.paramcfopempresa_id = pc.id);
      exception
         when others then
            vn_dm_gera_cred_pf_pc := null;
      end;
      --
   end if;
   --
   vn_fase := 2;
   -- Se não encontrou pela Empresa, busca pela Matriz da Empresa
   if vn_dm_gera_cred_pf_pc is null then
      --
      vn_fase := 3;
      -- Busca a empresa matriz para novas consultas
      vn_empresa_id_matriz := pk_csf.fkg_empresa_id_matriz ( en_empresa_id );
      --
      vn_fase := 4;
      --
      if nvl(vn_empresa_id_matriz,0) = nvl(en_empresa_id,0) then
         -- Não é necessário fazer a busca pois as empresas são iguais.
         vn_dm_gera_cred_pf_pc := 0; -- valor default 0-não
         --
      else
         --
         vn_fase := 5;
         -- Busca na empresa matriz com parametrização de PIS e COFINS
         if nvl(en_codst_id_pis,0) > 0 and
            nvl(en_codst_id_cofins,0) > 0 then
            --
            begin
               select pc.dm_gera_cred_pf_pc
                 into vn_dm_gera_cred_pf_pc
                 from param_cfop_empresa  pc
                    , param_cfop_empr_cst pe
                where pc.empresa_id          = vn_empresa_id_matriz
                  and pc.cfop_id             = en_cfop_id
                  and pe.paramcfopempresa_id = pc.id
                  and pe.codst_id_pis        = en_codst_id_pis
                  and pe.codst_id_cofins     = en_codst_id_cofins;
            exception
               when others then
                  vn_dm_gera_cred_pf_pc := null;
            end;
            --
         end if;
         --
         vn_fase := 5.1;
         -- Busca na empresa matriz com parametrização de PIS
         if vn_dm_gera_cred_pf_pc is null and
            nvl(en_codst_id_pis,0) > 0 then
            --
            begin
               select pc.dm_gera_cred_pf_pc
                 into vn_dm_gera_cred_pf_pc
                 from param_cfop_empresa  pc
                    , param_cfop_empr_cst pe
                where pc.empresa_id          = vn_empresa_id_matriz
                  and pc.cfop_id             = en_cfop_id
                  and pe.paramcfopempresa_id = pc.id
                  and pe.codst_id_pis        = en_codst_id_pis;
            exception
               when others then
                  vn_dm_gera_cred_pf_pc := null;
            end;
            --
         end if;
         --
         vn_fase := 5.2;
         -- Busca na empresa matriz com parametrização de COFINS
         if vn_dm_gera_cred_pf_pc is null and
            nvl(en_codst_id_cofins,0) > 0 then
            --
            begin
               select pc.dm_gera_cred_pf_pc
                 into vn_dm_gera_cred_pf_pc
                 from param_cfop_empresa  pc
                    , param_cfop_empr_cst pe
                where pc.empresa_id          = vn_empresa_id_matriz
                  and pc.cfop_id             = en_cfop_id
                  and pe.paramcfopempresa_id = pc.id
                  and pe.codst_id_cofins     = en_codst_id_cofins;
            exception
               when others then
                  vn_dm_gera_cred_pf_pc := null;
            end;
            --
         end if;
         --
         vn_fase := 5.3;
         --
         if vn_dm_gera_cred_pf_pc is null then
            -- Se não encontrou, busca a matriz informada sem parametrização de PIS / COFINS
            begin
               select pc.dm_gera_cred_pf_pc
                 into vn_dm_gera_cred_pf_pc
                 from param_cfop_empresa pc
                where pc.empresa_id = vn_empresa_id_matriz
                  and pc.cfop_id    = en_cfop_id
                  and not exists (select 1 from param_cfop_empr_cst pe where pe.paramcfopempresa_id = pc.id);
            exception
               when others then
                  vn_dm_gera_cred_pf_pc := 0; -- valor default 0-não
            end;
            --
         end if;
         --
      end if; -- nvl(vn_empresa_id_matriz,0) = nvl(en_empresa_id,0) then
      --
   end if;
   --
   return vn_dm_gera_cred_pf_pc;
   --
exception
   when others then
      raise_application_error(-20101, 'Problemas em fkg_gera_cred_nfpc_cfop_empr, fase '||vn_fase||'. Erro = '||sqlerrm);
end fkg_gera_cred_nfpc_cfop_empr;

-------------------------------------------------------------------------------------------------------
-- Função verifica se o CFOP gera escrituração fiscal - geração do arquivo texto de pis/cofins
-- O sistema busca na empresa, seja filial, ou busca na matriz -> 0-não, 1-sim -> valor default 1-sim
-- se existir pis ou cofins na tabela param_cfop_empr_cst corresponde a exceção para geração 
function fkg_gera_escr_efdpc_cfop_empr ( en_empresa_id      in param_cfop_empresa.empresa_id%type
                                       , en_cfop_id         in param_cfop_empresa.cfop_id%type
                                       , en_codst_id_pis    in param_cfop_empr_cst.codst_id_pis%type    default null
                                       , en_codst_id_cofins in param_cfop_empr_cst.codst_id_cofins%type default null
                                       )
         return param_cfop_empresa.dm_gera_escr_efd_pc%type
is
   --
   vn_fase                number := 0;
   vn_dm_gera_escr_efd_pc param_cfop_empresa.dm_gera_escr_efd_pc%type;
   vn_empresa_id_matriz   empresa.id%type;
   --
begin
   --
   vn_fase := 1;
   -- Busca na empresa informada com parametrização de PIS e COFINS
   if nvl(en_codst_id_pis,0) > 0 and
      nvl(en_codst_id_cofins,0) > 0 then
      --
      begin
         select pc.dm_gera_escr_efd_pc
           into vn_dm_gera_escr_efd_pc
           from param_cfop_empresa  pc
              , param_cfop_empr_cst pe
          where pc.empresa_id          = en_empresa_id
            and pc.cfop_id             = en_cfop_id
            and pe.paramcfopempresa_id = pc.id
            and pe.codst_id_pis        = en_codst_id_pis
            and pe.codst_id_cofins     = en_codst_id_cofins;
      exception
         when others then
            vn_dm_gera_escr_efd_pc := null;
      end;
      --
   end if;
   --
   vn_fase := 1.1;
   -- Busca na empresa informada com parametrização de PIS
   if vn_dm_gera_escr_efd_pc is null and
      nvl(en_codst_id_pis,0) > 0 then
      --
      begin
         select pc.dm_gera_escr_efd_pc
           into vn_dm_gera_escr_efd_pc
           from param_cfop_empresa  pc
              , param_cfop_empr_cst pe
          where pc.empresa_id          = en_empresa_id
            and pc.cfop_id             = en_cfop_id
            and pe.paramcfopempresa_id = pc.id
            and pe.codst_id_pis        = en_codst_id_pis;
      exception
         when others then
            vn_dm_gera_escr_efd_pc := null;
      end;
      --
   end if;
   --
   vn_fase := 1.2;
   -- Busca na empresa informada com parametrização de COFINS
   if vn_dm_gera_escr_efd_pc is null and
      nvl(en_codst_id_cofins,0) > 0 then
      --
      begin
         select pc.dm_gera_escr_efd_pc
           into vn_dm_gera_escr_efd_pc
           from param_cfop_empresa  pc
              , param_cfop_empr_cst pe
          where pc.empresa_id          = en_empresa_id
            and pc.cfop_id             = en_cfop_id
            and pe.paramcfopempresa_id = pc.id
            and pe.codst_id_cofins     = en_codst_id_cofins;
      exception
         when others then
            vn_dm_gera_escr_efd_pc := null;
      end;
      --
   end if;
   --
   vn_fase := 1.3;
   -- Se não encontrou, busca na empresa informada sem parametrização de PIS / COFINS
   if vn_dm_gera_escr_efd_pc is null then
      --
      begin
         select pc.dm_gera_escr_efd_pc
           into vn_dm_gera_escr_efd_pc
           from param_cfop_empresa pc
          where pc.empresa_id = en_empresa_id
            and pc.cfop_id    = en_cfop_id
            and not exists (select 1 from param_cfop_empr_cst pe where pe.paramcfopempresa_id = pc.id);
      exception
         when others then
            vn_dm_gera_escr_efd_pc := null;
      end;
      --
   end if;
   --
   vn_fase := 2;
   -- Se não encontrou pela Empresa, busca pela Matriz da Empresa
   if vn_dm_gera_escr_efd_pc is null then
      --
      vn_fase := 3;
      -- Busca a empresa matriz para novas consultas
      vn_empresa_id_matriz := pk_csf.fkg_empresa_id_matriz ( en_empresa_id );
      --
      vn_fase := 4;
      --
      if nvl(vn_empresa_id_matriz,0) = nvl(en_empresa_id,0) then
         -- Não é necessário fazer a busca pois as empresas são iguais.
         vn_dm_gera_escr_efd_pc := 1; -- valor default 1-sim
         --
      else
         --
         vn_fase := 5;
         -- Busca na empresa matriz com parametrização de PIS e COFINS
         if nvl(en_codst_id_pis,0) > 0 and
            nvl(en_codst_id_cofins,0) > 0 then
            --
            begin
               select pc.dm_gera_escr_efd_pc
                 into vn_dm_gera_escr_efd_pc
                 from param_cfop_empresa  pc
                    , param_cfop_empr_cst pe
                where pc.empresa_id          = vn_empresa_id_matriz
                  and pc.cfop_id             = en_cfop_id
                  and pe.paramcfopempresa_id = pc.id
                  and pe.codst_id_pis        = en_codst_id_pis
                  and pe.codst_id_cofins     = en_codst_id_cofins;
            exception
               when others then
                  vn_dm_gera_escr_efd_pc := null;
            end;
            --
         end if;
         --
         vn_fase := 5.1;
         -- Busca na empresa matriz com parametrização de PIS
         if vn_dm_gera_escr_efd_pc is null and
            nvl(en_codst_id_pis,0) > 0 then
            --
            begin
               select pc.dm_gera_escr_efd_pc
                 into vn_dm_gera_escr_efd_pc
                 from param_cfop_empresa  pc
                    , param_cfop_empr_cst pe
                where pc.empresa_id          = vn_empresa_id_matriz
                  and pc.cfop_id             = en_cfop_id
                  and pe.paramcfopempresa_id = pc.id
                  and pe.codst_id_pis        = en_codst_id_pis;
            exception
               when others then
                  vn_dm_gera_escr_efd_pc := null;
            end;
            --
         end if;
         --
         vn_fase := 5.2;
         -- Busca na empresa matriz com parametrização de COFINS
         if vn_dm_gera_escr_efd_pc is null and
            nvl(en_codst_id_cofins,0) > 0 then
            --
            begin
               select pc.dm_gera_escr_efd_pc
                 into vn_dm_gera_escr_efd_pc
                 from param_cfop_empresa  pc
                    , param_cfop_empr_cst pe
                where pc.empresa_id          = vn_empresa_id_matriz
                  and pc.cfop_id             = en_cfop_id
                  and pe.paramcfopempresa_id = pc.id
                  and pe.codst_id_cofins     = en_codst_id_cofins;
            exception
               when others then
                  vn_dm_gera_escr_efd_pc := null;
            end;
            --
         end if;
         --
         vn_fase := 5.3;
         --
         if vn_dm_gera_escr_efd_pc is null then
            -- Se não encontrou, busca a matriz informada sem parametrização de PIS / COFINS
            begin
               select pc.dm_gera_escr_efd_pc
                 into vn_dm_gera_escr_efd_pc
                 from param_cfop_empresa pc
                where pc.empresa_id = vn_empresa_id_matriz
                  and pc.cfop_id    = en_cfop_id
                  and not exists (select 1 from param_cfop_empr_cst pe where pe.paramcfopempresa_id = pc.id);
            exception
               when others then
                  vn_dm_gera_escr_efd_pc := 1; -- valor default 0-não
            end;
            --
         end if;
         --
      end if; -- nvl(vn_empresa_id_matriz,0) = nvl(en_empresa_id,0) then
      --
   end if;
   --
   return vn_dm_gera_escr_efd_pc;
   --
exception
   when others then
      raise_application_error(-20101, 'Problemas em fkg_gera_escr_efdpc_cfop_empr, fase '||vn_fase||'. Erro = '||sqlerrm);
end fkg_gera_escr_efdpc_cfop_empr;

-------------------------------------------------------------------------------------------------------
-- Função retorna id da tabela REGISTRO_DACON conforme o código.
function fkg_registrodacon_id ( ev_cod  in  registro_dacon.cd%type )
         return registro_dacon.id%type
is
   --
   vn_registrodacon_id registro_dacon.id%type := null;
   --
begin
   --
   select id
     into vn_registrodacon_id
     from registro_dacon
    where cd = ev_cod;
   --
   return vn_registrodacon_id;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error (-20101, 'Erro na pk_csf_efd_pc.fkg_registrodacon_id: ' || sqlerrm );
end fkg_registrodacon_id;

-------------------------------------------------------------------------------------------------------
-- Função retorna código da tabela REGISTRO_DACON conforme o id.
function fkg_registrodacon_cd ( en_registrodacon_id  in  registro_dacon.id%type )
         return registro_dacon.cd%type
is
   --
   vv_registrodacon_cd registro_dacon.cd%type := null;
   --
begin
   --
   select cd
     into vv_registrodacon_cd
     from registro_dacon
    where id = en_registrodacon_id;
   --
   return vv_registrodacon_cd;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error (-20101, 'Erro na pk_csf_efd_pc.fkg_registrodacon_cd: ' || sqlerrm );
end fkg_registrodacon_cd;

-------------------------------------------------------------------------------------------------------
-- Função retorna id da tabela PROD_DACON conforme o código e o dm_tabela.
function fkg_proddacon_id ( ev_cod        in  prod_dacon.cd%type
                          , ev_dm_tabela  in  prod_dacon.dm_tabela%type
                          )
         return prod_dacon.id%type
is
   --
   vn_proddacon_id prod_dacon.id%type := null;
   --
begin
   --
   select id
     into vn_proddacon_id
     from prod_dacon
    where cd = ev_cod
      and dm_tabela = ev_dm_tabela;
   --
   return vn_proddacon_id;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error (-20101, 'Erro na pk_csf_efd_pc.fkg_proddacon_id: ' || sqlerrm );
end fkg_proddacon_id;

-------------------------------------------------------------------------------------------------------
-- Função retorna código da tabela PROD_DACON conforme o id.
function fkg_proddacon_cd ( en_proddacon_id  in  prod_dacon.id%type )
         return prod_dacon.cd%type
is
   --
   vv_proddacon_cd prod_dacon.cd%type := null;
   --
begin
   --
   select cd
     into vv_proddacon_cd
     from prod_dacon
    where id = en_proddacon_id;
   --
   return vv_proddacon_cd;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error (-20101, 'Erro na pk_csf_efd_pc.fkg_proddacon_cd: ' || sqlerrm );
end fkg_proddacon_cd;

-------------------------------------------------------------------------------------------------------
-- Função para retornar se o CFOP gera valor como ajuste na consolidação para PIS e COFINS (0-não, 1-sim)
function fkg_dmgeraajusm210_parcfopempr ( en_empresa_id      in empresa.id%type
                                        , en_cfop_id         in cfop.id%type
                                        , en_codst_id_pis    in param_cfop_empr_cst.codst_id_pis%type    default null
                                        , en_codst_id_cofins in param_cfop_empr_cst.codst_id_cofins%type default null
                                         )
         return param_cfop_empresa.dm_gera_ajuste_contr%type
is
   --
   vn_fase                 number := 0;
   vn_dm_gera_ajuste_contr param_cfop_empresa.dm_gera_ajuste_contr%type;
   vn_empresa_id_matriz    empresa.id%type;
   --
begin
   --
   vn_fase := 1;
   -- Busca na empresa informada com parametrização de PIS e COFINS
   if nvl(en_codst_id_pis,0) > 0 and
      nvl(en_codst_id_cofins,0) > 0 then
      --
      begin
         select pc.dm_gera_ajuste_contr
           into vn_dm_gera_ajuste_contr
           from param_cfop_empresa  pc
              , param_cfop_empr_cst pe
          where pc.empresa_id          = en_empresa_id
            and pc.cfop_id             = en_cfop_id
            and pe.paramcfopempresa_id = pc.id
            and pe.codst_id_pis        = en_codst_id_pis
            and pe.codst_id_cofins     = en_codst_id_cofins;
      exception
         when others then
            vn_dm_gera_ajuste_contr := null;
      end;
      --
   end if;
   --
   vn_fase := 1.1;
   -- Busca na empresa informada com parametrização de PIS
   if vn_dm_gera_ajuste_contr is null and
      nvl(en_codst_id_pis,0) > 0 then
      --
      begin
         select pc.dm_gera_ajuste_contr
           into vn_dm_gera_ajuste_contr
           from param_cfop_empresa  pc
              , param_cfop_empr_cst pe
          where pc.empresa_id          = en_empresa_id
            and pc.cfop_id             = en_cfop_id
            and pe.paramcfopempresa_id = pc.id
            and pe.codst_id_pis        = en_codst_id_pis;
      exception
         when others then
            vn_dm_gera_ajuste_contr := null;
      end;
      --
   end if;
   --
   vn_fase := 1.2;
   -- Busca na empresa informada com parametrização de COFINS
   if vn_dm_gera_ajuste_contr is null and
      nvl(en_codst_id_cofins,0) > 0 then
      --
      begin
         select pc.dm_gera_ajuste_contr
           into vn_dm_gera_ajuste_contr
           from param_cfop_empresa  pc
              , param_cfop_empr_cst pe
          where pc.empresa_id          = en_empresa_id
            and pc.cfop_id             = en_cfop_id
            and pe.paramcfopempresa_id = pc.id
            and pe.codst_id_cofins     = en_codst_id_cofins;
      exception
         when others then
            vn_dm_gera_ajuste_contr := null;
      end;
      --
   end if;
   --
   vn_fase := 1.3;
   -- Se não encontrou, busca na empresa informada sem parametrização de PIS / COFINS
   if vn_dm_gera_ajuste_contr is null then
      --
      begin
         select pc.dm_gera_ajuste_contr
           into vn_dm_gera_ajuste_contr
           from param_cfop_empresa pc
          where pc.empresa_id = en_empresa_id
            and pc.cfop_id    = en_cfop_id
            and not exists (select 1 from param_cfop_empr_cst pe where pe.paramcfopempresa_id = pc.id);
      exception
         when others then
            vn_dm_gera_ajuste_contr := null;
      end;
      --
   end if;
   --
   vn_fase := 2;
   -- Se não encontrou pela Empresa, busca pela Matriz da Empresa
   if vn_dm_gera_ajuste_contr is null then
      --
      vn_fase := 3;
      -- Busca a empresa matriz para novas consultas
      vn_empresa_id_matriz := pk_csf.fkg_empresa_id_matriz ( en_empresa_id );
      --
      vn_fase := 4;
      --
      if nvl(vn_empresa_id_matriz,0) = nvl(en_empresa_id,0) then
         -- Não é necessário fazer a busca pois as empresas são iguais.
         vn_dm_gera_ajuste_contr := 0; -- valor default 0-não
         --
      else
         --
         vn_fase := 5;
         -- Busca na empresa matriz com parametrização de PIS e COFINS
         if nvl(en_codst_id_pis,0) > 0 and
            nvl(en_codst_id_cofins,0) > 0 then
            --
            begin
               select pc.dm_gera_ajuste_contr
                 into vn_dm_gera_ajuste_contr
                 from param_cfop_empresa  pc
                    , param_cfop_empr_cst pe
                where pc.empresa_id          = vn_empresa_id_matriz
                  and pc.cfop_id             = en_cfop_id
                  and pe.paramcfopempresa_id = pc.id
                  and pe.codst_id_pis        = en_codst_id_pis;
            exception
               when others then
                  vn_dm_gera_ajuste_contr := null;
            end;
            --
         end if;
         --
         vn_fase := 5.1;
         -- Busca na empresa matriz com parametrização de PIS
         if vn_dm_gera_ajuste_contr is null and
            nvl(en_codst_id_pis,0) > 0 then
            --
            begin
               select pc.dm_gera_ajuste_contr
                 into vn_dm_gera_ajuste_contr
                 from param_cfop_empresa  pc
                    , param_cfop_empr_cst pe
                where pc.empresa_id          = vn_empresa_id_matriz
                  and pc.cfop_id             = en_cfop_id
                  and pe.paramcfopempresa_id = pc.id
                  and pe.codst_id_pis        = en_codst_id_pis;
            exception
               when others then
                  vn_dm_gera_ajuste_contr := null;
            end;
            --
         end if;
         --
         vn_fase := 5.2;
         -- Busca na empresa matriz com parametrização de COFINS
         if vn_dm_gera_ajuste_contr is null and
            nvl(en_codst_id_cofins,0) > 0 then
            --
            begin
               select pc.dm_gera_ajuste_contr
                 into vn_dm_gera_ajuste_contr
                 from param_cfop_empresa  pc
                    , param_cfop_empr_cst pe
                where pc.empresa_id          = vn_empresa_id_matriz
                  and pc.cfop_id             = en_cfop_id
                  and pe.paramcfopempresa_id = pc.id
                  and pe.codst_id_cofins     = en_codst_id_cofins;
            exception
               when others then
                  vn_dm_gera_ajuste_contr := null;
            end;
            --
         end if;
         --
         vn_fase := 5.3;
         --
         if vn_dm_gera_ajuste_contr is null then
            -- Se não encontrou, busca a matriz informada sem parametrização de PIS / COFINS
            begin
               select pc.dm_gera_ajuste_contr
                 into vn_dm_gera_ajuste_contr
                 from param_cfop_empresa pc
                where pc.empresa_id = vn_empresa_id_matriz
                  and pc.cfop_id    = en_cfop_id
                  and not exists (select 1 from param_cfop_empr_cst pe where pe.paramcfopempresa_id = pc.id);
            exception
               when others then
                  vn_dm_gera_ajuste_contr := 0; -- valor default 0-não
            end;
            --
         end if;
         --
      end if; -- nvl(vn_empresa_id_matriz,0) = nvl(en_empresa_id,0) then
      --
   end if;
   --
   return vn_dm_gera_ajuste_contr;
   --
exception
   when others then
      raise_application_error(-20101, 'Problemas em fkg_dmgeraajusm210_parcfopempr, fase '||vn_fase||'. Erro = '||sqlerrm);
end fkg_dmgeraajusm210_parcfopempr;

-------------------------------------------------------------------------------------------------------
-- Função para retornar o identificador do código de ajuste de contribuição ou crédito através do código.
function fkg_id_cd_ajustcontrpc ( en_cd in ajust_contr_pc.cd%type )
         return ajust_contr_pc.id%type
is
   --
   vn_ajustcontrpc_id ajust_contr_pc.id%type := 0;
   --
begin
   --
   select ac.id
     into vn_ajustcontrpc_id
     from ajust_contr_pc ac
    where ac.cd = en_cd;
   --
   return vn_ajustcontrpc_id;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error (-20101, 'Erro na pk_csf_efd_pc.fkg_id_cd_ajustcontrpc: '||sqlerrm );
end fkg_id_cd_ajustcontrpc;

----------------------------------------------------------------------------------------------------------
-- Função para retornar o parâmetro que indica geração de receita para CST através da Natureza de Receita
function fkg_dm_gerareceita_natrecpc( en_natrecpc_id in nat_rec_pc.id%type )
         return nat_rec_pc.dm_gera_receita%type
is
   --
   vn_dm_gera_receita nat_rec_pc.dm_gera_receita%type := 1; -- 0-não, 1-sim
   --
begin
   --
   select nr.dm_gera_receita
     into vn_dm_gera_receita
     from nat_rec_pc nr
    where nr.id = en_natrecpc_id;
   --
   return vn_dm_gera_receita;
   --
exception
   when no_data_found then
      return 1; -- 0-não, 1-sim
   when others then
      raise_application_error (-20101, 'Erro na pk_csf_efd_pc.fkg_dm_gerareceita_natrecpc: '||sqlerrm );
end fkg_dm_gerareceita_natrecpc;

----------------------------------------------------------------------------------------------------------
-- Função para retornar o parâmetro de Cálculo automático do Bloco M
function fkg_dmcalcblocomaut_empresa( en_empresa_id in param_efd_contr.empresa_id%type )
         return param_efd_contr.dm_calc_bloco_m_aut%type
is
   --
   vn_dm_calc_bloco_m_aut param_efd_contr.dm_calc_bloco_m_aut%type := 0; -- 0-não, 1-sim
   --
begin
   --
   select pe.dm_calc_bloco_m_aut
     into vn_dm_calc_bloco_m_aut
     from param_efd_contr pe
    where pe.empresa_id = en_empresa_id;
   --
   return vn_dm_calc_bloco_m_aut;
   --
exception
   when no_data_found then
      return 0; -- 0-não, 1-sim
   when others then
      raise_application_error (-20101, 'Erro na pk_csf_efd_pc.fkg_dmcalcblocomaut_empresa: '||sqlerrm );
end fkg_dmcalcblocomaut_empresa;

----------------------------------------------------------------------------------------------------------
-- Função retorna se existe período de abertura efd pis/cofins com arquivo gerado
function fkb_existe_perarq_gerado( en_empresa_id in empresa.id%type
                                 , ed_data       in date
                                 )
         return boolean
is
   --
   vv_existe varchar2(1) := 'N';
   --
begin
   --
   begin
      select 'S'
        into vv_existe
        from abertura_efd_pc ae
       where ae.empresa_id   = en_empresa_id
         and ae.dm_situacao in (2, 3) -- 2-Validado, 3-Gerado Arquivo
         and ed_data   between ae.dt_ini and ae.dt_fin;
   exception
      when no_data_found then
         vv_existe := 'N';
      when too_many_rows then
         vv_existe := 'S';
      when others then
         raise_application_error (-20101, 'Problemas ao verificar se existe abertura efd pis/cofins com arquivo gerado no período solicitado (empresa_id = '||
                                          en_empresa_id||' data = '||ed_data||' - pk_csf_efd_pc.fkb_existe_perarq_gerado). Erro = '||sqlerrm);
   end;
   --
   if vv_existe = 'S' then
      return(true);
   else
      return(false);
   end if;
   --
exception
   when others then
      return(false);
end fkb_existe_perarq_gerado;

------------------------------------------------------------------------------------------------------------------------
-- Função retorna o identificador do código de atividade incidente da contribuição previdenciária sobre a receita bruta
function fkg_codativcprb_id_empativcprb( en_empresa_id   in empresa.id%type
                                       , en_item_id      in item.id%type default null
                                       , en_ncm_id       in ncm.id%type  default null
                                       , en_tpservico_id in tipo_servico.id%type default null 
                                       , en_cnae_id      in cnae.id%type default null                                       
                                       )
         return empresa_ativcprb.codativcprb_id%type
is
   --
   vn_codativcprb_id empresa_ativcprb.codativcprb_id%type := null;
   --
begin
   -- Tenta recuperar o parâmetro pela Empresa e id do ítem (produto)
   begin
      select ea.codativcprb_id
        into vn_codativcprb_id
        from empresa_ativcprb ea
       where ea.empresa_id = en_empresa_id
         and ea.item_id    = en_item_id
         and en_item_id    is not null
         and ea.ncm_id    is null
         and ea.cnae_id   is null
         and ea.tpservico_id  is null;      
   exception
      when no_data_found then
         vn_codativcprb_id := null;
   end;
   --
   -- Tenta recuperar o parâmetro pela Empresa e id do NCM
   if nvl(vn_codativcprb_id,0) = 0 then
   begin
      select ea.codativcprb_id
        into vn_codativcprb_id
        from empresa_ativcprb ea
       where ea.empresa_id = en_empresa_id
            and ea.item_id    is null
            and ea.ncm_id     = en_ncm_id
            and en_ncm_id     is not null
            and ea.tpservico_id is null
            and ea.cnae_id      is null;
   exception
      when no_data_found then
         vn_codativcprb_id := null;
   end;
   end if;
   --
   -- Tenta recuperar o parâmetro pela Empresa e id do NCM
   if nvl(vn_codativcprb_id,0) = 0 then
   begin
      select ea.codativcprb_id
        into vn_codativcprb_id
        from empresa_ativcprb ea
       where ea.empresa_id = en_empresa_id
            and ea.item_id    is null
            and ea.ncm_id     = en_ncm_id
            and en_ncm_id     is not null
            and ea.tpservico_id is null
            and ea.cnae_id      is null;
   exception
      when no_data_found then
         vn_codativcprb_id := null;
   end;
   end if;
   --
   -- Tenta recuperar o parâmetro pela Empresa e id do CD_LISTA_SERV  (tipo_servico)
   if nvl(vn_codativcprb_id,0) = 0 then
   begin
      select ea.codativcprb_id
        into vn_codativcprb_id
        from empresa_ativcprb ea
       where ea.empresa_id = en_empresa_id
            and ea.item_id      is null
            and ea.tpservico_id = en_tpservico_id
            and en_ncm_id       is null
            and ea.tpservico_id is not null
            and ea.cnae_id      is null;
   exception
      when no_data_found then
         vn_codativcprb_id := null;
   end;
   end if;
   --
   -- Tenta recuperar o parâmetro pela Empresa e id do CNAE
   if nvl(vn_codativcprb_id,0) = 0 then
   begin
      select ea.codativcprb_id
        into vn_codativcprb_id
        from empresa_ativcprb ea
       where ea.empresa_id = en_empresa_id
            and ea.item_id      is null
            and ea.cnae_id = en_cnae_id
            and en_ncm_id       is null
            and ea.cnae_id  is not null
            and ea.tpservico_id is null;
   exception
      when no_data_found then
         vn_codativcprb_id := null;
   end;
   end if;
   --
   -- Tenta recuperar o parâmetro pela Matriz e id do ítem (produto)
   if nvl(vn_codativcprb_id,0) = 0 then
      begin
         select ea.codativcprb_id
           into vn_codativcprb_id
           from empresa_ativcprb ea
          where ea.empresa_id = pk_csf.fkg_empresa_id_matriz ( en_empresa_id )
            and ea.item_id    = en_item_id
            and en_item_id    is not null
            and ea.tpservico_id is null
            and ea.cnae_id      is null;
      exception
         when no_data_found then
            vn_codativcprb_id := null;
      end;
      --
   end if;
   --
   -- Tenta recuperar o parâmetro pela Matriz e id do NCM
   if nvl(vn_codativcprb_id,0) = 0 then
      begin
         select ea.codativcprb_id
           into vn_codativcprb_id
           from empresa_ativcprb ea
          where ea.empresa_id = pk_csf.fkg_empresa_id_matriz ( en_empresa_id )
            and ea.item_id    is null
            and ea.ncm_id     = en_ncm_id
            and en_ncm_id     is not null
            and ea.tpservico_id is null
            and ea.cnae_id      is null;
      exception
         when no_data_found then
            vn_codativcprb_id := null;
      end;
      --
   end if;
   --
   -- Tenta recuperar o parâmetro pela Empresa e id do CD_LISTA_SERV  (tipo_servico)
   if nvl(vn_codativcprb_id,0) = 0 then
   begin
      select ea.codativcprb_id
        into vn_codativcprb_id
        from empresa_ativcprb ea
       where ea.empresa_id = pk_csf.fkg_empresa_id_matriz ( en_empresa_id )
            and ea.item_id      is null
            and ea.tpservico_id = en_tpservico_id
            and en_ncm_id       is null
            and ea.tpservico_id is not null
            and ea.cnae_id      is null;
   exception
      when no_data_found then
         vn_codativcprb_id := null;
   end;
   end if;
   --
   -- Tenta recuperar o parâmetro pela Empresa e id do CNAE
   if nvl(vn_codativcprb_id,0) = 0 then
   begin
      select ea.codativcprb_id
        into vn_codativcprb_id
        from empresa_ativcprb ea
       where ea.empresa_id = pk_csf.fkg_empresa_id_matriz ( en_empresa_id )
            and ea.item_id      is null
            and ea.cnae_id = en_cnae_id
            and en_ncm_id       is null
            and ea.cnae_id  is not null
            and ea.tpservico_id is null;
   exception
      when no_data_found then
         vn_codativcprb_id := null;
   end;
   end if;
   return(vn_codativcprb_id);
   --
exception
   when others then
      raise_application_error (-20101, 'Problemas ao recuperar identificador do código de atividade incidente da contribuição previdenciária sobre a '||
                                       'receita bruta através da empresa e item do produto relacionados (empresa_id = '||en_empresa_id||' en_item_id = '||
                                       en_item_id||' - pk_csf_efd_pc.fkg_codativcprb_id_empativcprb). Erro = '||sqlerrm);
end fkg_codativcprb_id_empativcprb;

--------------------------------------------------------------------------------------------------------------------------------
-- Função retorna o código da atividade incidente da contribuição previdenciária sobre a receita bruta através do identificador
function fkg_cd_codativcprb( en_codativcprb_id in cod_ativ_cprb.id%type
                           )
         return cod_ativ_cprb.cd%type
is
   --
   vv_cd cod_ativ_cprb.cd%type := null;
   --
begin
   --
   begin
      select ca.cd
        into vv_cd
        from cod_ativ_cprb ca
       where ca.id = en_codativcprb_id;
   exception
      when no_data_found then
         vv_cd := null;
      when others then
         raise_application_error (-20101, 'Problemas ao recuperar o código de atividade incidente da contribuição previdenciária sobre a receita bruta através '||
                                          'do identificador (en_codativcprb_id = '||en_codativcprb_id||' - pk_csf_efd_pc.fkg_cd_codativcprb). Erro = '||sqlerrm);
   end;
   --
   return(vv_cd);
   --
exception
   when others then
      return(null);
end fkg_cd_codativcprb;

-------------------------------------------------------------------------------------------------------------------------
-- Função retorna o código de Detalhamento da contribuição previdenciária sobre a receita bruta através do identificador
function fkg_cd_coddetcprb( en_coddetcprb_id in cod_det_cprb.id%type
                          )
         return cod_det_cprb.cd%type
is
   --
   vv_cd cod_det_cprb.cd%type := null;
   --
begin
   --
   begin
      select cd.cd
        into vv_cd
        from cod_det_cprb cd
       where cd.id = en_coddetcprb_id;
   exception
      when no_data_found then
         vv_cd := null;
      when others then
         raise_application_error (-20101, 'Problemas ao recuperar o código de detalhamento da contribuição previdenciária sobre a receita bruta através '||
                                          'do identificador (en_coddetcprb_id = '||en_coddetcprb_id||' - pk_csf_efd_pc.fkg_cd_coddetcprb). Erro = '||sqlerrm);
   end;
   --
   return(vv_cd);
   --
exception
   when others then
      return(null);
end fkg_cd_coddetcprb;

-----------------------------------------------------------------------------------------------
-- Função para retornar o código de ajuste de contribuição ou crédito através do identificador
function fkg_cd_ajustcontrpc ( en_ajustcontrpc_id in ajust_contr_pc.id%type )
         return ajust_contr_pc.cd%type
is
   --
   vv_cd ajust_contr_pc.cd%type := null;
   --
begin
   --
   select ac.cd
     into vv_cd
     from ajust_contr_pc ac
    where ac.id = en_ajustcontrpc_id;
   --
   return vv_cd;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error (-20101, 'Erro na pk_csf_efd_pc.fkg_cd_ajustcontrpc: '||sqlerrm );
end fkg_cd_ajustcontrpc;

----------------------------------------------------------------------------------------------------------------
-- Função para retornar se o CFOP gera INSS desonerado, porém sem utilizar os parâmetros de CST de PIS e COFINS
function fkb_gerainssdeson_cfop ( en_empresa_id      in empresa.id%type
                                , en_cfop_id         in cfop.id%type
                                , en_codst_id_pis    in param_cfop_empr_cst.codst_id_pis%type    default null
                                , en_codst_id_cofins in param_cfop_empr_cst.codst_id_cofins%type default null
                                )
         return param_cfop_empresa.dm_gera_inss_deson%type
is
   --
   vn_fase               number := 0;
   vn_dm_gera_inss_deson param_cfop_empresa.dm_gera_inss_deson%type := 0; -- 0-não, 1-sim
   vn_empresa_id_matriz  empresa.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   begin
      select pc.dm_gera_inss_deson
        into vn_dm_gera_inss_deson
        from param_cfop_empresa pc
       where pc.empresa_id = en_empresa_id
         and pc.cfop_id    = en_cfop_id
         and not exists (select 1 from param_cfop_empr_cst pe where pe.paramcfopempresa_id = pc.id);
   exception
      when others then
         vn_dm_gera_inss_deson := null;
   end;
   --
   vn_fase := 2;
   -- Se não encontrou pela Empresa, busca pela Matriz da Empresa
   if vn_dm_gera_inss_deson is null then
      --
      vn_fase := 3;
      -- Busca a empresa matriz para novas consultas
      vn_empresa_id_matriz := pk_csf.fkg_empresa_id_matriz ( en_empresa_id );
      --
      vn_fase := 4;
      --
      if nvl(vn_empresa_id_matriz,0) = nvl(en_empresa_id,0) then
         -- Não é necessário fazer a busca pois as empresas são iguais.
         vn_dm_gera_inss_deson := 0; -- valor default 0-não
         --
      else
         --
         vn_fase := 5;
         -- Se não encontrou, busca a matriz informada sem parametrização de PIS / COFINS
         begin
            select pc.dm_gera_inss_deson
              into vn_dm_gera_inss_deson
              from param_cfop_empresa pc
             where pc.empresa_id = vn_empresa_id_matriz
               and pc.cfop_id    = en_cfop_id
               and not exists (select 1 from param_cfop_empr_cst pe where pe.paramcfopempresa_id = pc.id);
         exception
            when others then
               vn_dm_gera_inss_deson := 0; -- valor default 0-não
         end;
         --
      end if; -- nvl(vn_empresa_id_matriz,0) = nvl(en_empresa_id,0) then
      --
   end if;
   --
   return vn_dm_gera_inss_deson;
   --
exception
   when others then
      raise_application_error(-20101, 'Problemas em fkb_gerainssdeson_cfop, fase '||vn_fase||'. Erro = '||sqlerrm);
end fkb_gerainssdeson_cfop;

---------------------------------------------------------------------------------------------------------------
-- Função para retornar se a Empresa permite validação com registro de log/inconsistência para INSS desonerado
function fkb_valinssdeson_empr ( en_empresa_id empresa.id%type )
         return param_efd_contr.dm_valida_inss_deson%type
is
   --
   vn_dm_valida_inss_deson param_efd_contr.dm_valida_inss_deson%type := 1; -- 0-Não Valida e Registra Log, 1-Valida e Registra Log
   --
begin
   -- busca na empresa informada
   begin
      select pe.dm_valida_inss_deson
        into vn_dm_valida_inss_deson
        from param_efd_contr pe
       where pe.empresa_id = en_empresa_id;
   exception
      when others then
         vn_dm_valida_inss_deson := null;
   end;
   -- busca na matriz
   if vn_dm_valida_inss_deson is null then
      --
      begin
         select pe.dm_valida_inss_deson
           into vn_dm_valida_inss_deson
           from param_efd_contr pe
          where pe.empresa_id = pk_csf.fkg_empresa_id_matriz ( en_empresa_id );
      exception
         when others then
            vn_dm_valida_inss_deson := 0; -- valor default 0-não
      end;
      --
   end if;
   --
   return vn_dm_valida_inss_deson;
   --
exception
   when others then
      raise_application_error (-20101, 'Erro na pk_csf_efd_pc.fkb_valinssdeson_empr: '||sqlerrm );
end fkb_valinssdeson_empr;

---------------------------------------------------------------------------------------------------------------
-- Função para retornar se o código de atividade incidente CPRB está válido dentro do período da apuração
function fkb_valida_codativcprb_id ( en_codativcprb_id in cod_ativ_cprb.id%type
                                   , ed_dt_inicial     in date
                                   , ed_dt_final       in date )
         return cod_ativ_cprb.id%type
is
   --
   vn_codativcprb_id cod_ativ_cprb.id%type;
   --
begin
   --
   begin
      select ca.id
        into vn_codativcprb_id
        from cod_ativ_cprb ca
       where ca.id      = en_codativcprb_id
         and ca.dt_ini <= ed_dt_inicial
         and ((ca.dt_fin is null)
               or
              (ca.dt_fin >= ed_dt_final));
   exception
      when others then
         vn_codativcprb_id := 0;
   end;
   --
   return vn_codativcprb_id;
   --
exception
   when others then
      raise_application_error (-20101, 'Erro na pk_csf_efd_pc.fkb_valida_codativcprb_id: '||sqlerrm );
end fkb_valida_codativcprb_id;

---------------------------------------------------------------------------------------------------------------
-- Função para retornar a alíquota vinculada ao código da atividade da previdência (cod_ativ_cprb.aliq)
function fkb_aliq_codativcprb_id( en_codativcprb_id in cod_ativ_cprb.id%type )
         return cod_ativ_cprb.aliq%type
is
   --
   vn_aliq cod_ativ_cprb.aliq%type;
   --
begin
   --
   begin
      select ca.aliq
        into vn_aliq
        from cod_ativ_cprb ca
       where ca.id = en_codativcprb_id;
   exception
      when others then
         vn_aliq := 0;
   end;
   --
   return vn_aliq;
   --
exception
   when others then
      raise_application_error (-20101, 'Erro na pk_csf_efd_pc.fkb_aliq_codativcprb_id: '||sqlerrm );
end fkb_aliq_codativcprb_id;

-----------------------------------------------------------------------------------------------------------
-- Função para retornar os parâmetros de CFOP para os ajustes da CPRB através de Empresa e CFOP (param_cfop_empresa)
function fkb_paramcfopempr_emprcfop ( en_empresa_id          in  param_cfop_empresa.empresa_id%type
                                    , en_cfop_id             in  param_cfop_empresa.cfop_id%type
                                    , sn_dm_gera_receita     out param_cfop_empresa.dm_gera_receita%type
                                    , sn_dm_gera_inss_deson  out param_cfop_empresa.dm_gera_inss_deson%type
                                    , sn_dm_gera_ajuste_cprb out param_cfop_empresa.dm_gera_ajuste_cprb%type
                                    , sn_dm_tipo_ajuste      out param_cfop_empresa.dm_tipo_ajuste%type
                                    , sn_dm_ind_aj           out param_cfop_empresa.dm_ind_aj%type
                                    , sn_ajustcontrpc_id     out param_cfop_empresa.ajustcontrpc_id%type )
         return number
is
   --
   vn_fase               number;
   vn_empresa_id_matriz  empresa.id%type;
   --
begin
   --
   vn_fase := 1;
   -- busca na empresa informada
   begin
      select pc.dm_gera_receita
           , pc.dm_gera_inss_deson
           , pc.dm_gera_ajuste_cprb
           , pc.dm_tipo_ajuste
           , pc.dm_ind_aj
           , pc.ajustcontrpc_id
        into sn_dm_gera_receita
           , sn_dm_gera_inss_deson
           , sn_dm_gera_ajuste_cprb
           , sn_dm_tipo_ajuste
           , sn_dm_ind_aj
           , sn_ajustcontrpc_id
        from param_cfop_empresa pc
       where pc.empresa_id = en_empresa_id
         and pc.cfop_id    = en_cfop_id
         and not exists (select 1 from param_cfop_empr_cst pe where pe.paramcfopempresa_id = pc.id);
   exception
      when others then
         sn_dm_gera_receita     := null;
         sn_dm_gera_inss_deson  := null;
         sn_dm_gera_ajuste_cprb := null;
         sn_dm_tipo_ajuste      := null;
         sn_dm_ind_aj           := null;
         sn_ajustcontrpc_id     := null;
   end;
   --
   vn_fase := 2;
   -- busca na matriz
   if sn_dm_gera_receita is null then
      --
      vn_fase := 3;
      -- Busca a empresa matriz para novas consultas
      vn_empresa_id_matriz := pk_csf.fkg_empresa_id_matriz ( en_empresa_id );
      --
      vn_fase := 4;
      --
      if nvl(vn_empresa_id_matriz,0) = nvl(en_empresa_id,0) then
         -- Não é necessário fazer a busca pois as empresas são iguais.
         sn_dm_gera_receita     := 1; -- valor default: Indicador de CFOP que gera receitas isentas para PIS/COFINS (0-não, 1-sim)
         sn_dm_gera_inss_deson  := 1; -- valor default: Gera INSS desonerado? 0-Não; 1-Sim
         sn_dm_gera_ajuste_cprb := 0; -- valor default: Gerar ajuste automático da CPRB? 0-não, 1-sim
         sn_dm_tipo_ajuste      := 0; -- valor default: Tipo de ajuste a ser gerado: 0-Nenhum, 1-Desconto incondicional, 2-Devolução de Vendas, 3-Retorno de Vendas, 4-Exportação.
         sn_dm_ind_aj           := 2; -- valor default: Indicador de ajuste: 0-Ajuste de redução, 1-Ajuste de acréscimo, 2-Nenhum
         sn_ajustcontrpc_id     := null; -- valor default: Identificador do código de ajuste
         --
      else
         --
         vn_fase := 5;
         --
         begin
            select pc.dm_gera_receita
                 , pc.dm_gera_inss_deson
                 , pc.dm_gera_ajuste_cprb
                 , pc.dm_tipo_ajuste
                 , pc.dm_ind_aj
                 , pc.ajustcontrpc_id
              into sn_dm_gera_receita
                 , sn_dm_gera_inss_deson
                 , sn_dm_gera_ajuste_cprb
                 , sn_dm_tipo_ajuste
                 , sn_dm_ind_aj
                 , sn_ajustcontrpc_id
              from param_cfop_empresa pc
             where pc.empresa_id = vn_empresa_id_matriz
               and pc.cfop_id    = en_cfop_id
               and not exists (select 1 from param_cfop_empr_cst pe where pe.paramcfopempresa_id = pc.id);
         exception
            when others then
               sn_dm_gera_receita     := 1; -- valor default: Indicador de CFOP que gera receitas isentas para PIS/COFINS (0-não, 1-sim)
               sn_dm_gera_inss_deson  := 1; -- valor default: Gera INSS desonerado? 0-Não; 1-Sim
               sn_dm_gera_ajuste_cprb := 0; -- valor default: Gerar ajuste automático da CPRB? 0-não, 1-sim
               sn_dm_tipo_ajuste      := 0; -- valor default: Tipo de ajuste a ser gerado: 0-Nenhum, 1-Desconto incondicional, 2-Devolução de Vendas, 3-Retorno de Vendas, 4-Exportação.
               sn_dm_ind_aj           := 2; -- valor default: Indicador de ajuste: 0-Ajuste de redução, 1-Ajuste de acréscimo, 2-Nenhum
               sn_ajustcontrpc_id     := null; -- valor default: Identificador do código de ajuste
         end;
         --
      end if; -- nvl(vn_empresa_id_matriz,0) = nvl(en_empresa_id,0)
      --
   end if;
   --
   return 1;
   --
exception
   when others then
      raise_application_error(-20101, 'Problemas em fkb_paramcfopempr_emprcfop, fase '||vn_fase||'. Erro = '||sqlerrm);
end fkb_paramcfopempr_emprcfop;

----------------------------------------------------------------------------------------------------------
-- Função retorna se existe Obrigações a Recolher da Apuração de PIS das consolidações de contribuições com tipo Digitado
function fkb_existe_pisor_gerado( en_perconscontrpis_id in per_cons_contr_pis.id%type
                                )
         return boolean
is
   --
   vv_existe varchar2(1) := 'N';
   --
begin
   --
   begin
      select 'S'
        into vv_existe
        from cons_contr_pis_or cc
       where cc.dm_origem = 0 -- 0-Digitado, 1-Gerado no Bloco M200
         and exists (select cc.id
                       from cons_contr_pis cc
                      where cc.perconscontrpis_id = en_perconscontrpis_id
                        and cc.id                 = cc.conscontrpis_id);
   exception
      when no_data_found then
         vv_existe := 'N';
      when too_many_rows then
         vv_existe := 'S';
      when others then
         raise_application_error (-20101, 'Problemas ao verificar se existe Obrigações a Recolher da Apuração de PIS das consolidações de contribuições com '||
                                          'origem Digitado (en_perconscontrpis_id = '||en_perconscontrpis_id||' - pk_csf_efd_pc.fkb_existe_pisor_gerado). '||
                                          'Erro = '||sqlerrm);
   end;
   --
   if vv_existe = 'S' then
      return(true);
   else
      return(false);
   end if;
   --
exception
   when others then
      return(false);
end fkb_existe_pisor_gerado;

----------------------------------------------------------------------------------------------------------
-- Função retorna se existe Obrigações a Recolher da Apuração de COFINS das consolidações de contribuições com tipo Digitado
function fkb_existe_cofinsor_gerado( en_perconscontrcofins_id in per_cons_contr_cofins.id%type
                                   )
         return boolean
is
   --
   vv_existe varchar2(1) := 'N';
   --
begin
   --
   begin
      select 'S'
        into vv_existe
        from cons_contr_cofins_or cc
       where cc.dm_origem = 0 -- 0-Digitado, 1-Gerado no Bloco M600
         and exists (select cc.id
                       from cons_contr_cofins cc
                      where cc.perconscontrcofins_id = en_perconscontrcofins_id
                        and cc.id                    = cc.conscontrcofins_id);
   exception
      when no_data_found then
         vv_existe := 'N';
      when too_many_rows then
         vv_existe := 'S';
      when others then
         raise_application_error (-20101, 'Problemas ao verificar se existe Obrigações a Recolher da Apuração de COFINS das consolidações de contribuições com '||
                                          'origem Digitado (en_perconscontrcofins_id = '||en_perconscontrcofins_id||' - pk_csf_efd_pc.fkb_existe_cofinsor_gerado). '||
                                          'Erro = '||sqlerrm);
   end;
   --
   if vv_existe = 'S' then
      return(true);
   else
      return(false);
   end if;
   --
exception
   when others then
      return(false);
end fkb_existe_cofinsor_gerado;

----------------------------------------------------------------------------------------------------------------------
-- Função retorna se existe Relacionamento entre Apuração de Crédito (M100) e Controle de Crédito Fiscal (1100) - PIS
function fkb_existe_relac_apur_pis( en_apurcredpis_id in apur_cred_pis.id%type )
         return boolean is
   --
   vv_existe varchar2(1) := 'N';
   --
begin
   --
   begin
      select 'S'
        into vv_existe
        from r_apurcredpis_contrcredfpis ra
       where ra.apurcredpis_id = en_apurcredpis_id
         and rownum            = 1;
   exception
      when no_data_found then
         vv_existe := 'N';
      when too_many_rows then
         vv_existe := 'S';
      when others then
         raise_application_error (-20101, 'Problemas ao verificar se existe Relacionamento entre Apuração de Crédito e Controle de Crédito Fiscal do PIS '||
                                          '(en_apurcredpis_id = '||en_apurcredpis_id||' - pk_csf_efd_pc.fkb_existe_relac_apur_pis). Erro = '||sqlerrm);
   end;
   --
   if vv_existe = 'S' then
      return(true);
   else
      return(false);
   end if;
   --
exception
   when others then
      return(false);
end fkb_existe_relac_apur_pis;
---------------------------------------------------------------------------------------------------------------------------------
-- Função retorna se existe Valores de Relacionamento entre Apuração de Crédito (M100) e Controle de Crédito Fiscal (1100) - PIS
function fkb_existe_rel_apur_contr_pis( en_apurcredpis_id in apur_cred_pis.id%type )
         return boolean is
   --
   vv_existe varchar2(1) := 'N';
   --
begin
   --
   begin
      select 'S'
        into vv_existe
        from relac_apur_contr_pis ra
       where ra.apurcredpis_id = en_apurcredpis_id
         and rownum            = 1;
   exception
      when no_data_found then
         vv_existe := 'N';
      when too_many_rows then
         vv_existe := 'S';
      when others then
         raise_application_error (-20101, 'Problemas ao verificar se existe Valores de Relacionamento entre Apuração de Crédito e Controle de Crédito Fiscal '||
                                          'do PIS (en_apurcredpis_id = '||en_apurcredpis_id||' - pk_csf_efd_pc.fkb_existe_rel_apur_contr_pis). Erro = '||sqlerrm);
   end;
   --
   if vv_existe = 'S' then
      return(true);
   else
      return(false);
   end if;
   --
exception
   when others then
      return(false);
end fkb_existe_rel_apur_contr_pis;
---------------------------------------------------------------------------------------------------------------------------------------------
-- Função retorna se existe Relacionamento entre Apuração de Crédito (M100) e Controle de Crédito Fiscal (1100) - Controle de Crédito Fiscal
function fkb_existe_relac_contr_pis( en_contrcredfiscalpis_id in contr_cred_fiscal_pis.id%type )
         return boolean is
   --
   vv_existe varchar2(1) := 'N';
   --
begin
   --
   begin
      select 'S'
        into vv_existe
        from r_apurcredpis_contrcredfpis ra
       where ra.contrcredfiscalpis_id = en_contrcredfiscalpis_id
         and rownum            = 1;
   exception
      when no_data_found then
         vv_existe := 'N';
      when too_many_rows then
         vv_existe := 'S';
      when others then
         raise_application_error (-20101, 'Problemas ao verificar se existe Relacionamento entre Apuração de Crédito e Controle de Crédito Fiscal do PIS '||
                                          '(en_contrcredfiscalpis_id = '||en_contrcredfiscalpis_id||' - pk_csf_efd_pc.fkb_existe_relac_contr_pis). Erro = '||
                                          sqlerrm);
   end;
   --
   if vv_existe = 'S' then
      return(true);
   else
      return(false);
   end if;
   --
exception
   when others then
      return(false);
end fkb_existe_relac_contr_pis;
--------------------------------------------------------------------------------------------------------------------------------------------------------
-- Função retorna se existe Valores de Relacionamento entre Apuração de Crédito (M100) e Controle de Crédito Fiscal (1100) - Controle de Crédito Fiscal
function fkb_existe_rel_vlr_contr_pis( en_contrcredfiscalpis_id in contr_cred_fiscal_pis.id%type )
         return boolean is
   --
   vv_existe varchar2(1) := 'N';
   --
begin
   --
   begin
      select 'S'
        into vv_existe
        from relac_apur_contr_pis ra
       where ra.contrcredfiscalpis_id = en_contrcredfiscalpis_id
         and rownum            = 1;
   exception
      when no_data_found then
         vv_existe := 'N';
      when too_many_rows then
         vv_existe := 'S';
      when others then
         raise_application_error (-20101, 'Problemas ao verificar se existe Valores de Relacionamento entre Apuração de Crédito e Controle de Crédito Fiscal '||
                                          'do PIS (en_contrcredfiscalpis_id = '||en_contrcredfiscalpis_id||' - pk_csf_efd_pc.fkb_existe_rel_vlr_contr_pis). '||
                                          'Erro = '||sqlerrm);
   end;
   --
   if vv_existe = 'S' then
      return(true);
   else
      return(false);
   end if;
   --
exception
   when others then
      return(false);
end fkb_existe_rel_vlr_contr_pis;
-------------------------------------------------------------------------------------------------------------------------
-- Função retorna se existe Relacionamento entre Apuração de Crédito (M500) e Controle de Crédito Fiscal (1500) - COFINS
function fkb_existe_relac_apur_cof( en_apurcredcofins_id in apur_cred_cofins.id%type )
         return boolean is
   --
   vv_existe varchar2(1) := 'N';
   --
begin
   --
   begin
      select 'S'
        into vv_existe
        from r_apurcredcof_contrcredfcof ra
       where ra.apurcredcofins_id = en_apurcredcofins_id
         and rownum               = 1;
   exception
      when no_data_found then
         vv_existe := 'N';
      when too_many_rows then
         vv_existe := 'S';
      when others then
         raise_application_error (-20101, 'Problemas ao verificar se existe Relacionamento entre Apuração de Crédito e Controle de Crédito Fiscal da COFINS '||
                                          '(en_apurcredcofins_id = '||en_apurcredcofins_id||' - pk_csf_efd_pc.fkb_existe_relac_apur_cof). Erro = '||sqlerrm);
   end;
   --
   if vv_existe = 'S' then
      return(true);
   else
      return(false);
   end if;
   --
exception
   when others then
      return(false);
end fkb_existe_relac_apur_cof;
------------------------------------------------------------------------------------------------------------------------------------
-- Função retorna se existe Valores de Relacionamento entre Apuração de Crédito (M500) e Controle de Crédito Fiscal (1500) - COFINS
function fkb_existe_rel_apur_contr_cof( en_apurcredcofins_id in apur_cred_cofins.id%type )
         return boolean is
   --
   vv_existe varchar2(1) := 'N';
   --
begin
   --
   begin
      select 'S'
        into vv_existe
        from relac_apur_contr_cofins ra
       where ra.apurcredcofins_id = en_apurcredcofins_id
         and rownum               = 1;
   exception
      when no_data_found then
         vv_existe := 'N';
      when too_many_rows then
         vv_existe := 'S';
      when others then
         raise_application_error (-20101, 'Problemas ao verificar se existe Valores de Relacionamento entre Apuração de Crédito e Controle de Crédito Fiscal '||
                                          'da COFINS (en_apurcredcofins_id = '||en_apurcredcofins_id||' - pk_csf_efd_pc.fkb_existe_rel_apur_contr_cof). '||
                                          'Erro = '||sqlerrm);
   end;
   --
   if vv_existe = 'S' then
      return(true);
   else
      return(false);
   end if;
   --
exception
   when others then
      return(false);
end fkb_existe_rel_apur_contr_cof;
---------------------------------------------------------------------------------------------------------------------------------------------
-- Função retorna se existe Relacionamento entre Apuração de Crédito (M500) e Controle de Crédito Fiscal (1500) - Controle de Crédito Fiscal
function fkb_existe_relac_contr_cof( en_contrcredfiscalcofins_id in contr_cred_fiscal_cofins.id%type )
         return boolean is
   --
   vv_existe varchar2(1) := 'N';
   --
begin
   --
   begin
      select 'S'
        into vv_existe
        from r_apurcredcof_contrcredfcof ra
       where ra.contrcredfiscalcofins_id = en_contrcredfiscalcofins_id
         and rownum                      = 1;
   exception
      when no_data_found then
         vv_existe := 'N';
      when too_many_rows then
         vv_existe := 'S';
      when others then
         raise_application_error (-20101, 'Problemas ao verificar se existe Relacionamento entre Apuração de Crédito e Controle de Crédito Fiscal da COFINS '||
                                          '(en_contrcredfiscalcofins_id = '||en_contrcredfiscalcofins_id||' - pk_csf_efd_pc.fkb_existe_relac_contr_cof). '||
                                          'Erro = '||sqlerrm);
   end;
   --
   if vv_existe = 'S' then
      return(true);
   else
      return(false);
   end if;
   --
exception
   when others then
      return(false);
end fkb_existe_relac_contr_cof;
--------------------------------------------------------------------------------------------------------------------------------------------------------
-- Função retorna se existe Valores de Relacionamento entre Apuração de Crédito (M500) e Controle de Crédito Fiscal (1500) - Controle de Crédito Fiscal
function fkb_existe_rel_vlr_contr_cof( en_contrcredfiscalcofins_id in contr_cred_fiscal_cofins.id%type )
         return boolean is
   --
   vv_existe varchar2(1) := 'N';
   --
begin
   --
   begin
      select 'S'
        into vv_existe
        from relac_apur_contr_cofins ra
       where ra.contrcredfiscalcofins_id = en_contrcredfiscalcofins_id
         and rownum                      = 1;
   exception
      when no_data_found then
         vv_existe := 'N';
      when too_many_rows then
         vv_existe := 'S';
      when others then
         raise_application_error (-20101, 'Problemas ao verificar se existe Valores de Relacionamento entre Apuração de Crédito e Controle de Crédito Fiscal '||
                                          'da COFINS (en_contrcredfiscalcofins_id = '||en_contrcredfiscalcofins_id||
                                          ' - pk_csf_efd_pc.fkb_existe_rel_vlr_contr_cof). Erro = '||sqlerrm);
   end;
   --
   if vv_existe = 'S' then
      return(true);
   else
      return(false);
   end if;
   --
exception
   when others then
      return(false);
end fkb_existe_rel_vlr_contr_cof;

---------------------------------------------------------------------------------------------------------------
-- Função para retornar: ou plano de conta para PIS ou COFINS; ou, centro de custo para PIS ou COFINS
function fkb_recup_pcta_ccto_pc( en_empresa_id   in param_efd_contr_geral.empresa_id%type
                               , en_dm_ind_emit  in param_efd_contr_geral.dm_ind_emit%type default null
                               , en_dm_ind_oper  in param_efd_contr_geral.dm_ind_oper%type default null
                               , en_modfiscal_id in param_efd_contr_geral.modfiscal_id%type default null
                               , en_pessoa_id    in param_efd_contr_geral.pessoa_id%type default null
                               , en_cfop_id      in param_efd_contr_geral.cfop_id%type default null
                               , en_item_id      in param_efd_contr_geral.item_id%type default null
                               , en_ncm_id       in param_efd_contr_geral.ncm_id%type default null
                               , en_tpservico_id in param_efd_contr_geral.tpservico_id%type default null
                               , ed_dt_ini       in param_efd_contr_geral.dt_ini%type
                               , ed_dt_final     in param_efd_contr_geral.dt_final%type default null
                               , en_cod_st_piscofins  in param_efd_contr_geral.cod_st_piscofins%type default null
                               , ev_ret          in varchar2 ) -- 'PCTA_PIS', 'PCTA_COF', 'CCTO_PIS', 'CCTO_COF'
         return number -- planoconta_id_pis, centrocusto_id_pis, planoconta_id_cofins, centrocusto_id_cofins
is
   --
   vn_empresa_id            number;
   vn_planoconta_id_pis     number;
   vn_centrocusto_id_pis    number;
   vn_planoconta_id_cofins  number;
   vn_centrocusto_id_cofins number;
   vn_ret_id                number;
   --
   cursor c_recup_id( en_empresa_id   in param_efd_contr_geral.empresa_id%type
                    , ed_dt_ini       in param_efd_contr_geral.dt_ini%type
                    , ed_dt_final     in param_efd_contr_geral.dt_final%type default null
                    , en_dm_ind_emit  in param_efd_contr_geral.dm_ind_emit%type default null
                    , en_dm_ind_oper  in param_efd_contr_geral.dm_ind_oper%type default null
                    , en_modfiscal_id in param_efd_contr_geral.modfiscal_id%type default null
                    , en_pessoa_id    in param_efd_contr_geral.pessoa_id%type default null
                    , en_cfop_id      in param_efd_contr_geral.cfop_id%type default null
                    , en_item_id      in param_efd_contr_geral.item_id%type default null
                    , en_ncm_id       in param_efd_contr_geral.ncm_id%type default null
                    , en_tpservico_id in param_efd_contr_geral.tpservico_id%type default null
                    , en_cod_st_piscofins  in param_efd_contr_geral.cod_st_piscofins%type default null  
                    ) is
      select pe.planoconta_id_pis
           , pe.centrocusto_id_pis
           , pe.planoconta_id_cofins
           , pe.centrocusto_id_cofins
        from param_efd_contr_geral pe
       where pe.empresa_id = en_empresa_id
         and ed_dt_ini between pe.dt_ini and nvl(pe.dt_final,ed_dt_ini)
         and ((pe.dt_final is null)
               or
              (ed_dt_final is not null and
               ed_dt_final between pe.dt_ini and nvl(pe.dt_final,ed_dt_final)))
         and ((pe.dm_ind_emit is null)  or (nvl(pe.dm_ind_emit,9)  = nvl(en_dm_ind_emit,9)))
         and ((pe.dm_ind_oper is null)  or (nvl(pe.dm_ind_oper,9)  = nvl(en_dm_ind_oper,9)))
         and ((pe.modfiscal_id is null) or (nvl(pe.modfiscal_id,0) = nvl(en_modfiscal_id,0)))
         and ((pe.pessoa_id is null)    or (nvl(pe.pessoa_id,0)    = nvl(en_pessoa_id,0)))
         and ((pe.cfop_id is null)      or (nvl(pe.cfop_id,0)      = nvl(en_cfop_id,0)))
         and ((pe.item_id is null)      or (nvl(pe.item_id,0)      = nvl(en_item_id,0)))
         and ((pe.ncm_id is null)       or (nvl(pe.ncm_id,0)       = nvl(en_ncm_id,0)))
         and ((pe.tpservico_id is null) or (nvl(pe.tpservico_id,0) = nvl(en_tpservico_id,0)))
         and ((pe.cod_st_piscofins is null) or (nvl(pe.cod_st_piscofins,0) =  nvl(en_cod_st_piscofins,0))) 
    order by pe.tpservico_id
           , pe.ncm_id
           , pe.item_id
           , pe.cfop_id
           , pe.pessoa_id
           , pe.modfiscal_id
           , pe.dm_ind_oper
           , pe.dm_ind_emit;
   --
   cursor c_dados is
      select pe.dm_ind_emit
           , pe.dm_ind_oper
           , pe.modfiscal_id
           , pe.pessoa_id
           , pe.cfop_id
           , pe.item_id
           , pe.ncm_id
           , pe.tpservico_id
           , pe.planoconta_id_pis
           , pe.centrocusto_id_pis
           , pe.planoconta_id_cofins
           , pe.centrocusto_id_cofins
        from param_efd_contr_geral pe
       where pe.empresa_id   = en_empresa_id
         and ed_dt_ini between pe.dt_ini and nvl(pe.dt_final,ed_dt_ini)
         and ((pe.dt_final is null)
               or
              (ed_dt_final is not null and
               ed_dt_final between pe.dt_ini and nvl(pe.dt_final,ed_dt_final)))
       order by pe.dm_ind_emit
           , pe.dm_ind_oper
           , pe.modfiscal_id
           , pe.pessoa_id
           , pe.cfop_id
           , pe.item_id
           , pe.ncm_id
           , pe.tpservico_id
           , pe.dt_ini desc;
   --
begin
   -- Recuperar a empresa matriz
   vn_empresa_id            := pk_csf.fkg_empresa_id_matriz( en_empresa_id => en_empresa_id);
   -- Recuperar os Identificadores do Plano de Contas e do Centro de Custos através do parâmetros iniciais de entrada
   vn_planoconta_id_pis     := null;
   vn_centrocusto_id_pis    := null;
   vn_planoconta_id_cofins  := null;
   vn_centrocusto_id_cofins := null;
   --
   open c_recup_id( en_empresa_id   => en_empresa_id -- empresa inicial
                  , ed_dt_ini       => ed_dt_ini
                  , ed_dt_final     => ed_dt_final
                  , en_dm_ind_emit  => en_dm_ind_emit
                  , en_dm_ind_oper  => en_dm_ind_oper
                  , en_modfiscal_id => en_modfiscal_id
                  , en_pessoa_id    => en_pessoa_id
                  , en_cfop_id      => en_cfop_id
                  , en_item_id      => en_item_id
                  , en_ncm_id       => en_ncm_id
                  , en_tpservico_id => en_tpservico_id 
                  , en_cod_st_piscofins => en_cod_st_piscofins
                  );
   fetch c_recup_id into vn_planoconta_id_pis
                       , vn_centrocusto_id_pis
                       , vn_planoconta_id_cofins
                       , vn_centrocusto_id_cofins;
   close c_recup_id;
   --
   if ev_ret = 'PCTA_PIS' and nvl(vn_planoconta_id_pis,0) <> 0 then
      vn_ret_id := vn_planoconta_id_pis;
   elsif ev_ret = 'CCTO_PIS' and  nvl(vn_centrocusto_id_pis,0) <> 0 then
         vn_ret_id := vn_centrocusto_id_pis;
   elsif ev_ret = 'PCTA_COF' and  nvl(vn_planoconta_id_cofins,0) <> 0 then
         vn_ret_id := vn_planoconta_id_cofins;
   elsif ev_ret = 'CCTO_COF' and  nvl(vn_centrocusto_id_cofins,0) <> 0 then
         vn_ret_id := vn_centrocusto_id_cofins;
   end if;
   --
   if nvl(vn_ret_id,0) = 0 then -- Identificador ainda não encontrado
      --
      vn_planoconta_id_pis     := null;
      vn_centrocusto_id_pis    := null;
      vn_planoconta_id_cofins  := null;
      vn_centrocusto_id_cofins := null;
      --
      if nvl(vn_empresa_id,0) = nvl(en_empresa_id,0) then
         -- Recuperar os Identificadores por outro processo
         null;
         --
      else
         -- Recuperar os Identificadores do Plano de Contas e do Centro de Custos através do parâmetros iniciais de entrada, porém com Empresa Matriz
         open c_recup_id( en_empresa_id   => vn_empresa_id -- empresa matriz
                        , ed_dt_ini       => ed_dt_ini
                        , ed_dt_final     => ed_dt_final
                        , en_dm_ind_emit  => en_dm_ind_emit
                        , en_dm_ind_oper  => en_dm_ind_oper
                        , en_modfiscal_id => en_modfiscal_id
                        , en_pessoa_id    => en_pessoa_id
                        , en_cfop_id      => en_cfop_id
                        , en_item_id      => en_item_id
                        , en_ncm_id       => en_ncm_id
                        , en_tpservico_id => en_tpservico_id 
                        , en_cod_st_piscofins => en_cod_st_piscofins);
         fetch c_recup_id into vn_planoconta_id_pis
                             , vn_centrocusto_id_pis
                             , vn_planoconta_id_cofins
                             , vn_centrocusto_id_cofins;
         close c_recup_id;
         --
         if ev_ret = 'PCTA_PIS' and nvl(vn_planoconta_id_pis,0) <> 0 then
            vn_ret_id := vn_planoconta_id_pis;
         elsif ev_ret = 'CCTO_PIS' and  nvl(vn_centrocusto_id_pis,0) <> 0 then
               vn_ret_id := vn_centrocusto_id_pis;
         elsif ev_ret = 'PCTA_COF' and  nvl(vn_planoconta_id_cofins,0) <> 0 then
               vn_ret_id := vn_planoconta_id_cofins;
         elsif ev_ret = 'CCTO_COF' and  nvl(vn_centrocusto_id_cofins,0) <> 0 then
               vn_ret_id := vn_centrocusto_id_cofins;
         end if;
         --
      end if;
      --
   end if;
   --
   if nvl(vn_ret_id,0) = 0 then -- Identificador ainda não encontrado
      --
      begin
         select pe.planoconta_id_pis
              , pe.centrocusto_id_pis
              , pe.planoconta_id_cofins
              , pe.centrocusto_id_cofins
           into vn_planoconta_id_pis
              , vn_centrocusto_id_pis
              , vn_planoconta_id_cofins
              , vn_centrocusto_id_cofins
           from param_efd_contr_geral pe
          where pe.empresa_id = en_empresa_id -- empresa enviada no parâmetro (matriz ou filial)
            and ed_dt_ini between pe.dt_ini and nvl(pe.dt_final,ed_dt_ini)
            and ((pe.dt_final is null)
                  or
                 (ed_dt_final is not null and
                  ed_dt_final between pe.dt_ini and nvl(pe.dt_final,ed_dt_final)))
            and ((pe.dm_ind_emit is null)  or (nvl(pe.dm_ind_emit,9)  = nvl(en_dm_ind_emit,9)))
            and ((pe.dm_ind_oper is null)  or (nvl(pe.dm_ind_oper,9)  = nvl(en_dm_ind_oper,9)))
            and ((pe.modfiscal_id is null) or (nvl(pe.modfiscal_id,0) = nvl(en_modfiscal_id,0)))
            and ((pe.pessoa_id is null)    or (nvl(pe.pessoa_id,0)    = nvl(en_pessoa_id,0)))
            and ((pe.cfop_id is null)      or (nvl(pe.cfop_id,0)      = nvl(en_cfop_id,0)))
            and ((pe.item_id is null)      or (nvl(pe.item_id,0)      = nvl(en_item_id,0)))
            and ((pe.ncm_id is null)       or (nvl(pe.ncm_id,0)       = nvl(en_ncm_id,0)))
            and ((pe.tpservico_id is null) or (nvl(pe.tpservico_id,0) = nvl(en_tpservico_id,0)))
            and ((pe.cod_st_piscofins is null) or (nvl(pe.cod_st_piscofins,0) =  nvl(en_cod_st_piscofins,0)));
      exception
         when no_data_found then
            --
            if nvl(vn_empresa_id,0) = nvl(en_empresa_id,0) then -- empresa matriz igual a empresa inicial
               -- Não é necessário refazer o select, pois as empresas são iguais
               vn_planoconta_id_pis     := null;
               vn_centrocusto_id_pis    := null;
               vn_planoconta_id_cofins  := null;
               vn_centrocusto_id_cofins := null;
               --
            else
               -- Recuperação pela empresa matriz
               begin
                  select pe.planoconta_id_pis
                       , pe.centrocusto_id_pis
                       , pe.planoconta_id_cofins
                       , pe.centrocusto_id_cofins
                    into vn_planoconta_id_pis
                       , vn_centrocusto_id_pis
                       , vn_planoconta_id_cofins
                       , vn_centrocusto_id_cofins
                    from param_efd_contr_geral pe
                   where pe.empresa_id = vn_empresa_id -- empresa matriz
                     and ed_dt_ini between pe.dt_ini and nvl(pe.dt_final,ed_dt_ini)
                     and ((pe.dt_final is null)
                           or
                          (ed_dt_final is not null and
                           ed_dt_final between pe.dt_ini and nvl(pe.dt_final,ed_dt_final)))
                     and ((pe.dm_ind_emit is null)  or (nvl(pe.dm_ind_emit,9)  = nvl(en_dm_ind_emit,9)))
                     and ((pe.dm_ind_oper is null)  or (nvl(pe.dm_ind_oper,9)  = nvl(en_dm_ind_oper,9)))
                     and ((pe.modfiscal_id is null) or (nvl(pe.modfiscal_id,0) = nvl(en_modfiscal_id,0)))
                     and ((pe.pessoa_id is null)    or (nvl(pe.pessoa_id,0)    = nvl(en_pessoa_id,0)))
                     and ((pe.cfop_id is null)      or (nvl(pe.cfop_id,0)      = nvl(en_cfop_id,0)))
                     and ((pe.item_id is null)      or (nvl(pe.item_id,0)      = nvl(en_item_id,0)))
                     and ((pe.ncm_id is null)       or (nvl(pe.ncm_id,0)       = nvl(en_ncm_id,0)))
                     and ((pe.tpservico_id is null) or (nvl(pe.tpservico_id,0) = nvl(en_tpservico_id,0)))
                     and ((pe.cod_st_piscofins is null) or (nvl(pe.cod_st_piscofins,0) =  nvl(en_cod_st_piscofins,0)));
               exception
                  when too_many_rows then
                     -- Recuperar o último parâmetro - max(id)
                     begin
                        select max(pe.planoconta_id_pis)
                             , max(pe.centrocusto_id_pis)
                             , max(pe.planoconta_id_cofins)
                             , max(pe.centrocusto_id_cofins)
                          into vn_planoconta_id_pis
                             , vn_centrocusto_id_pis
                             , vn_planoconta_id_cofins
                             , vn_centrocusto_id_cofins
                          from param_efd_contr_geral pe
                         where pe.empresa_id = vn_empresa_id -- empresa matriz
                           and ed_dt_ini between pe.dt_ini and nvl(pe.dt_final,ed_dt_ini)
                           and ((pe.dt_final is null)
                                 or
                                (ed_dt_final is not null and
                                 ed_dt_final between pe.dt_ini and nvl(pe.dt_final,ed_dt_final)))
                           and ((pe.dm_ind_emit is null)  or (nvl(pe.dm_ind_emit,9)  = nvl(en_dm_ind_emit,9)))
                           and ((pe.dm_ind_oper is null)  or (nvl(pe.dm_ind_oper,9)  = nvl(en_dm_ind_oper,9)))
                           and ((pe.modfiscal_id is null) or (nvl(pe.modfiscal_id,0) = nvl(en_modfiscal_id,0)))
                           and ((pe.pessoa_id is null)    or (nvl(pe.pessoa_id,0)    = nvl(en_pessoa_id,0)))
                           and ((pe.cfop_id is null)      or (nvl(pe.cfop_id,0)      = nvl(en_cfop_id,0)))
                           and ((pe.item_id is null)      or (nvl(pe.item_id,0)      = nvl(en_item_id,0)))
                           and ((pe.ncm_id is null)       or (nvl(pe.ncm_id,0)       = nvl(en_ncm_id,0)))
                           and ((pe.tpservico_id is null) or (nvl(pe.tpservico_id,0) = nvl(en_tpservico_id,0)))
                           and ((pe.cod_st_piscofins is null) or (nvl(pe.cod_st_piscofins,0) =  nvl(en_cod_st_piscofins,0)));
                    
                   exception
                        when others then
                           vn_planoconta_id_pis     := null;
                           vn_centrocusto_id_pis    := null;
                           vn_planoconta_id_cofins  := null;
                           vn_centrocusto_id_cofins := null;
                     end;
                  when others then
                     vn_planoconta_id_pis     := null;
                     vn_centrocusto_id_pis    := null;
                     vn_planoconta_id_cofins  := null;
                     vn_centrocusto_id_cofins := null;
               end;
               --
            end if; -- nvl(vn_empresa_id,0) = nvl(en_empresa_id,0) -- Não é necessário refazer o select, pois as empresas são iguais
            --
         when too_many_rows then
            begin
               select max(pe.planoconta_id_pis)
                    , max(pe.centrocusto_id_pis)
                    , max(pe.planoconta_id_cofins)
                    , max(pe.centrocusto_id_cofins)
                 into vn_planoconta_id_pis
                    , vn_centrocusto_id_pis
                    , vn_planoconta_id_cofins
                    , vn_centrocusto_id_cofins
                 from param_efd_contr_geral pe
                where pe.empresa_id = en_empresa_id -- empresa enviada no parâmetro (matriz ou filial)
                  and ed_dt_ini between pe.dt_ini and nvl(pe.dt_final,ed_dt_ini)
                  and ((pe.dt_final is null)
                        or
                       (ed_dt_final is not null and
                        ed_dt_final between pe.dt_ini and nvl(pe.dt_final,ed_dt_final)))
                  and ((pe.dm_ind_emit is null)  or (nvl(pe.dm_ind_emit,9)  = nvl(en_dm_ind_emit,9)))
                  and ((pe.dm_ind_oper is null)  or (nvl(pe.dm_ind_oper,9)  = nvl(en_dm_ind_oper,9)))
                  and ((pe.modfiscal_id is null) or (nvl(pe.modfiscal_id,0) = nvl(en_modfiscal_id,0)))
                  and ((pe.pessoa_id is null)    or (nvl(pe.pessoa_id,0)    = nvl(en_pessoa_id,0)))
                  and ((pe.cfop_id is null)      or (nvl(pe.cfop_id,0)      = nvl(en_cfop_id,0)))
                  and ((pe.item_id is null)      or (nvl(pe.item_id,0)      = nvl(en_item_id,0)))
                  and ((pe.ncm_id is null)       or (nvl(pe.ncm_id,0)       = nvl(en_ncm_id,0)))
                  and ((pe.tpservico_id is null) or (nvl(pe.tpservico_id,0) = nvl(en_tpservico_id,0)))
                  and ((pe.cod_st_piscofins is null) or (nvl(pe.cod_st_piscofins,0) =  nvl(en_cod_st_piscofins,0)));
            exception
               when others then
                  vn_planoconta_id_pis     := null;
                  vn_centrocusto_id_pis    := null;
                  vn_planoconta_id_cofins  := null;
                  vn_centrocusto_id_cofins := null;
            end;
         when others then
            vn_planoconta_id_pis     := null;
            vn_centrocusto_id_pis    := null;
            vn_planoconta_id_cofins  := null;
            vn_centrocusto_id_cofins := null;
      end;
      --
      if ev_ret = 'PCTA_PIS' and nvl(vn_planoconta_id_pis,0) <> 0 then
         vn_ret_id := vn_planoconta_id_pis;
      elsif ev_ret = 'CCTO_PIS' and  nvl(vn_centrocusto_id_pis,0) <> 0 then
            vn_ret_id := vn_centrocusto_id_pis;
      elsif ev_ret = 'PCTA_COF' and  nvl(vn_planoconta_id_cofins,0) <> 0 then
            vn_ret_id := vn_planoconta_id_cofins;
      elsif ev_ret = 'CCTO_COF' and  nvl(vn_centrocusto_id_cofins,0) <> 0 then
            vn_ret_id := vn_centrocusto_id_cofins;
      end if;
      --
   end if;
   --
   if nvl(vn_ret_id,0) = 0 then -- Identificador ainda não encontrado
      --
      for r_reg in c_dados
      loop
         --
         exit when c_dados%notfound or (c_dados%notfound);
         --
         if en_dm_ind_emit is null then
            --
            if en_dm_ind_oper is null then
               --
               if en_modfiscal_id is null then
                  --
                  if en_pessoa_id is null then
                     --
                     if en_cfop_id is null then
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     else -- en_cfop_id is not null
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     end if; -- en_cfop_id is null
                     --
                  else -- en_pessoa_id is not null
                     --
                     if en_cfop_id is null then
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     else -- en_cfop_id is not null
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     end if; -- en_cfop_id is null
                     --
                  end if; -- en_pessoa_id is null
                  --
               else -- en_modfiscal_id is not null
                  --
                  if en_pessoa_id is null then
                     --
                     if en_cfop_id is null then
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     else -- en_cfop_id is not null
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     end if; -- en_cfop_id is null
                     --
                  else -- en_pessoa_id is not null
                     --
                     if en_cfop_id is null then
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     else -- en_cfop_id is not null
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     end if; -- en_cfop_id is null
                     --
                  end if; -- en_pessoa_id is null
                  --
               end if; -- en_modfiscal_id is null
               --
            else -- en_dm_ind_oper is not null
               --
               if en_modfiscal_id is null then
                  --
                  if en_pessoa_id is null then
                     --
                     if en_cfop_id is null then
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     else -- en_cfop_id is not null
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     end if; -- en_cfop_id is null
                     --
                  else -- en_pessoa_id is not null
                     --
                     if en_cfop_id is null then
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     else -- en_cfop_id is not null
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     end if; -- en_cfop_id is null
                     --
                  end if; -- en_pessoa_id is null
                  --
               else -- en_modfiscal_id is not null
                  --
                  if en_pessoa_id is null then
                     --
                     if en_cfop_id is null then
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     else -- en_cfop_id is not null
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     end if; -- en_cfop_id is null
                     --
                  else -- en_pessoa_id is not null
                     --
                     if en_cfop_id is null then
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     else -- en_cfop_id is not null
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit is null and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     end if; -- en_cfop_id is null
                     --
                  end if; -- en_pessoa_id is null
                  --
               end if; -- en_modfiscal_id is null
               --
            end if; -- en_dm_ind_oper is null
            --
         else -- en_dm_ind_emit is not null
            --
            if en_dm_ind_oper is null then
               --
               if en_modfiscal_id is null then
                  --
                  if en_pessoa_id is null then
                     --
                     if en_cfop_id is null then
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     else -- en_cfop_id is not null
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     end if; -- en_cfop_id is null
                     --
                  else -- en_pessoa_id is not null
                     --
                     if en_cfop_id is null then
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     else -- en_cfop_id is not null
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     end if; -- en_cfop_id is null
                     --
                  end if; -- en_pessoa_id is null
                  --
               else -- en_modfiscal_id is not null
                  --
                  if en_pessoa_id is null then
                     --
                     if en_cfop_id is null then
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     else -- en_cfop_id is not null
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     end if; -- en_cfop_id is null
                     --
                  else -- en_pessoa_id is not null
                     --
                     if en_cfop_id is null then
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     else -- en_cfop_id is not null
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper is null and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     end if; -- en_cfop_id is null
                     --
                  end if; -- en_pessoa_id is null
                  --
               end if; -- en_modfiscal_id is null
               --
            else -- en_dm_ind_oper is not null
               --
               if en_modfiscal_id is null then
                  --
                  if en_pessoa_id is null then
                     --
                     if en_cfop_id is null then
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     else -- en_cfop_id is not null
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     end if; -- en_cfop_id is null
                     --
                  else -- en_pessoa_id is not null
                     --
                     if en_cfop_id is null then
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     else -- en_cfop_id is not null
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id is null and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     end if; -- en_cfop_id is null
                     --
                  end if; -- en_pessoa_id is null
                  --
               else -- en_modfiscal_id is not null
                  --
                  if en_pessoa_id is null then
                     --
                     if en_cfop_id is null then
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     else -- en_cfop_id is not null
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id is null and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     end if; -- en_cfop_id is null
                     --
                  else -- en_pessoa_id is not null
                     --
                     if en_cfop_id is null then
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id is null and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     else -- en_cfop_id is not null
                        --
                        if en_item_id is null then
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id is null and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        else -- en_item_id is not null
                           --
                           if en_ncm_id is null then
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id is null and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           else -- en_ncm_id is not null
                              --
                              if en_tpservico_id is null then
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id is null then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              else -- en_tpservico_id is not null
                                 --
                                 if r_reg.dm_ind_emit = en_dm_ind_emit and
                                    r_reg.dm_ind_oper = en_dm_ind_oper and
                                    r_reg.modfiscal_id = en_modfiscal_id and
                                    r_reg.pessoa_id = en_pessoa_id and
                                    r_reg.cfop_id = en_cfop_id and
                                    r_reg.item_id = en_item_id and
                                    r_reg.ncm_id = en_ncm_id and
                                    r_reg.tpservico_id = en_tpservico_id then
                                    --
                                    vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
                                    vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
                                    vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
                                    vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
                                    --
                                 end if;
                                 --
                              end if; -- en_tpservico_id is null
                              --
                           end if; -- en_ncm_id is null
                           --
                        end if; -- en_item_id is null
                        --
                     end if; -- en_cfop_id is null
                     --
                  end if; -- en_pessoa_id is null
                  --
               end if; -- en_modfiscal_id is null
               --
            end if; -- en_dm_ind_oper is null
            --
         end if; -- en_dm_ind_emit is null
         --
         if nvl(vn_planoconta_id_pis,0) = 0 then
            --
            if r_reg.dm_ind_emit = en_dm_ind_emit and
               r_reg.dm_ind_oper is null and
               r_reg.modfiscal_id is null and
               r_reg.pessoa_id is null and
               r_reg.cfop_id is null and
               r_reg.item_id is null and
               r_reg.ncm_id is null and
               r_reg.tpservico_id is null then
               --
               vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
               vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
               vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
               vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
               --
            end if;
            --
            if r_reg.dm_ind_emit is null and
               r_reg.dm_ind_oper = en_dm_ind_oper and
               r_reg.modfiscal_id is null and
               r_reg.pessoa_id is null and
               r_reg.cfop_id is null and
               r_reg.item_id is null and
               r_reg.ncm_id is null and
               r_reg.tpservico_id is null then
               --
               vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
               vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
               vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
               vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
               --
            end if;
            --
            if r_reg.dm_ind_emit is null and
               r_reg.dm_ind_oper is null and
               r_reg.modfiscal_id = en_modfiscal_id and
               r_reg.pessoa_id is null and
               r_reg.cfop_id is null and
               r_reg.item_id is null and
               r_reg.ncm_id is null and
               r_reg.tpservico_id is null then
               --
               vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
               vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
               vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
               vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
               --
            end if;
            --
            if r_reg.dm_ind_emit is null and
               r_reg.dm_ind_oper is null and
               r_reg.modfiscal_id is null and
               r_reg.pessoa_id = en_pessoa_id and
               r_reg.cfop_id is null and
               r_reg.item_id is null and
               r_reg.ncm_id is null and
               r_reg.tpservico_id is null then
               --
               vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
               vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
               vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
               vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
               --
            end if;
            --
            if r_reg.dm_ind_emit is null and
               r_reg.dm_ind_oper is null and
               r_reg.modfiscal_id is null and
               r_reg.pessoa_id is null and
               r_reg.cfop_id = en_cfop_id and
               r_reg.item_id is null and
               r_reg.ncm_id is null and
               r_reg.tpservico_id is null then
               --
               vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
               vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
               vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
               vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
               --
            end if;
            --
            if r_reg.dm_ind_emit is null and
               r_reg.dm_ind_oper is null and
               r_reg.modfiscal_id is null and
               r_reg.pessoa_id is null and
               r_reg.cfop_id is null and
               r_reg.item_id = en_item_id and
               r_reg.ncm_id is null and
               r_reg.tpservico_id is null then
               --
               vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
               vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
               vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
               vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
               --
            end if;
            --
            if r_reg.dm_ind_emit is null and
               r_reg.dm_ind_oper is null and
               r_reg.modfiscal_id is null and
               r_reg.pessoa_id is null and
               r_reg.cfop_id is null and
               r_reg.item_id is null and
               r_reg.ncm_id = en_ncm_id and
               r_reg.tpservico_id is null then
               --
               vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
               vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
               vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
               vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
               --
            end if;
            --
            if r_reg.dm_ind_emit is null and
               r_reg.dm_ind_oper is null and
               r_reg.modfiscal_id is null and
               r_reg.pessoa_id is null and
               r_reg.cfop_id is null and
               r_reg.item_id is null and
               r_reg.ncm_id is null and
               r_reg.tpservico_id = en_tpservico_id then
               --
               vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
               vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
               vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
               vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
               --
            end if;
            --
            if r_reg.dm_ind_emit is null and
               r_reg.dm_ind_oper is null and
               r_reg.modfiscal_id is null and
               r_reg.pessoa_id is null and
               r_reg.cfop_id is null and
               r_reg.item_id is null and
               r_reg.ncm_id is null and
               r_reg.tpservico_id is null then
               --
               vn_planoconta_id_pis     := r_reg.planoconta_id_pis;
               vn_centrocusto_id_pis    := r_reg.centrocusto_id_pis;
               vn_planoconta_id_cofins  := r_reg.planoconta_id_cofins;
               vn_centrocusto_id_cofins := r_reg.centrocusto_id_cofins;
               --
            end if;
            --
         end if;
         --
         if ev_ret = 'PCTA_PIS' and nvl(vn_planoconta_id_pis,0) <> 0 then
            vn_ret_id := vn_planoconta_id_pis;
            exit;
         elsif ev_ret = 'CCTO_PIS' and  nvl(vn_centrocusto_id_pis,0) <> 0 then
               vn_ret_id := vn_centrocusto_id_pis;
               exit;
         elsif ev_ret = 'PCTA_COF' and  nvl(vn_planoconta_id_cofins,0) <> 0 then
               vn_ret_id := vn_planoconta_id_cofins;
               exit;
         elsif ev_ret = 'CCTO_COF' and  nvl(vn_centrocusto_id_cofins,0) <> 0 then
               vn_ret_id := vn_centrocusto_id_cofins;
               exit;
         end if;
         --
      end loop;
      --
   end if; -- nvl(vn_ret_id,0) = 0 -- Identificador ainda não encontrado
   --
   return(vn_ret_id);
   --
exception
   when others then
      raise_application_error(-20101, 'Problemas em fkb_recup_pcta_ccto_pc. Parâmetros: en_empresa_id = '||en_empresa_id||', en_dm_ind_emit = '||en_dm_ind_emit||
                                      ', en_dm_ind_oper = '||en_dm_ind_oper||', en_modfiscal_id = '||en_modfiscal_id||', en_pessoa_id = '||en_pessoa_id||
                                      ', en_cfop_id = '||en_cfop_id||', en_item_id = '||en_item_id||', en_ncm_id = '||en_ncm_id||', en_tpservico_id = '||
                                      en_tpservico_id||', ed_dt_ini = '||ed_dt_ini||', ed_dt_final = '||ed_dt_final||', ev_ret = '||ev_ret||'. Erro: '||sqlerrm);
end fkb_recup_pcta_ccto_pc;

---------------------------------------------------------------------------------------------------------------
-- Procedimento retorna o parâmetro que Permite a quebra da Informação Adicional no arquivo Sped Contribuições
function fkg_parefdcontr_dmqueinfadi ( en_empresa_id in empresa.id%type )
         return param_efd_contr.dm_quebra_infadic_spedc%type
is
   --
   vn_dm_quebra_infadic_spedc param_efd_contr.dm_quebra_infadic_spedc%type;
   --
begin
   --
   select pe.dm_quebra_infadic_spedc
     into vn_dm_quebra_infadic_spedc
     from param_efd_contr pe
    where pe.empresa_id = en_empresa_id;
   --
   return vn_dm_quebra_infadic_spedc;
   --
exception
   when others then
      return 0;
end fkg_parefdcontr_dmqueinfadi;

----------------------------------------------------------------------------------------------------------

end pk_csf_efd_pc;
/
