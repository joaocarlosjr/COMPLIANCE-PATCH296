create or replace package body csf_own.pk_csf_secf is

-------------------------------------------------------------------------------------------------------
-- Corpo do pacote de funções para o Sped ECF
-------------------------------------------------------------------------------------------------------
-- Retorna a sigla do pais conforme o codigo informado do identificador
function fkg_pais_id_sigla_pais ( en_pais_id in pais.id%type
                                ) return pais.sigla_pais%type
is
   --
   vv_sigla_pais                pais.sigla_pais%type;
   --
begin
   --
   vv_sigla_pais := null;
   --
   if nvl(en_pais_id,0) > 0 then
      --
      select sigla_pais
        into vv_sigla_pais
        from pais
       where id = en_pais_id;
      --
   end if;
   --
   return vv_sigla_pais;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_pais_id_sigla_pais:' || sqlerrm);
end fkg_pais_id_sigla_pais;
-------------------------------------------------------------------------------------------------------
-- Retorna o código da tabela de Identificação de Sócios ou Titular Y600
function fkg_identsocioig_id ( en_empresa_id          in empresa.id%type
                             , en_pessoa_id           in pessoa.id%type
                             , ed_dt_alt_soc          in ident_socio_ig.dt_alt_soc%type
                             , ev_dm_ind_qualif_socio in ident_socio_ig.dm_ind_qualif_socio%type
                             , en_pessoa_id_rptl      in ident_socio_ig.pessoa_id_rptl%type
                             ) return ident_socio_ig.id%type
is
   --
   vn_identsocioig_id        ident_socio_ig.id%type;
   --
begin
   --
   select id
     into vn_identsocioig_id
     from ident_socio_ig
    where empresa_id            = en_empresa_id
      and pessoa_id             = en_pessoa_id
      and dt_alt_soc            = ed_dt_alt_soc
      and dm_ind_qualif_socio   = ev_dm_ind_qualif_socio
      and nvl(pessoa_id_rptl,0) = nvl(en_pessoa_id_rptl,0);
   --
   return vn_identsocioig_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_identsocioig_id:' || sqlerrm);
end fkg_identsocioig_id;
-------------------------------------------------------------------------------------------------------
-- Retorna o código da tabela de Demonstrativo do Livro Caixa - Q100
function fkg_demlivrocaixa_id ( en_empresa_id in abertura_ecf.id%type
                              , ed_dt_demon   in dem_livro_caixa.dt_demon%type
                              ) return dem_livro_caixa.id%type
is
   --
   vn_demlivrocaixa_id        dem_livro_caixa.id%type;
   --
begin
   --
   select id
     into vn_demlivrocaixa_id
     from dem_livro_caixa
    where empresa_id = en_empresa_id
      and dt_demon   = ed_dt_demon;
   --
   return vn_demlivrocaixa_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_demlivrocaixa_id:' || sqlerrm);
end fkg_demlivrocaixa_id;

-------------------------------------------------------------------------------------------------------
-- Retorna o código da tabela de Informações de Optantes pelo Refis ¿ Imunes ou Isentas Y682
function fkg_infooptrefisiiig_id ( en_aberturaecf_id in abertura_ecf.id%type
                                 , ev_dm_mes         in info_opt_refis_ii_ig.dm_mes%type
                                 ) return info_opt_refis_ii_ig.id%type
is
   --
   vn_infooptrefisiiig_id        info_opt_refis_ii_ig.id%type;
   --
begin
   --
   select id
     into vn_infooptrefisiiig_id
     from info_opt_refis_ii_ig
    where aberturaecf_id = en_aberturaecf_id
      and dm_mes         = ev_dm_mes;
   --
   return vn_infooptrefisiiig_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_infooptrefisiiig_id:' || sqlerrm);
end fkg_infooptrefisiiig_id;
-------------------------------------------------------------------------------------------------------
-- Retorna o código da tabela de Informações de Optantes pelo PAES Y690
function pkb_infooptpaesig_id ( en_aberturaecf_id in abertura_ecf.id%type
                              , ev_dm_mes         in info_opt_paes_ig.dm_mes%type
                              ) return info_opt_paes_ig.id%type
is
   --
   vn_infooptpaesig_id        info_opt_paes_ig.id%type;
   --
begin
   --
   select id
     into vn_infooptpaesig_id
     from info_opt_paes_ig
    where aberturaecf_id = en_aberturaecf_id
      and dm_mes         = ev_dm_mes;
   --
   return vn_infooptpaesig_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na pkb_infooptpaesig_id:' || sqlerrm);
end pkb_infooptpaesig_id;
-------------------------------------------------------------------------------------------------------
-- Retorna o código da tabela de Informações de Períodos Anteriore - Y720
function fkg_infperantig_id ( en_empresa_id in empresa.id%type
                            , en_ano_ref    in inf_per_ant_ig.ano_ref%Type
                            ) return inf_per_ant_ig.id%type
is
   --
   vn_infperantig_id        inf_per_ant_ig.id%type;
   --
begin
   --
   select id
     into vn_infperantig_id
     from inf_per_ant_ig
    where empresa_id = en_empresa_id
      and ano_ref    = en_ano_ref;
   --
   return vn_infperantig_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_infperantig_id:' || sqlerrm);
end fkg_infperantig_id;
-------------------------------------------------------------------------------------------------------
-- Retorna o código da tabela de Demonstrativo das Diferenças na Adoção Inicial Y665
function fkg_detinfooptrefislrapig_id ( en_infooptrefislrapig_id in info_opt_refis_lrap_ig.id%type
                                      , en_tabdinecf_id          in tab_din_ecf.id%type
                                      ) return det_info_opt_refis_lrap_ig.id%type
is
   --
   vn_detinfooptrefislrapig_id        det_info_opt_refis_lrap_ig.id%type;
   --
begin
   --
   select id
     into vn_detinfooptrefislrapig_id
     from det_info_opt_refis_lrap_ig
    where infooptrefislrapig_id = en_infooptrefislrapig_id
      and tabdinecf_id          = en_tabdinecf_id;
   --
   return vn_detinfooptrefislrapig_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_detinfooptrefislrapig_id:' || sqlerrm);
end fkg_detinfooptrefislrapig_id;
-------------------------------------------------------------------------------------------------------
-- Retorna o código da tabela de Demonstrativo das Diferenças na Adoção Inicial Y665
function fkg_demdifadiniig_id ( en_empresa_id     in empresa.id%type
                              , en_ano_ref        in dem_dif_ad_ini_ig.ano_ref%type
                              , en_planoconta_id  in plano_conta.id%type
                              , en_centrocusto_id in centro_custo.id%type
                              ) return dem_dif_ad_ini_ig.id%type
is
   --
   vn_demdifadiniig_id        dem_dif_ad_ini_ig.id%type;
   --
begin
   --
   select id
     into vn_demdifadiniig_id
     from dem_dif_ad_ini_ig
    where empresa_id            = en_empresa_id
      and ano_ref               = en_ano_ref
      and planoconta_id         = en_planoconta_id
      and nvl(centrocusto_id,0) = nvl(en_centrocusto_id,0);
   --
   return vn_demdifadiniig_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_demdifadiniig_id:' || sqlerrm);
end fkg_demdifadiniig_id;
-------------------------------------------------------------------------------------------------------
-- Retorna o código da tabela de Detalhamento de Participações em Consórcios de Empresas Y650
function fkg_detpartconsemprig_id ( en_partconsemprig_id in part_cons_empr_ig.id%type
                                  , en_pessoa_id         in pessoa.id%type
                                  ) return det_part_cons_empr_ig.id%type
is
   --
   vn_detpartconsemprig_id        det_part_cons_empr_ig.id%type;
   --
begin
   --
   select id
     into vn_detpartconsemprig_id
     from det_part_cons_empr_ig
    where partconsemprig_id = en_partconsemprig_id
      and pessoa_id         = en_pessoa_id;
   --
   return vn_detpartconsemprig_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_detpartconsemprig_id:' || sqlerrm);
end fkg_detpartconsemprig_id;
-------------------------------------------------------------------------------------------------------
-- Retorna o código da tabela de Participações em Consórcios de Empresas Y640
function fkg_partconsemprig_id ( en_empresa_id in empresa.id%type
                               , en_ano_ref    in part_cons_empr_ig.ano_ref%type
                               , en_pessoa_id  in pessoa.id%type
                               ) return part_cons_empr_ig.id%type
is
   --
   vn_partconsemprig_id        part_cons_empr_ig.id%type := null;
   --
begin
   --
   select id
     into vn_partconsemprig_id
     from part_cons_empr_ig
    where empresa_id = en_empresa_id
      and ano_ref    = en_ano_ref
      and pessoa_id  = en_pessoa_id;
   --
   return vn_partconsemprig_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_partconsemprig_id:' || sqlerrm);
end fkg_partconsemprig_id;
-------------------------------------------------------------------------------------------------------
-- Retornar o código da tabela de Outras Informações (Lucro Presumido ou Lucro Arbitrado) Y672
function fkg_outrainflplaig_id ( en_empresa_id in empresa.id%type
                               , en_ano_ref    in outra_inf_lp_la_ig.ano_ref%type
                               ) return outra_inf_lp_la_ig.id%type
is
   --
   vn_outrainflplaig_id        outra_inf_lp_la_ig.id%type;
   --
begin
   --
   select id
     into vn_outrainflplaig_id
     from outra_inf_lp_la_ig
    where empresa_id  = en_empresa_id
      and ano_ref     = en_ano_ref;
   --
   return vn_outrainflplaig_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_outrainflplaig_id:' || sqlerrm);
end fkg_outrainflplaig_id;
-------------------------------------------------------------------------------------------------------
-- Retorna o código da tabela de Outras Informações (Lucro Real) Y671
function fkg_outrainflrig_id ( en_empresa_id in empresa.id%type
                             , en_ano_ref    in outra_inf_lr_ig.ano_ref%type
                             ) return outra_inf_lr_ig.id%type
is
   --
   vn_outrainflrig_id        outra_inf_lr_ig.id%type;
   --
begin
   --
   select id
     into vn_outrainflrig_id
     from outra_inf_lr_ig
    where empresa_id  = en_empresa_id
      and ano_ref     = en_ano_ref;
   --
   return vn_outrainflrig_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_outrainflrig_id:' || sqlerrm);
end fkg_outrainflrig_id;

-------------------------------------------------------------------------------------------------------
-- Retorna o código da tabela de Dados de Sucessoras Y660
function fkg_dadosucessoraig_id( en_empresa_id in empresa.id%type
                               , en_ano_ref    in dado_sucessora_ig.ano_ref%type
                               , en_pessoa_id  in pessoa.id%type
                               ) return dado_sucessora_ig.id%type
is
   --
   vn_dadosucessoraig_id       dado_sucessora_ig.id%type;
   --
begin
   --
   select id
     into vn_dadosucessoraig_id
     from dado_sucessora_ig
    where empresa_id  = en_empresa_id
      and ano_ref     = en_ano_ref   
      and pessoa_id   = en_pessoa_id;
   --
   return vn_dadosucessoraig_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_dadosucessoraig_id:' || sqlerrm);
end fkg_dadosucessoraig_id;

-------------------------------------------------------------------------------------------------------
-- Retorna o código da tabela de Fundos/Clubes de Investimento Y630
function fkg_fundoinvestig_id ( en_empresa_id in empresa.id%type
                              , en_ano_ref    in fundo_invest_ig.ano_ref%type
                              , en_pessoa_id  in pessoa.id%type
                              ) return fundo_invest_ig.id%type
is
   --
   vn_fundoinvestig_id        fundo_invest_ig.id%type;
   --
begin
   --
   select id 
     into vn_fundoinvestig_id
     from fundo_invest_ig
    where empresa_id = en_empresa_id
      and ano_ref    = en_ano_ref   
      and pessoa_id  = en_pessoa_id;
   --
   return vn_fundoinvestig_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_fundoinvestig_id:' || sqlerrm);
end fkg_fundoinvestig_id;
-------------------------------------------------------------------------------------------------------
-- Retorna o código da tabela de Participações Avaliadas Pelo Método de Equivalência Patrimonial Y620
function fkb_partavameteqpatrig_id ( en_empresa_id   in empresa.id%type
                                   , en_ano_ref      in part_ava_met_eq_patr_ig.ano_ref%type
                                   , en_pessoa_id    in pessoa.id%type
                                   , ed_dt_evento    in part_ava_met_eq_patr_ig.dt_evento%type
                                   , en_dm_ind_relac in part_ava_met_eq_patr_ig.dm_ind_relac%type
                                   ) return part_ava_met_eq_patr_ig.id%type
is
   --
   vn_partavameteqpatrig_id           part_ava_met_eq_patr_ig.id%type;
   --
begin
   --
   select id
     into vn_partavameteqpatrig_id
     from part_ava_met_eq_patr_ig
    where empresa_id    = en_empresa_id
      and ano_ref       = en_ano_ref
      and pessoa_id     = en_pessoa_id
      and ed_dt_evento  = dt_evento
      and dm_ind_relac  = en_dm_ind_relac;
   --
   return vn_partavameteqpatrig_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkb_partavameteqpatrig_id:' || sqlerrm);
end fkb_partavameteqpatrig_id;

-------------------------------------------------------------------------------------------------------
-- Retorna o código da tabela de Rendimentos de Dirigentes e Conselheiros ¿ Imunes ou Isentas Y612
function fkg_renddirigiiig_id ( en_empresa_id in empresa.id%type
                              , en_ano_ref    in rend_dirig_ii_ig.ano_ref%type
                              , en_pessoa_id  in rend_dirig_ii_ig.pessoa_id%type
                              , ev_dm_qualif  in rend_dirig_ii_ig.dm_qualif%type
                              ) return rend_dirig_ii_ig.id%type
is
   --
   vn_renddirigiiig_id        rend_dirig_ii_ig.id%type;
   --
begin
   --
   select id
     into vn_renddirigiiig_id
     from rend_dirig_ii_ig
    where empresa_id = en_empresa_id
      and ano_ref    = en_ano_ref   
      and pessoa_id  = en_pessoa_id 
      and dm_qualif  = ev_dm_qualif;
   --
   return vn_renddirigiiig_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_renddirigiiig_id:' || sqlerrm);
end fkg_renddirigiiig_id;
-------------------------------------------------------------------------------------------------------
-- Retorna o código da tabela de Ativos no Exterior Y590
function fkg_ativoexteriorig_id( en_empresa_id      in empresa.id%type
                               , en_ano_ref         in ativo_exterior_ig.ano_ref%type
                               , en_tipoativoecf_id in ativo_exterior_ig.tipoativoecf_id%type
                               , ev_discrim         in ativo_exterior_ig.discrim%type
                               ) return ativo_exterior_ig.id%type
is
   --
   vn_ativoexteriorig_id       ativo_exterior_ig.id%type;
   --
begin
   --
   select id
     into vn_ativoexteriorig_id
     from ativo_exterior_ig
    where empresa_id      = en_empresa_id
      and ano_ref         = en_ano_ref
      and tipoativoecf_id = en_tipoativoecf_id
      and discrim         = ev_discrim;
   --
   return vn_ativoexteriorig_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_ativoexteriorig_id:' || sqlerrm);
end fkg_ativoexteriorig_id;
-------------------------------------------------------------------------------------------------------
-- Retorna o código da tabela de Doações a Campanhas Eleitorais Y580
function fkg_doaccampeleitig_id ( en_empresa_id in empresa.id%type
                                , en_ano_ref    in dem_ir_csll_rf_ig.ano_ref%type
                                , en_pessoa_id  in pessoa.id%type
                                ) return doac_camp_eleit_ig.id%type
is
   --
   vn_doaccampeleitig_id       doac_camp_eleit_ig.id%type;
   --
begin
   --
   select id
     into vn_doaccampeleitig_id
     from doac_camp_eleit_ig
    where empresa_id = en_empresa_id
      and ano_ref    = en_ano_ref   
      and pessoa_id  = en_pessoa_id;
   --
   return vn_doaccampeleitig_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_doaccampeleitig_id:' || sqlerrm);
end fkg_doaccampeleitig_id;

-------------------------------------------------------------------------------------------------------
-- Retorna o código da tabela de Demonstrativo do Imposto de Renda e CSLL Retidos na Fonte Y570
function fkg_demircsllrfig_id ( en_empresa_id    in empresa.id%type
                              , en_ano_ref       in dem_ir_csll_rf_ig.ano_ref%type
                              , en_pessoa_id     in pessoa.id%type
                              , en_tiporetimp_id in tipo_ret_imp.id%type
                              ) return dem_ir_csll_rf_ig.id%type
is
   --
   vn_demircsllrfig_id        dem_ir_csll_rf_ig.id%type;
   --
begin
   --
   select id
     into vn_demircsllrfig_id
     from dem_ir_csll_rf_ig
    where empresa_id    = en_empresa_id
      and ano_ref       = en_ano_ref      
      and pessoa_id     = en_pessoa_id    
      and tiporetimp_id = en_tiporetimp_id;
   --
   return vn_demircsllrfig_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_demircsllrfig_id:' || sqlerrm);
end fkg_demircsllrfig_id;

-------------------------------------------------------------------------------------------------------
-- Retorna o código da tabela de Detalhamento das Exportações da Comercial Exportadora Y560
function fkg_detexpcomig_id ( en_empresa_id       in empresa.id%TYPE
                            , en_ano_ref          in det_exp_com_ig.ano_ref%type
                            /*, en_empresa_id_estab in empresa.id%TYPE*/
                            , en_pessoa_id_part   in det_exp_com_ig.pessoa_id_part%type
                            , en_ncm_id           in ncm.id%type
                            ) return det_exp_com_ig.id%type
is
   --
   vn_detexpcomig_id        det_exp_com_ig.id%type;
   --
begin
   --
   select id
     into vn_detexpcomig_id
     from det_exp_com_ig
    where empresa_id       = en_empresa_id
      and ano_ref          = en_ano_ref         
      /*and empresa_id_estab = en_empresa_id_estab*/
      and ncm_id           = en_ncm_id
      and pessoa_id_part   = en_pessoa_id_part;
   --
   return vn_detexpcomig_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_detexpcomig_id:' || sqlerrm);
end fkg_detexpcomig_id;


-------------------------------------------------------------------------------------------------------
-- Retorna o código da tabela de Vendas a Comercial Exportadora com Fim Específico de Exportação Y550
function fkg_vendcomfimexpig_id ( en_empresa_id in empresa.id%TYPE
                                , en_ano_ref    in vend_com_fim_exp_ig.ano_ref%type
                                , en_pessoa_id  in pessoa.id%type
                                , en_ncm_id     in ncm.id%type
                                ) return vend_com_fim_exp_ig.id%type
is
   --
   vn_vendcomfimexpig_id        vend_com_fim_exp_ig.id%type;
   --
begin
   --
   select id
     into vn_vendcomfimexpig_id
     from vend_com_fim_exp_ig
    where empresa_id       = en_empresa_id
      and ano_ref          = en_ano_ref 
      and pessoa_id        = en_pessoa_id
      and ncm_id           = en_ncm_id;
   --
   return vn_vendcomfimexpig_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_vendcomfimexpig_id:' || sqlerrm);
end fkg_vendcomfimexpig_id;

-------------------------------------------------------------------------------------------------------
-- Retorna o código da tabela Discr. da Receita de Vendas dos Estab. por Ativ. Econômica Y540
function fkg_descrrecestabcnaeig_id ( en_empresa_id       in empresa.id%TYPE
                                    , en_ano_ref          in descr_rec_estab_cnae_ig.ano_ref%type
                                    , en_empresa_id_estab in empresa.id%TYPE
                                    , en_cnae_id          in cnae.id%type
                                    ) return descr_rec_estab_cnae_ig.id%type
is
   --
   vn_descrrecestabcnaeig_id        descr_rec_estab_cnae_ig.id%type;
   --
begin
   --
   select id
     into vn_descrrecestabcnaeig_id
     from descr_rec_estab_cnae_ig
    where empresa_id       = en_empresa_id
      and ano_ref          = en_ano_ref         
      and empresa_id_estab = en_empresa_id_estab
      and cnae_id          = en_cnae_id;
   --
   return vn_descrrecestabcnaeig_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_prextnresidig_id:' || sqlerrm);
end fkg_descrrecestabcnaeig_id;



-------------------------------------------------------------------------------------------------------
-- Função que retorna o código da tabela de Pagamentos/Recebimentos do Exterior ou de Não Residentes Y520
function fkg_prextnresidig_id ( en_empresa_id    in empresa.id%TYPE
                              , en_ano_ref       in pr_ext_nresid_ig.ano_ref%TYPE
                              , en_pais_id       in pais.id%TYPE
                              , ev_dm_tip_ext    in pr_ext_nresid_ig.dm_tip_ext%TYPE
                              , en_dm_forma      in pr_ext_nresid_ig.dm_forma%TYPE
                              , en_natoperecf_id in nat_oper_ecf.id%TYPE
                              ) return pr_ext_nresid_ig.id%type
is
   --
   vn_prextnresidig_id        pr_ext_nresid_ig.id%type;
   --
begin
   --
   select id
     into vn_prextnresidig_id
     from pr_ext_nresid_ig
    where empresa_id    = en_empresa_id
      and ano_ref       = en_ano_ref
      and pais_id       = en_pais_id
      and dm_tip_ext    = ev_dm_tip_ext
      and dm_forma      = en_dm_forma
      and natoperecf_id = en_natoperecf_id;
   --
   return vn_prextnresidig_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_prextnresidig_id:' || sqlerrm);
end fkg_prextnresidig_id;
-------------------------------------------------------------------------------------------------------
-- Função que retorna o código da tabela de Áreas de Livre Comércio (ALC) (ZPE) X510
function fkg_arealivrecomie_id ( en_aberturaecf_id  in abertura_ecf.id%type
                               , en_tabdinecf_id    in tab_din_ecf.id%type
                               ) return area_livre_com_ie.id%type
is
   --
   vn_arealivrecomie_id        area_livre_com_ie.id%type;
   --
begin
   --
   select id
     into vn_arealivrecomie_id
     from area_livre_com_ie
    where aberturaecf_id = en_aberturaecf_id
      and tabdinecf_id   = en_tabdinecf_id;
   --
   return vn_arealivrecomie_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_arealivrecomie_id:' || sqlerrm);
end fkg_arealivrecomie_id;

-------------------------------------------------------------------------------------------------------
-- Função que retorna o código da tabela de Zonas de Processamento de Exportação (ZPE) X500
function fkg_zonaprocexpie_id ( en_aberturaecf_id in abertura_ecf.id%type
                              , en_tabdinecf_id   in tab_din_ecf.id%type
                              ) return zona_proc_exp_ie.id%type
is
   --
   vn_zonaprocexpie_id        zona_proc_exp_ie.id%type;
   --
begin
   --
   select id
     into vn_zonaprocexpie_id
     from zona_proc_exp_ie
    where aberturaecf_id  = en_aberturaecf_id
      and tabdinecf_id    = en_tabdinecf_id;
   --
   return vn_zonaprocexpie_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_zonaprocexpie_id:' || sqlerrm);
end fkg_zonaprocexpie_id;
-------------------------------------------------------------------------------------------------------
-- Função que retorna o código da tabela de Pólo Industrial de Manaus e Amazônia Ocidental X490
function fkg_pimanausamazocidie_id ( en_aberturaecf_id in abertura_ecf.id%type
                                   , en_tabdinecf_id   in tab_din_ecf.id%type
                                   ) return pi_manaus_amaz_ocid_ie.id%type
is
   --
   vn_pimanausamazocidie_id        pi_manaus_amaz_ocid_ie.id%type;
   --
begin
   --
   select id
     into vn_pimanausamazocidie_id
     from pi_manaus_amaz_ocid_ie
    where aberturaecf_id  = en_aberturaecf_id
      and tabdinecf_id    = en_tabdinecf_id;
   --
   return vn_pimanausamazocidie_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_pimanausamazocidie_id:' || sqlerrm);
end fkg_pimanausamazocidie_id;
-------------------------------------------------------------------------------------------------------
-- Função que retorna o código da tabela do Bloco X480
function fkg_infoextservie_id ( en_aberturaecf_id in abertura_ecf.id%type
                              , en_tabdinecf_id   in tab_din_ecf.id%type
                              ) return info_ext_serv_ie.id%type
is
   --
   vn_infoextservie_id        info_ext_serv_ie.id%type;
   --
begin
   --
   select id
     into vn_infoextservie_id
     from info_ext_serv_ie
    where aberturaecf_id = en_aberturaecf_id
      and tabdinecf_id   = en_tabdinecf_id;
   --
   return vn_infoextservie_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_capinfincldigie_id:' || sqlerrm);
end fkg_infoextservie_id;

-------------------------------------------------------------------------------------------------------
-- Função que retorna o código da tabela de Capacitação de Informática e Inclusão Digital X470
function fkg_capinfincldigie_id ( en_aberturaecf_id in abertura_ecf.id%type
                                , en_tabdinecf_id   in tab_din_ecf.id%type 
                                ) return cap_inf_incl_dig_ie.id%type
is
   --
   vn_capinfincldigie_id        cap_inf_incl_dig_ie.id%type;
   --
begin
   --
   select id
     into vn_capinfincldigie_id
     from cap_inf_incl_dig_ie
    where aberturaecf_id = en_aberturaecf_id
      and tabdinecf_id   = en_tabdinecf_id;
   --
   return vn_capinfincldigie_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_capinfincldigie_id:' || sqlerrm);
end fkg_capinfincldigie_id;
-------------------------------------------------------------------------------------------------------
-- Função que retorna o código da tabela Inovação Tecnológica e Desenvolvimento Tecnológico X460
function fkg_inovtecdesenvie_id ( en_aberturaecf_id in abertura_ecf.id%type
                                , en_tabdinecf_id   in tab_din_ecf.id%type
                                ) return inov_tec_desenv_ie.id%type
is
   --
   vn_inovtecdesenvie_id        inov_tec_desenv_ie.id%type;
   --
begin
   --
   select id
     into vn_inovtecdesenvie_id
     from inov_tec_desenv_ie
    where aberturaecf_id   = en_aberturaecf_id
      and tabdinecf_id     = en_tabdinecf_id;
   --
   return vn_inovtecdesenvie_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_inovtecdesenvie_id:' || sqlerrm);
end fkg_inovtecdesenvie_id;
-------------------------------------------------------------------------------------------------------
-- Função que retorna o código da tabela de Pagamentos/Remessas Relat. a Serviços, Juros e Divid. Recebidos do Brasil e do Exterior X450
function fkg_pagrelextie_id ( en_empresa_id in empresa.id%type
                            , en_ano_ref    in pag_rel_ext_ie.ano_ref%type
                            , en_pais_id    in pais.id%type
                            ) return pag_rel_ext_ie.id%type
is
   --
   vn_pagrelextie_id      pag_rel_ext_ie.id%type;
   --
begin
   --
   select id
     into vn_pagrelextie_id
     from pag_rel_ext_ie
    where empresa_id  = en_empresa_id
      and ano_ref     = en_ano_ref
      and pais_id     = en_pais_id;
   --
   return vn_pagrelextie_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_pagrelextie_id:' || sqlerrm);
end fkg_pagrelextie_id;
-------------------------------------------------------------------------------------------------------
-- Função que retorna o código da tabela de Rend. Relat. a Serv., Juros e Divid. Receb. do Brasil e do Ext. X430
function fkg_rendrelrecebie_id ( en_empresa_id in empresa.id%type
                               , en_ano_ref    in rend_rel_receb_ie.ano_ref%type
                               , en_pais_id    in pais.id%type
                               ) return rend_rel_receb_ie.id%type
is
   --
   vn_rendrelrecebie_id      rend_rel_receb_ie.id%type;
   --
begin
   --
   select id
     into vn_rendrelrecebie_id
     from rend_rel_receb_ie
    where empresa_id  = en_empresa_id
      and ano_ref     = en_ano_ref
      and pais_id     = en_pais_id;
   --
   return vn_rendrelrecebie_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_rendrelrecebie_id:' || sqlerrm);
end fkg_rendrelrecebie_id;

-------------------------------------------------------------------------------------------------------
-- Função que retorna o código da tabela de Royalties Rec. ou Pagos a Benef. do Brasil e do Ext. X420
function fkg_royrpbenfie_id ( en_empresa_id in empresa.id%type
                            , en_ano_ref    in roy_rp_benf_ie.ano_ref%type
                            , en_pais_id    in pais.id%type
                            , ev_dm_tip_roy in roy_rp_benf_ie.dm_tip_roy%type
                            ) return roy_rp_benf_ie.id%type
is
   --
   vn_royrpbenfie_id        roy_rp_benf_ie.id%type;
   --
begin
   --
   vn_royrpbenfie_id := null;
   --
   select id
     into vn_royrpbenfie_id
     from roy_rp_benf_ie
    where empresa_id = en_empresa_id
      and ano_ref    = en_ano_ref
      and pais_id    = en_pais_id
      and dm_tip_roy = ev_dm_tip_roy;
   --
   return vn_royrpbenfie_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_royrpbenfie_id:' || sqlerrm);
end fkg_royrpbenfie_id;
-------------------------------------------------------------------------------------------------------
-- Função que retorna o código da tabela Origem e Aplicação de Recursos, Imunes e Isentas X390    
function fkg_oraplreciiie_id ( en_aberturaecf_id in abertura_ecf.id%type
                             , en_tabdinecf_id   in tab_din_ecf.id%type
                             ) return or_apl_rec_ii_ie.id%type
is
   --
   vn_oraplreciiie_id        or_apl_rec_ii_ie.id%type;
   --
begin
   --
   vn_oraplreciiie_id := null;
   --
   select id
     into vn_oraplreciiie_id
     from or_apl_rec_ii_ie
    where aberturaecf_id = en_aberturaecf_id
      and tabdinecf_id = en_tabdinecf_id;
   --
   return vn_oraplreciiie_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_oraplreciiie_id:' || sqlerrm);
end fkg_oraplreciiie_id;
-------------------------------------------------------------------------------------------------------
-- Função que retorna o código da tabela Comércio Eletrônico ¿ Informação de Homepage/Servidor
function fkg_comeletinfie_id ( en_empresa_id   in empresa.id%type
                             , en_ano_ref      in com_elet_inf_ie.ano_ref%type
                             , en_pais_id      in pais.id%type
                             ) return com_elet_inf_ie.id%type
is
   --
   vn_comeleinfie_id   com_elet_inf_ie.id%type;
   --
begin
   --
   vn_comeleinfie_id := null;
   --
   select id
     into vn_comeleinfie_id
     from com_elet_inf_ie
    where empresa_id = en_empresa_id
      and ano_ref    = en_ano_ref
      and pais_id    = en_pais_id;
   --
   return vn_comeleinfie_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_comeletinfie_id:' || sqlerrm);
end fkg_comeletinfie_id;

-------------------------------------------------------------------------------------------------------
-- Função que retorna o código da tabela dem_prej_acm_ext_contr_ie
function fkg_demprejacmextcontrie_id ( en_identpartextie_id in ident_part_ext_ie.id%type
                                     ) return dem_prej_acm_ext_contr_ie.id%type
is
   --
   vn_demprejacmextcontrie_id        number := null;
   --
begin
   --
   vn_demprejacmextcontrie_id := null;
   --
   select id
     into vn_demprejacmextcontrie_id
     from dem_prej_acm_ext_contr_ie
    where identpartextie_id = en_identpartextie_id;
   --
   return vn_demprejacmextcontrie_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_demprejacmextcontrie_id:' || sqlerrm);
end fkg_demprejacmextcontrie_id;

-------------------------------------------------------------------------------------------------------
-- Função que retorna o código da tabela com_ele_ti_inf_vend_ie
function fkg_comeletiinfvendie_id ( en_aberturaecf_id in abertura_ecf.id%type
                                  , en_tabdinecf_id   in tab_din_ecf.id%type
                                  ) return com_ele_ti_inf_vend_ie.id%type
is
   --
   vn_comeletiinfvendie_id        number := null;
   --
begin
   --
   vn_comeletiinfvendie_id := null;
   --
   select id
     into vn_comeletiinfvendie_id
     from com_ele_ti_inf_vend_ie
    where aberturaecf_id  = en_aberturaecf_id
      and tabdinecf_id    = en_tabdinecf_id;
   --
   return vn_comeletiinfvendie_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_comeletiinfvendie_id:' || sqlerrm);
end fkg_comeletiinfvendie_id;

-------------------------------------------------------------------------------------------------------
-- Função que retorna o código da tabela invest_diretas_ie
function fkg_investdiretasie_id ( en_identpartextie_id invest_diretas_ie.identpartextie_id%type,
                                  en_pais_id           invest_diretas_ie.pais_id%type,
                                  ev_nif_cnpj          invest_diretas_ie.nif_cnpj%type
                                  ) return invest_diretas_ie.id%type
is
  --
  vn_investdiretasie_id number:=null;
  --
begin
  --
  select id 
         into vn_investdiretasie_id
  from invest_diretas_ie 
  where identpartextie_id = en_identpartextie_id
    and pais_id           = en_pais_id
    and nif_cnpj          = ev_nif_cnpj;
  --
  return vn_investdiretasie_id;
  --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_investdiretasie_id:' || sqlerrm);
end;

-------------------------------------------------------------------------------------------------------
-- Função que retorna o código da tabela dem_estr_soc_ext_contr_ie
function fkg_demestrsocextcontrie_id ( en_identpartextie_id in ident_part_ext_ie.id%type
                                     ) return dem_estr_soc_ext_contr_ie.id%type
is
   --
   vn_demestrsocextcontrie_id        number := null;
   --
begin
   --
   vn_demestrsocextcontrie_id := null;
   --
   select id
     into vn_demestrsocextcontrie_id
     from dem_estr_soc_ext_contr_ie
    where identpartextie_id = en_identpartextie_id;
   --
   return vn_demestrsocextcontrie_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_demrendapextcontrie_id:' || sqlerrm);
end fkg_demestrsocextcontrie_id;

-------------------------------------------------------------------------------------------------------
-- Função que retorna o código da tabela DEM_REND_AP_EXT_CONTR_IE
function fkg_demrendapextcontrie_id ( en_identpartextie_id  in ident_part_ext_ie.id%type
                                    ) return DEM_REND_AP_EXT_CONTR_IE.id%type
is
   --
   vn_demrendapextcontrie_id        number := null;
   --
begin
   --
   vn_demrendapextcontrie_id := null;
   --
   select id
     into vn_demrendapextcontrie_id
     from dem_rend_ap_ext_contr_ie
    where identpartextie_id = en_identpartextie_id;
   --
   return vn_demrendapextcontrie_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_demrendapextcontrie_id:' || sqlerrm);
end fkg_demrendapextcontrie_id;

-------------------------------------------------------------------------------------------------------
-- Função que retorna o código da tabela dem_cons_ext_contr_ie
function fkg_demconsextcontrie_id ( en_identpartextie_id in ident_part_ext_ie.id%type
                                  ) return dem_cons_ext_contr_ie.id%type
is
   --
   vn_demconsextcontrie_id        number := null;
   --
begin
   --
   vn_demconsextcontrie_id := null;
   --
   select id
     into vn_demconsextcontrie_id
     from dem_cons_ext_contr_ie
    where identpartextie_id = en_identpartextie_id;
   --
   return vn_demconsextcontrie_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_demconsextcontrie_id:' || sqlerrm);
end fkg_demconsextcontrie_id;

-------------------------------------------------------------------------------------------------------
-- Função que retorna o código da tabela dem_res_ext_auf_col_rc_ie
function fkg_demresextaufcolrcie_id ( en_identpartextie_id  in ident_part_ext_ie.id%type
                                    ) return dem_res_ext_auf_col_rc_ie.id%type
is
   --
   vn_demresextaufcolrcie_id        number := null;
   --
begin
   --
   vn_demresextaufcolrcie_id := null;
   --
   select id
     into vn_demresextaufcolrcie_id
     from dem_res_ext_auf_col_rc_ie
    where identpartextie_id = en_identpartextie_id;
   --
   return vn_demresextaufcolrcie_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_demresextaufcolrcie_id:' || sqlerrm);
end fkg_demresextaufcolrcie_id;

-------------------------------------------------------------------------------------------------------
-- Função que retorna o código da tabela dem_resul_imp_ext_ie
function fkg_demresulimpextie_id ( en_identpartextie_id  in ident_part_ext_ie.id%type
                                 ) return dem_resul_imp_ext_ie.id%type
is
   --
   vn_demresulimpextie_id        number := null;
   --
begin
   --
   vn_demresulimpextie_id := null;
   --
   select id
     into vn_demresulimpextie_id
     from dem_resul_imp_ext_ie
    where identpartextie_id = en_identpartextie_id;
   --
   return vn_demresulimpextie_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_demresulimpextie_id:' || sqlerrm);
end fkg_demresulimpextie_id;

-------------------------------------------------------------------------------------------------------
-- Função que retorna o código da tabela part_ext_resul_apur_ie
function fkg_partextresulapurie_id ( en_identpartextie_id  in ident_part_ext_ie.id%type
                                   ) return part_ext_resul_apur_ie.id%type
is
   --
   vn_partextresulapurie_id        number := null;
   --
begin
   --
   vn_partextresulapurie_id := null;
   --
   select id
     into vn_partextresulapurie_id
     from part_ext_resul_apur_ie
    where identpartextie_id = en_identpartextie_id;
   --
   return vn_partextresulapurie_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_partextresulapurie_id:' || sqlerrm);
end fkg_partextresulapurie_id;

-------------------------------------------------------------------------------------------------------
-- Função que retorna o Código da tabela ident_part_ext_ie

function fkg_identpartextie_id ( en_empresa_id  in ident_part_ext_ie.empresa_id%type
                               , en_ano_ref     in ident_part_ext_ie.ano_ref%type
                               , en_pessoa_id   in ident_part_ext_ie.pessoa_id%type
                               , ev_nif         in ident_part_ext_ie.nif%type
                               ) return ident_part_ext_ie.id%type
is
   --
   vn_identpartextie_id        ident_part_ext_ie.id%type := null;
   --
begin
   --
   vn_identpartextie_id := null;
   --
   select id
     into vn_identpartextie_id
     from ident_part_ext_ie
    where empresa_id = en_empresa_id
      and ano_ref    = en_ano_ref
      and pessoa_id  = en_pessoa_id
      and nif        = ev_nif;
   --
   return vn_identpartextie_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_identpartextie_id:' || sqlerrm);
end fkg_identpartextie_id;

-------------------------------------------------------------------------------------------------------
-- Função que retorna o ID da tabela oper_ext_contr_exp_ie
function fkg_operextcontrimpie_id ( en_operextimportacaoie_id   in oper_ext_importacao_ie.id%type
                                  , en_pessoa_id                in pessoa.id%type
                                  ) return oper_ext_contr_imp_ie.id%type
is
   --
   vn_operextcontrimpie_id        oper_ext_contr_imp_ie.id%type := null;
   --
begin
   --
   vn_operextcontrimpie_id := null;
   --
   select id
     into vn_operextcontrimpie_id
     from oper_ext_contr_imp_ie oe
    where oe.operextimportacaoie_id = en_operextimportacaoie_id
      and oe.pessoa_id              = en_pessoa_id;
   --
   return vn_operextcontrimpie_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_operextcontrimpie_id:' || sqlerrm);
end fkg_operextcontrimpie_id;

-------------------------------------------------------------------------------------------------------
-- Função que retorna o ID da tabela oper_ext_importacao_ie
function fkg_operextimportacaoie_id ( en_empresa_id              in empresa.id%type
                                    , en_ano_ref                 in oper_ext_importacao_ie.ano_ref%type
                                    , ev_num_ordem               in oper_ext_importacao_ie.num_ordem%type
                                    ) return oper_ext_importacao_ie.id%type
is
   --
   vn_operextimportacaoie_id        number := null;
   --
begin
   --
   vn_operextimportacaoie_id := null;
   --
   select id
     into vn_operextimportacaoie_id
     from oper_ext_importacao_ie oe
    where oe.empresa_id = en_empresa_id
      and oe.ano_ref    = en_ano_ref
      and oe.num_ordem  = ev_num_ordem;
   --
   return vn_operextimportacaoie_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_operextimportacaoie_id:' || sqlerrm);
end fkg_operextimportacaoie_id;

-------------------------------------------------------------------------------------------------------
-- Função que retorna o ID da tabela oper_ext_contr_exp_ie
function fkg_operextcontrexpie_id ( en_operextexportacaoie_id   in oper_ext_exportacao_ie.id%type
                                  , en_pessoa_id                in pessoa.id%type
                                  ) return oper_ext_contr_exp_ie.id%type
is
   --
   vn_operextcontrexpie_id        number := null;
   --
begin
   --
   vn_operextcontrexpie_id := null;
   --
   select id
     into vn_operextcontrexpie_id
     from oper_ext_contr_exp_ie oe
    where oe.operextexportacaoie_id = en_operextexportacaoie_id
      and oe.pessoa_id              = en_pessoa_id;
   --
   return vn_operextcontrexpie_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_operextcontrexpie_id:' || sqlerrm);
end fkg_operextcontrexpie_id;

-------------------------------------------------------------------------------------------------------
-- Função que retorna o ID da tabela OPER_EXT_EXPORTACAO_IE

function fkg_operextexportacaoie_id ( en_empresa_id        in  empresa.id%type
                                    , en_ano_ref           in  oper_ext_exportacao_ie.ano_ref%type
                                    , ev_num_ordem         in  oper_ext_exportacao_ie.num_ordem%type
                                    ) return oper_ext_exportacao_ie.id%type
is
   --
   vn_operextexportacaoie_id        oper_ext_exportacao_ie.id%type;
   --
begin
   --
   vn_operextexportacaoie_id := null;
   --
   select id
     into vn_operextexportacaoie_id
     from oper_ext_exportacao_ie oe
    where oe.empresa_id = en_empresa_id
      and oe.ano_ref    = en_ano_ref
      and oe.num_ordem  = ev_num_ordem;
   --
   return vn_operextexportacaoie_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_operextexportacaoie_id:' || sqlerrm);
end fkg_operextexportacaoie_id;


-------------------------------------------------------------------------------------------------------
-- Função que retorna o ID da tabela OPER_EXT_PESSOA_NVINC_IE

function fkg_operextpessoanvincie_id ( en_aberturaecf_id in abertura_ecf.id%type
                                     , en_tabdinecf_id   in tab_din_ecf.id%type
                                     ) return oper_ext_pessoa_nvinc_ie.id%type 
is
   --
   vn_operextpessoanvincie_id        oper_ext_pessoa_nvinc_ie.id%type;
   --
begin
   --
   vn_operextpessoanvincie_id := null;
   --
   if nvl(en_aberturaecf_id,0) > 0 and
      nvl(en_tabdinecf_id,0) > 0 then
      --
      select id
        into vn_operextpessoanvincie_id
        from oper_ext_pessoa_nvinc_ie oe
       where oe.aberturaecf_id = en_aberturaecf_id
         and oe.tabdinecf_id   = en_tabdinecf_id;
      --
   end if;
   --
   return vn_operextpessoanvincie_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_operextpessoanvincie_id:' || sqlerrm);
end fkg_operextpessoanvincie_id;
-------------------------------------------------------------------------------------------------------

-- Função que retorna o ID da tabela OPER_EXT_PESSOA_VINC_IE

function fkg_operextpessoavincie_id ( en_aberturaecf_id in abertura_ecf.id%type
                                    , en_tabdinecf_id in tab_din_ecf.id%type 
                                    ) return oper_ext_pessoa_vinc_ie.id%type
is
   --
   vn_operextpessoavincie_id        oper_ext_pessoa_vinc_ie.id%type;
   --
begin
   --
   vn_operextpessoavincie_id := null;
   --
   if nvl(en_aberturaecf_id,0) > 0 and
      nvl(en_tabdinecf_id,0) > 0 then
      --
      select id
        into vn_operextpessoavincie_id
        from oper_ext_pessoa_vinc_ie oe
       where oe.aberturaecf_id = en_aberturaecf_id
         and oe.tabdinecf_id   = en_tabdinecf_id;
      --
   end if;
   --
   return vn_operextpessoavincie_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_operextpessoavincie_id:' || sqlerrm);
end fkg_operextpessoavincie_id;

----------------------------------------------------------------------------------------------------

-- Função retorna o Código da Versão Leiaute do Sped ECF

function fkg_cd_versaolayoutecf_id ( en_versaolayoutecf_id in versao_layout_ecf.id%type )
         return versao_layout_ecf.cd%type
is
   --
   vv_versaolayoutecf_cd versao_layout_ecf.cd%type := null;
   --
begin
   --
   if nvl(en_versaolayoutecf_id,0) > 0 then
      --
      select v.cd
        into vv_versaolayoutecf_cd
        from versao_layout_ecf v
       where v.id = en_versaolayoutecf_id;
      --
   end if;
   --
   return vv_versaolayoutecf_cd;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_cd_versaolayoutecf_id:' || sqlerrm);
end fkg_cd_versaolayoutecf_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna a "Versão" Leiaute do Sped ECF

function fkg_versao_versaolayoutecf_id ( en_versaolayoutecf_id in versao_layout_ecf.id%type )
         return versao_layout_ecf.versao%type
is
   --
   vv_versao versao_layout_ecf.versao%type := null;
   --
begin
   --
   if nvl(en_versaolayoutecf_id,0) > 0 then
      --
      select v.versao
        into vv_versao
        from versao_layout_ecf v
       where v.id = en_versaolayoutecf_id;
      --
   end if;
   --
   return vv_versao;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_versao_versaolayoutecf_id:' || sqlerrm);
end fkg_versao_versaolayoutecf_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da Versão Leiaute do Sped ECF conforme o Código

function fkg_id_versaolayoutecf_cd ( ev_versaolayoutecf_cd in versao_layout_ecf.cd%type )
         return versao_layout_ecf.id%type
is
   --
   vn_versaolayoutecf_id versao_layout_ecf.id%type := null;
   --
begin
   --
   if trim(ev_versaolayoutecf_cd) is not null then
      --
      select v.id
        into vn_versaolayoutecf_id
        from versao_layout_ecf v
       where v.cd = ev_versaolayoutecf_cd;
      --
   end if;
   --
   return vn_versaolayoutecf_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_id_versaolayoutecf_cd:' || sqlerrm);
end fkg_id_versaolayoutecf_cd;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da Versão Leiaute do Sped ECF conforme o periodo

function fkg_id_versaolayoutecf_dt ( ed_dt_ini in date
                                   , ed_dt_fin in date 
                                   )
         return versao_layout_ecf.id%type
is
   --
   vn_versaolayoutecf_id versao_layout_ecf.id%type := null;
   --
begin
   --
   begin
      --
      select v.id
        into vn_versaolayoutecf_id
        from versao_layout_ecf v
       where ed_dt_ini between v.dt_ini and nvl(v.dt_fin, ed_dt_fin)
         and ed_dt_fin between v.dt_ini and nvl(v.dt_fin, ed_dt_fin);
      --
   exception
      when others then
         vn_versaolayoutecf_id := null;
   end;
   --
   if nvl(vn_versaolayoutecf_id,0) <= 0 then
      --
      begin
         --
         select max(v.id)
           into vn_versaolayoutecf_id
           from versao_layout_ecf v
          where v.dt_ini <= ed_dt_ini;
         --
      exception
         when others then
            vn_versaolayoutecf_id := null;
      end;
      --
   end if;
   --
   return vn_versaolayoutecf_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_id_versaolayoutecf_dt:' || sqlerrm);
end fkg_id_versaolayoutecf_dt;

-------------------------------------------------------------------------------------------------------

-- Função retorna o CD da Versão Leiaute do Sped ECF conforme o periodo

function fkg_cd_versaolayoutecf_dt ( ed_dt_ini in date
                                   , ed_dt_fin in date 
                                   )
         return versao_layout_ecf.cd%type
is
   --
   vv_versaolayoutecf_cd versao_layout_ecf.cd%type := null;
   --
begin
   --
   begin
      --
      select v.cd
        into vv_versaolayoutecf_cd
        from versao_layout_ecf v
       where ed_dt_ini between v.dt_ini and nvl(v.dt_fin, ed_dt_fin)
         and ed_dt_fin between v.dt_ini and nvl(v.dt_fin, ed_dt_fin);
      --
   exception
      when others then
         vv_versaolayoutecf_cd := null;
   end;
   --
   if trim(vv_versaolayoutecf_cd) is null then
      --
      begin
         --
         select max(v.cd)
           into vv_versaolayoutecf_cd
           from versao_layout_ecf v
          where v.dt_ini <= ed_dt_ini;
         --
      exception
         when others then
            vv_versaolayoutecf_cd := null;
      end;
      --
   end if;
   --
   return vv_versaolayoutecf_cd;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_cd_versaolayoutecf_dt:' || sqlerrm);
end fkg_cd_versaolayoutecf_dt;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Código da Natureza Juridica conforme ID

function fkg_cd_naturjurid_id ( en_naturjurid_id in natur_jurid.id%type )
         return natur_jurid.cd%type
is
   --
   vv_naturjurid_cd natur_jurid.cd%type := null;
   --
begin
   --
   if nvl(en_naturjurid_id,0) > 0 then
      --
      select nj.cd
        into vv_naturjurid_cd
        from natur_jurid nj
       where nj.id = en_naturjurid_id;
      --
   end if;
   --
   return vv_naturjurid_cd;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_cd_naturjurid_id:' || sqlerrm);
end fkg_cd_naturjurid_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da Natureza Juridica conforme o Código

function fkg_id_naturjurid_cd ( en_naturjurid_cd in natur_jurid.cd%type )
         return natur_jurid.id%type
is
   --
   vn_naturjurid_id natur_jurid.id%type := null;
   --
begin
   --
   if trim(en_naturjurid_cd) is not null then
      --
      select nj.id
        into vn_naturjurid_id
        from natur_jurid nj
       where nj.cd = en_naturjurid_cd;
      --
   end if;
   --
   return vn_naturjurid_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_id_naturjurid_cd:' || sqlerrm);
end fkg_id_naturjurid_cd;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID Registro do SPED ECF conforme o Código

function fkg_id_registroecf_cod ( ev_registroecf_cod in registro_ecf.cod%TYPE )
         return registro_ecf.id%TYPE
is

   vn_registroecf_id  registro_ecf.id%TYPE;

begin
   --
   select r.id
     into vn_registroecf_id
     from registro_ecf r
    where r.cod = ev_registroecf_cod;
   --
   return vn_registroecf_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error (-20100, 'Erro na fkg_id_registroecf_cod: ' || sqlerrm);
end fkg_id_registroecf_cod;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Código do Registro do SPED ECF conforme ID

function fkg_cod_registroecf_id ( en_registroecf_id in registro_ecf.id%TYPE )
         return registro_ecf.cod%TYPE
is

   vv_registroecf_cod  registro_ecf.cod%TYPE;

begin
   --
   select r.cod
     into vv_registroecf_cod
     from registro_ecf r
    where r.id = en_registroecf_id;
   --
   return vv_registroecf_cod;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error (-20100, 'Erro na fkg_cod_registroecf_id: ' || sqlerrm);
end fkg_cod_registroecf_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Código + Descrição do Registro do SPED ECF conforme ID

function fkg_texto_registroecf_id ( en_registroecf_id in registro_ecf.id%TYPE )
         return varchar2
is

   vv_texto  varchar2(300);

begin
   --
   select r.cod || '-' || r.descr
     into vv_texto
     from registro_ecf r
    where r.id = en_registroecf_id;
   --
   return vv_texto;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error (-20100, 'Erro na fkg_texto_registroecf_id: ' || sqlerrm);
end fkg_texto_registroecf_id;

-------------------------------------------------------------------------------------------------------

-- Função retorno os dados da Tabela Dinamica do ECF conforme ID do registro

function fkg_tabdinecf_row ( en_tabdinecf_id in tab_din_ecf.id%type )
         return tab_din_ecf%rowtype
is
   --
   vt_tab_din_ecf tab_din_ecf%rowtype;
   --
begin
   --
   select td.*
     into vt_tab_din_ecf
     from tab_din_ecf td
    where td.id = en_tabdinecf_id;
   --
   return vt_tab_din_ecf;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error (-20100, 'Erro na fkg_tabdinecf_id: ' || sqlerrm);
end fkg_tabdinecf_row;
-------------------------------------------------------------------------------------------------------
-- Função de retorno do código da Tabela Padrão RFB -  Parte B
function fkg_tabpdrrfb_id( en_tabpdrrfb_id in tab_pb_rfb_part_b.id%type)
         return varchar2
is
   ---
   vv_cod_pb_rfb       tab_pb_rfb_part_b.cod_pb_rfb%type;
   ---
begin
   ---
   select tpr.cod_pb_rfb into vv_cod_pb_rfb
   from tab_pb_rfb_part_b tpr where tpr.id = en_tabpdrrfb_id;
   ---  
   return vv_cod_pb_rfb;
   --- 
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error (-20100, 'Erro na fkg_tabpdrrfb_id: ' || sqlerrm);  
end;

-------------------------------------------------------------------------------------------------------

-- Função retorno os dados da "Configuração do DE-PARA Tabela Dinamica do Sped ECF" (CONF_DP_TB_ECF) conforme ID do registro

function fkg_confdptbecf_id ( en_confdptbecf_id in conf_dp_tb_ecf.id%type )
         return conf_dp_tb_ecf%rowtype
is
   --
   vt_conf_dp_tb_ecf conf_dp_tb_ecf%rowtype;
   --
begin
   --
   select c.*
     into vt_conf_dp_tb_ecf
     from conf_dp_tb_ecf c
    where c.id = en_confdptbecf_id;
   --
   return vt_conf_dp_tb_ecf;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error (-20100, 'Erro na fkg_confdptbecf_id: ' || sqlerrm);
end fkg_confdptbecf_id;

-------------------------------------------------------------------------------------------------------

-- Função retorno a descrição da "Configuração do DE-PARA Tabela Dinamica do Sped ECF" (CONF_DP_TB_ECF) conforme ID do registro

function fkg_texto_confdptbecf_id ( en_confdptbecf_id in conf_dp_tb_ecf.id%type )
         return varchar2
is
   --
   vv_texto            varchar2(4000) := null;
   vv_texto_cp         varchar2(4000) := null;
   vt_conf_dp_tb_ecf   conf_dp_tb_ecf%rowtype;
   vt_tab_din_ecf      tab_din_ecf%rowtype;
   --
   cursor c_cp is
   select * from crit_pesq_lc
    where confdptbecf_id = vt_conf_dp_tb_ecf.id
    order by 1;
   --
begin
   --
   if nvl(en_confdptbecf_id,0) > 0 then
      --
      vt_conf_dp_tb_ecf := fkg_confdptbecf_id ( en_confdptbecf_id => en_confdptbecf_id );
      --
      if nvl(vt_conf_dp_tb_ecf.id,0) > 0 then
         --
         vv_texto := vv_texto || '-----------------------------------------------------------' || chr(10);
         vv_texto := vv_texto || 'Registro: ' || fkg_texto_registroecf_id ( en_registroecf_id => vt_conf_dp_tb_ecf.registroecf_id ) || chr(10);
         vv_texto := vv_texto || 'Plano Conta: ' || pk_csf.fkg_texto_plano_conta_id ( en_planoconta_id => vt_conf_dp_tb_ecf.planoconta_id ) || chr(10);
         --
         if nvl(vt_conf_dp_tb_ecf.centrocusto_id,0) > 0 then
            vv_texto := vv_texto || 'Centro Custo: ' || pk_csf.fkg_texto_centro_custo_id ( en_centrocusto_id => vt_conf_dp_tb_ecf.centrocusto_id ) || chr(10);
         end if;
         --
         vt_tab_din_ecf := fkg_tabdinecf_row ( en_tabdinecf_id => vt_conf_dp_tb_ecf.tabdinecf_id );
         --
         vv_texto := vv_texto || 'Tabela Dinâmica: ' || vt_tab_din_ecf.cd || '-' || vt_tab_din_ecf.descr || chr(10);
         --
         vv_texto := vv_texto || 'Tipo do Período: ' || pk_csf.fkg_dominio('CONF_DP_TB_ECF.DM_TIPO_PERIODO', vt_conf_dp_tb_ecf.dm_tipo_periodo) || chr(10);
         vv_texto := vv_texto || 'Recupera o Saldo Antes do Encerramento: ' || pk_csf.fkg_dominio('CONF_DP_TB_ECF.DM_SLD_ANTES_ENCERR', vt_conf_dp_tb_ecf.dm_sld_antes_encerr) || chr(10);
         vv_texto := vv_texto || 'Tipo do Valor Calculado: ' || pk_csf.fkg_dominio('CONF_DP_TB_ECF.DM_TIPO_VLR_CALC', vt_conf_dp_tb_ecf.dm_tipo_vlr_calc) || chr(10);
         --
         for rec_cp in c_cp loop
            exit when c_cp%notfound or (c_cp%notfound) is null;
            --
            vv_texto_cp := vv_texto_cp || pk_csf.fkg_dominio('CRIT_PESQ_LC.DM_TIPO', rec_cp.dm_tipo) || ' = ' || rec_cp.crit_pesq || chr(10);
            --
         end loop;
         --
         if trim(vv_texto_cp) is not null then
            --
            vv_texto := vv_texto || '-----------------------------------------------------------' || chr(10);
            vv_texto := vv_texto || 'Critério de Pesquisa utilizado para Lançamentos Contábeis: ' || chr(10);
            vv_texto := vv_texto || '-----------------------------------------------------------' || chr(10);
            vv_texto := vv_texto || vv_texto_cp;
            --
         end if;
         --
         vv_texto := vv_texto || '-----------------------------------------------------------' || chr(10);
         --
      end if;
      --
   end if;
   --
   return vv_texto;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error (-20100, 'Erro na fkg_texto_confdptbecf_id: ' || sqlerrm);
end fkg_texto_confdptbecf_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID "Codigo de CNC" do SPED ECF conforme o Código

function fkg_id_codcnc_cd ( en_codcnc_cd in cod_cnc.cd%TYPE )
         return cod_cnc.id%TYPE
is

   vn_codcnc_id  cod_cnc.id%TYPE;

begin
   --
   select c.id
     into vn_codcnc_id
     from cod_cnc c
    where c.cd = en_codcnc_cd;
   --
   return vn_codcnc_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error (-20100, 'Erro na fkg_id_codcnc_cd: ' || sqlerrm);
end fkg_id_codcnc_cd;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Código do "Codigo de CNC" do SPED ECF conforme ID

function fkg_cd_codcnc_id ( en_codcnc_id in cod_cnc.id%TYPE )
         return cod_cnc.cd%TYPE
is

   vv_codcnc_cd  cod_cnc.cd%TYPE;

begin
   --
   select c.cd
     into vv_codcnc_cd
     from cod_cnc c
    where c.id = en_codcnc_id;
   --
   return vv_codcnc_cd;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error (-20100, 'Erro na fkg_cd_codcnc_id: ' || sqlerrm);
end fkg_cd_codcnc_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID "Tipo Moeda" do SPED ECF conforme o Código

function fkg_id_tipomoeda_cd ( ev_tipomoeda_cd in tipo_moeda.cd%TYPE )
         return tipo_moeda.id%TYPE
is

   vn_tipomoeda_id  tipo_moeda.id%TYPE;

begin
   --
   select tp.id
     into vn_tipomoeda_id
     from tipo_moeda tp
    where tp.cd = ev_tipomoeda_cd;
   --
   return vn_tipomoeda_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error (-20100, 'Erro na fkg_id_tipomoeda_cd: ' || sqlerrm);
end fkg_id_tipomoeda_cd;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Código do "Codigo de CNC" do SPED ECF conforme ID

function fkg_cd_tipomoeda_id ( en_tipomoeda_id in tipo_moeda.id%TYPE )
         return tipo_moeda.cd%TYPE
is

   vv_tipomoeda_cd  tipo_moeda.cd%TYPE;

begin
   --
   select tm.cd
     into vv_tipomoeda_cd
     from tipo_moeda tm
    where tm.id = en_tipomoeda_id;
   --
   return vv_tipomoeda_cd;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error (-20100, 'Erro na fkg_cd_tipomoeda_id: ' || sqlerrm);
end fkg_cd_tipomoeda_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID "Natureza de Operação" do SPED ECF conforme o Código

function fkg_id_natoperecf_cd ( en_natoperecf_cd in nat_oper_ecf.cd%TYPE )
         return nat_oper_ecf.id%TYPE
is

   vn_natoperecf_id  nat_oper_ecf.id%TYPE;

begin
   --
   select n.id
     into vn_natoperecf_id
     from nat_oper_ecf n
    where n.cd = en_natoperecf_cd;
   --
   return vn_natoperecf_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error (-20100, 'Erro na fkg_id_natoperecf_cd: ' || sqlerrm);
end fkg_id_natoperecf_cd;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Código do "Natureza de Operação" do SPED ECF conforme ID

function fkg_cd_natoperecf_id ( en_natoperecf_id in nat_oper_ecf.id%TYPE )
         return nat_oper_ecf.cd%TYPE
is

   vv_natoperecf_cd  nat_oper_ecf.cd%TYPE;

begin
   --
   select n.cd
     into vv_natoperecf_cd
     from nat_oper_ecf n
    where n.id = en_natoperecf_id;
   --
   return vv_natoperecf_cd;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error (-20100, 'Erro na fkg_cd_natoperecf_id: ' || sqlerrm);
end fkg_cd_natoperecf_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID "Tipos de Ativo" do SPED ECF conforme o Código

function fkg_id_tipoativoecf_cd ( ev_tipoativoecf_cd in tipo_ativo_ecf.cd%TYPE )
         return tipo_ativo_ecf.id%TYPE
is

   vn_tipoativoecf_id  tipo_ativo_ecf.id%TYPE;

begin
   --
   select ta.id
     into vn_tipoativoecf_id
     from tipo_ativo_ecf ta
    where ta.cd = ev_tipoativoecf_cd;
   --
   return vn_tipoativoecf_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error (-20100, 'Erro na fkg_id_tipoativoecf_cd: ' || sqlerrm);
end fkg_id_tipoativoecf_cd;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Código do "Tipos de Ativo" do SPED ECF conforme ID

function fkg_cd_tipoativoecf_id ( en_tipoativoecf_id in tipo_ativo_ecf.id%TYPE )
         return tipo_ativo_ecf.cd%TYPE
is

   vv_tipoativoecf_cd  tipo_ativo_ecf.cd%TYPE;

begin
   --
   select ta.cd
     into vv_tipoativoecf_cd
     from tipo_ativo_ecf ta
    where ta.id = en_tipoativoecf_id;
   --
   return vv_tipoativoecf_cd;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error (-20100, 'Erro na fkg_cd_tipoativoecf_id: ' || sqlerrm);
end fkg_cd_tipoativoecf_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna os dados da "Abertura" do SPED ECF conforme ID

function fkg_aberturaecf_id ( en_aberturaecf_id in abertura_ecf.id%TYPE )
         return abertura_ecf%rowtype
is
   --
   vt_abertura_ecf abertura_ecf%rowtype;
   --
begin
   --
   if nvl(en_aberturaecf_id,0) > 0 then
      --
      select *
        into vt_abertura_ecf
        from abertura_ecf
       where id = en_aberturaecf_id;
      --
   end if;
   --
   return vt_abertura_ecf;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error (-20100, 'Erro na fkg_aberturaecf_id: ' || sqlerrm);
end fkg_aberturaecf_id;
-------------------------------------------------------------------------------------------------------
-- Função para localizar Id da tabela Abertura_Ecf.

function fkg_busca_aberturaecf_id ( en_empresa_id abertura_ecf.empresa_id%type
                               , ed_dt_ini     abertura_ecf.dt_ini%type
                               , ed_dt_fin     abertura_ecf.dt_fin%type)
                               return abertura_ecf.id%type
is
   vn_aberturaecf_id abertura_ecf.id%type;
begin
  --
  select ae.id
  into vn_aberturaecf_id
  from abertura_ecf ae 
  where ae.empresa_id = en_empresa_id  
  and ed_dt_ini between dt_ini and dt_fin
  and ed_dt_fin between dt_ini and dt_fin;
  --
  return vn_aberturaecf_id;
  --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error (-20100, 'Erro na fkg_busca_aberturaecf_id: ' || sqlerrm); 
end fkg_busca_aberturaecf_id; 

-------------------------------------------------------------------------------------------------------

-- Função retorna os dados da "Abertura - Parametros Tributaveis" do SPED ECF conforme ID

function fkg_abertecfparamtrib_id ( en_aberturaecf_id in abertura_ecf.id%TYPE )
         return abert_ecf_param_trib%rowtype
is
   --
   vt_abert_ecf_param_trib abert_ecf_param_trib%rowtype;
   --
begin
   --
   if nvl(en_aberturaecf_id,0) > 0 then
      --
      select *
        into vt_abert_ecf_param_trib
        from abert_ecf_param_trib
       where aberturaecf_id = en_aberturaecf_id;
      --
   end if;
   --
   return vt_abert_ecf_param_trib;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error (-20100, 'Erro na fkg_abertecfparamtrib_id: ' || sqlerrm);
end fkg_abertecfparamtrib_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna os dados da "Abertura - Parametros Complementares" do SPED ECF conforme ID

function fkg_abertecfparamcompl_id ( en_aberturaecf_id in abertura_ecf.id%TYPE )
         return abert_ecf_param_compl%rowtype
is
   --
   vt_abert_ecf_param_compl abert_ecf_param_compl%rowtype;
   --
begin
   --
   if nvl(en_aberturaecf_id,0) > 0 then
      --
      select *
        into vt_abert_ecf_param_compl
        from abert_ecf_param_compl
       where aberturaecf_id = en_aberturaecf_id;
      --
   end if;
   --
   return vt_abert_ecf_param_compl;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error (-20100, 'Erro na fkg_abertecfparamcompl_id: ' || sqlerrm);
end fkg_abertecfparamcompl_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna os dados da "Abertura - Parametros Gerais" do SPED ECF conforme ID

function fkg_abertecfparamgeral_id ( en_aberturaecf_id in abertura_ecf.id%TYPE )
         return abert_ecf_param_geral%rowtype
is
   --
   vt_abert_ecf_param_geral abert_ecf_param_geral%rowtype;
   --
begin
   --
   if nvl(en_aberturaecf_id,0) > 0 then
      --
      select *
        into vt_abert_ecf_param_geral
        from abert_ecf_param_geral
       where aberturaecf_id = en_aberturaecf_id;
      --
   end if;
   --
   return vt_abert_ecf_param_geral;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error (-20100, 'Erro na fkg_abertecfparamgeral_id: ' || sqlerrm);
end fkg_abertecfparamgeral_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna os dados da Abertura - Parâmetros de Identificação dos Tipos de Programa

function fkg_abertecfparidenttpprog_id ( en_aberturaecf_id in abertura_ecf.id%type )
                                       return abert_ecf_param_ident_tp_prog%rowtype
is
   --
   vt_abert_ecf_par_ident_tp_prog    abert_ecf_param_ident_tp_prog%rowtype;
   --
begin
   --
   vt_abert_ecf_par_ident_tp_prog := null;
   --
   if nvl(en_aberturaecf_id,0) > 0 then
      --
      select *
        into vt_abert_ecf_par_ident_tp_prog
        from abert_ecf_param_ident_tp_prog
       where aberturaecf_id = en_aberturaecf_id;
      --
   end if;
   --
   return vt_abert_ecf_par_ident_tp_prog;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error (-20100, 'Erro na fkg_abertecfparidenttpprog_id: ' || sqlerrm);
end fkg_abertecfparidenttpprog_id;
-------------------------------------------------------------------------------------------------------

-- Função retorna os dados da "Abertura - Parametros Dados Empresa" do SPED ECF conforme ID

function fkg_abertecfdados_id ( en_aberturaecf_id in abertura_ecf.id%TYPE )
         return abert_ecf_dados%rowtype
is
   --
   vt_abert_ecf_dados abert_ecf_dados%rowtype;
   --
begin
   --
   if nvl(en_aberturaecf_id,0) > 0 then
      --
      select *
        into vt_abert_ecf_dados
        from abert_ecf_dados
       where aberturaecf_id = en_aberturaecf_id;
      --
   end if;
   --
   return vt_abert_ecf_dados;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error (-20100, 'Erro na fkg_abertecfdados_id: ' || sqlerrm);
end fkg_abertecfdados_id;

-------------------------------------------------------------------------------------------------------

-- Função recupera o Código de Identificação do registro com base no Código da Jurisdicao do Sped ECF

function fkg_jurisdicaosecf_id ( ev_jurisdicaosecf_cd in JURISDICAO_SECF.cd%type
                               ) return JURISDICAO_SECF.id%type
is
   --
   vn_jurisdicaosecf_id       JURISDICAO_SECF.id%type;
   --
begin
   --
   vn_jurisdicaosecf_id := null;
   --
   if trim(ev_jurisdicaosecf_cd) is not null then
      --
      select id 
        into vn_jurisdicaosecf_id
        from JURISDICAO_SECF js
       where js.cd = ev_jurisdicaosecf_cd;
      --
   end if;
   --
   return vn_jurisdicaosecf_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error (-20100, 'Erro na fkg_cd_jurisdicaosecf: ' || sqlerrm);
end fkg_jurisdicaosecf_id;


-------------------------------------------------------------------------------------------------------

-- Função recupera o Código da Jurisdicao do Sped ECF com base no Código de Identificação do registro

function fkg_cd_jurisdicaosecf ( en_jurisdicaosecf_id in JURISDICAO_SECF.ID%type
                               ) return JURISDICAO_SECF.cd%type
is
   --
   vn_cd  JURISDICAO_SECF.cd%type;
   --
begin
   --
   vn_cd := null;
   --
   if nvl(en_jurisdicaosecf_id,0) > 0  then
      --
      select cd
        into vn_cd
        from JURISDICAO_SECF
       where id = en_jurisdicaosecf_id;
      --
   end if;
   --
   return vn_cd;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error (-20100, 'Erro na fkg_cd_jurisdicaosecf: ' || sqlerrm);
end fkg_cd_jurisdicaosecf;

-------------------------------------------------------------------------------------------------------

-- Função recupera a Indicação da Forma de Apuração da Estimativa
function fkg_vlr_mes_bal_red ( ev_dm_per_apur in varchar2 )
         return abert_ecf_param_trib.dm_mes_bal_red1%type
is
   --
   vv_mes_bal_red abert_ecf_param_trib.dm_mes_bal_red1%type;
   --
begin
   --
   if ev_dm_per_apur = 'A01' then
      vv_mes_bal_red := pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red1;
   elsif ev_dm_per_apur = 'A02' then
      vv_mes_bal_red := pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red2;
   elsif ev_dm_per_apur = 'A03' then
      vv_mes_bal_red := pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red3;
   elsif ev_dm_per_apur = 'A04' then
      vv_mes_bal_red := pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red4;
   elsif ev_dm_per_apur = 'A05' then
      vv_mes_bal_red := pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red5;
   elsif ev_dm_per_apur = 'A06' then
      vv_mes_bal_red := pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red6;
   elsif ev_dm_per_apur = 'A07' then
      vv_mes_bal_red := pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red7;
   elsif ev_dm_per_apur = 'A08' then
      vv_mes_bal_red := pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red8;
   elsif ev_dm_per_apur = 'A09' then
      vv_mes_bal_red := pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red9;
   elsif ev_dm_per_apur = 'A10' then
      vv_mes_bal_red := pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red10;
   elsif ev_dm_per_apur = 'A11' then
      vv_mes_bal_red := pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red11;
   elsif ev_dm_per_apur = 'A12' then
      vv_mes_bal_red := pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red12;
   else
      vv_mes_bal_red := null;
   end if;
   --
   return vv_mes_bal_red;
   --
exception
   when others then
      return null;
end fkg_vlr_mes_bal_red;

-------------------------------------------------------------------------------------------------------

-- Função recupera a Forma de Tributação no Período
function fkg_vlr_forma_trib_per ( ev_dm_per_apur in abert_ecf_param_trib.dm_mes_bal_red1%type )
         return abert_ecf_param_trib.dm_forma_trib_per1%type
is
   --
   vv_forma_trib_per abert_ecf_param_trib.dm_forma_trib_per1%type;
   --
begin
   --
   if ev_dm_per_apur = 'T01' then
      vv_forma_trib_per := pk_csf_api_secf.gt_abert_ecf_param_trib.dm_forma_trib_per1;
   elsif ev_dm_per_apur = 'T02' then
      vv_forma_trib_per := pk_csf_api_secf.gt_abert_ecf_param_trib.dm_forma_trib_per2;
   elsif ev_dm_per_apur = 'T03' then
      vv_forma_trib_per := pk_csf_api_secf.gt_abert_ecf_param_trib.dm_forma_trib_per3;
   elsif ev_dm_per_apur = 'T04' then
      vv_forma_trib_per := pk_csf_api_secf.gt_abert_ecf_param_trib.dm_forma_trib_per4;
   else
      vv_forma_trib_per := null;
   end if;
   --
   return vv_forma_trib_per;
   --
exception
   when others then
      return null;
end fkg_vlr_forma_trib_per;

-------------------------------------------------------------------------------------------------------

-- Função retorna o código ECF do "Tipo de Código de arquivo" por pais

function fkg_cd_ecf_pais_tipo_cod_arq ( en_pais_id        in pais.id%type
                                      )
         return pais_tipo_cod_arq.cd%type
is
   --
   vn_tipocodarq_id      tipo_cod_arq.id%type := null;
   vv_paistipocodarq_cd  pais_tipo_cod_arq.cd%type := null;
   --
begin
   --
   vn_tipocodarq_id := pk_csf.fkg_tipocodarq_id ( ev_cd => '17' ); -- Sped ECF
   --
   if nvl(vn_tipocodarq_id,0) > 0 then
      --
      vv_paistipocodarq_cd := pk_csf.fkg_cd_pais_tipo_cod_arq ( en_pais_id        => en_pais_id
                                                              , en_tipocodarq_id  => vn_tipocodarq_id
                                                              );
      --
   end if;
   --
   return vv_paistipocodarq_cd;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_cd_ecf_pais_tipo_cod_arq:' || sqlerrm);
end fkg_cd_ecf_pais_tipo_cod_arq;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela PER_SLD_CC_ECD conforme chave única

function fkg_persldccecd_id ( en_aberturaecf_id  in per_sld_cc_ecd.aberturaecf_id%type
                            , ev_dm_per_apur     in per_sld_cc_ecd.dm_per_apur%type
                            , ed_dt_ini          in per_sld_cc_ecd.dt_ini%type
                            , ed_dt_fin          in per_sld_cc_ecd.dt_fin%type
                            )
         return per_sld_cc_ecd.id%type
is
   --
   vn_persldccecd_id per_sld_cc_ecd.id%type;
   --
begin
   --
   select id
     into vn_persldccecd_id
     from per_sld_cc_ecd
    where aberturaecf_id = en_aberturaecf_id
      and dm_per_apur    = ev_dm_per_apur
      and dt_ini         = ed_dt_ini
      and dt_fin         = ed_dt_fin;
   --
   return vn_persldccecd_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_persldccecd_id:' || sqlerrm);
end fkg_persldccecd_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela PER_DEMON_BP conforme chave única

function fkg_perdemonbp_id ( en_aberturaecf_id  in per_demon_bp.aberturaecf_id%type
                           , ev_dm_per_apur     in per_demon_bp.dm_per_apur%type
                           , ed_dt_ini          in per_demon_bp.dt_ini%type
                           , ed_dt_fin          in per_demon_bp.dt_fin%type
                           )
         return per_demon_bp.id%type
is
   --
   vn_perdemonbp_id per_demon_bp.id%type;
   --
begin
   --
   select id
     into vn_perdemonbp_id
     from per_demon_bp
    where aberturaecf_id = en_aberturaecf_id
      and dm_per_apur    = ev_dm_per_apur
      and dt_ini         = ed_dt_ini
      and dt_fin         = ed_dt_fin;
   --
   return vn_perdemonbp_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_perdemonbp_id:' || sqlerrm);
end fkg_perdemonbp_id;

-------------------------------------------------------------------------------------------------------

-- Função que verifica se existe o ID na tabela lcto_part_a_lacs_lalur
function fkg_lctopartalacslalur_id ( en_ccrlancpart_id     in ccr_lanc_part.id%type
                                   , en_intlctocontabil_id in int_lcto_contabil.id%type
                                   ) return lcto_part_a_lacs_lalur.id%type
is
   --
   vn_lctopartalacslalur_id        lcto_part_a_lacs_lalur.id%type;
   --
begin
   --
   vn_lctopartalacslalur_id := null;
   --
   select id
     into vn_lctopartalacslalur_id
     from lcto_part_a_lacs_lalur
    where ccrlancpart_id = en_ccrlancpart_id
      and intlctocontabil_id = en_intlctocontabil_id;
   --
   return vn_lctopartalacslalur_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_lctopartalacslalur_id:' || sqlerrm);
end fkg_lctopartalacslalur_id;

-------------------------------------------------------------------------------------------------------

-- Função que verifica se existe o ID na tabela ccr_lanc_part
function fkg_ccr_lanc_part_id ( en_lancvlrtabdin_id in lanc_vlr_tab_din.id%type
                              , en_planoconta_id    in plano_conta.id%type
                              , en_centrocusto_id   in centro_custo.id%type
                              ) return ccr_lanc_part.id%type
is
   --
   vn_ccrlancpart_id ccr_lanc_part.id%type;
   --
begin
   --
   select id
     into vn_ccrlancpart_id
     from ccr_lanc_part
    where lancvlrtabdin_id = en_lancvlrtabdin_id
      and planoconta_id    = en_planoconta_id
      and nvl(centrocusto_id,0) = nvl(en_centrocusto_id,0);
   --
   return vn_ccrlancpart_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_ccr_lanc_part_id:' || sqlerrm);
end fkg_ccr_lanc_part_id;

-------------------------------------------------------------------------------------------------------

-- Função que verifica se existe o ID na tabela ccr_lanc_part
function fkg_contapartb_id ( en_lancvlrtabdin_id in lanc_vlr_tab_din.id%type
                           , en_planoconta_id    in plano_conta.id%type
                           ) return conta_part_b.id%type
is
   --
   vn_contapartb_id conta_part_b.id%type;
   --
begin
   --
   select id
     into vn_contapartb_id
     from conta_part_b
    where lancvlrtabdin_id = en_lancvlrtabdin_id
      and planoconta_id    = en_planoconta_id;
   --
   return vn_contapartb_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_contapartb_id:' || sqlerrm);
end fkg_contapartb_id;

-------------------------------------------------------------------------------------------------------

-- Função que verifica se existe o ID na tabela lanc_vlr_tab_din

function fkg_exist_lancvlrtabdin ( en_lancvlrtabdin_id in lanc_vlr_tab_din.id%type
                                   ) return boolean
is
   --
   vn_exist     number;
   --
begin
   --
   vn_exist := 0;
   --
   begin
      --
      select 1
        into vn_exist
        from lanc_vlr_tab_din
       where id = en_lancvlrtabdin_id;
      --
   exception
    when no_data_found then
      vn_exist := 0;
   end;
   --
   if nvl(vn_exist,0) = 1 then
      return true;
   else
      return false;
   end if;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na fkg_exist_lancvlrtabdin:' || sqlerrm);
end fkg_exist_lancvlrtabdin;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela lanc_vlr_tab_din conforme chave única

function fkg_lancvlrtabdin_id ( ed_dt_ini       in lanc_vlr_tab_din.dt_ini%type
                              , ed_dt_fin       in lanc_vlr_tab_din.dt_fim%type
                              , en_empresa_id   in empresa.id%type
                              , en_tabdinecf_id in tab_din_ecf.id%type
                              ) return lanc_vlr_tab_din.id%type
is
   --
   vn_lancvlrtabdin_id        lanc_vlr_tab_din.id%type;
   --
begin
   --
   if trim(ed_dt_ini) is not null
    and nvl(en_empresa_id,0) > 0 
    and nvl(en_tabdinecf_id,0) > 0 then
      --
      select id
        into vn_lancvlrtabdin_id
        from lanc_vlr_tab_din
       where dt_ini              = ed_dt_ini
         and nvl(dt_fim,sysdate) = nvl(ed_dt_fin,sysdate)
         and empresa_id          = en_empresa_id  
         and tabdinecf_id        = en_tabdinecf_id;
      --
   end if;
   --
   return vn_lancvlrtabdin_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_lancvlrtabdin_id:' || sqlerrm);
end fkg_lancvlrtabdin_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela tab_din_ecf conforme chave única

function fkg_tabdinecf_id ( en_codentref_id    in  cod_ent_ref.id%type
                          , en_registroecf_id  in  registro_ecf.id%type
                          , ev_tabdinecf_cd    in  tab_din_ecf.cd%type
                          )
         return tab_din_ecf.id%type
is
   --
   vn_tabdinecf_id tab_din_ecf.id%type;
   --
begin
   --
   begin
      --
      select id
        into vn_tabdinecf_id
        from tab_din_ecf
      where nvl(codentref_id,0)    = nvl(en_codentref_id,0)
        and registroecf_id         = en_registroecf_id
        and cd                     = ev_tabdinecf_cd/*;*/
        and dt_fin is null;
      --
   exception
      when no_data_found then
         --
         select max(id)
           into vn_tabdinecf_id
           from tab_din_ecf
         where registroecf_id         = en_registroecf_id
           and cd                     = ev_tabdinecf_cd/*;*/
           and dt_fin is null;
         --
   end;
   --
   return vn_tabdinecf_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_tabdinecf_id:' || sqlerrm);
end fkg_tabdinecf_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela cod_ent_ref conforme o codigo 

function fkg_codentref_id ( ev_cod_ent_ref in cod_ent_ref.cod_ent_ref%type
                          ) return cod_ent_ref.id%type
is
   --
   vn_codentref_id  cod_ent_ref.id%type;
   --
begin
   --
   select id
     into vn_codentref_id
     from cod_ent_ref
    where cod_ent_ref = ev_cod_ent_ref;
   --
   return vn_codentref_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_codentref_id:' || sqlerrm);
end fkg_codentref_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela PER_APUR_LR conforme chave única

function fkg_perapurlr_id ( en_aberturaecf_id  in per_apur_lr.aberturaecf_id%type
                          , ev_dm_per_apur     in per_apur_lr.dm_per_apur%type
                          , ed_dt_ini          in per_apur_lr.dt_ini%type
                          , ed_dt_fin          in per_apur_lr.dt_fin%type
                          )
         return per_apur_lr.id%type
is
   --
   vn_perapurlr_id per_apur_lr.id%type;
   --
begin
   --
   select id
     into vn_perapurlr_id
     from per_apur_lr
    where aberturaecf_id = en_aberturaecf_id
      and dm_per_apur    = ev_dm_per_apur
      and dt_ini         = ed_dt_ini
      and dt_fin         = ed_dt_fin;
   --
   return vn_perapurlr_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_perapurlr_id:' || sqlerrm);
end fkg_perapurlr_id;
--------------------------------------------------------------------------------------------------------
-- Função retornar id da tabela per_apur_lr através do id da tabela abertura_ecf e as datas de inicio e fim.
--
function fkg_busca_perapurlr_id (en_aberturaecf_id  in per_apur_lr.aberturaecf_id%type
                                ,ed_dt_ini          in per_apur_lr.dt_ini%type
                                ,ed_dt_fin          in per_apur_lr.dt_fin%type) return per_apur_lr.id%type
is
   --
   vn_perapurlr_id           per_apur_lr.id%type;
   --
begin
   --
/*   vt_abert_ecf_param_trib: = fkg_abertecfparamtrib_id(en_aberturaecf_id => en_aberturaecf_id);*/
   --   
   select id into vn_perapurlr_id 
   from per_apur_lr 
   where aberturaecf_id = en_aberturaecf_id
     and dt_ini = ed_dt_ini
     and dt_fin = ed_dt_fin
     and dm_situacao not in (1,3);
   --   
   return vn_perapurlr_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_busca_perapurlr_id:' || sqlerrm);
end fkg_busca_perapurlr_id;   
-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela PER_CALC_APUR_LR conforme chave única

function fkg_percalcapurlr_id ( en_aberturaecf_id  in per_calc_apur_lr.aberturaecf_id%type
                              , ev_dm_per_apur     in per_calc_apur_lr.dm_per_apur%type
                              , ed_dt_ini          in per_calc_apur_lr.dt_ini%type
                              , ed_dt_fin          in per_calc_apur_lr.dt_fin%type
                              )
         return per_calc_apur_lr.id%type
is
   --
   vn_percalcapurlr_id per_calc_apur_lr.id%type;
   --
begin
   --
   select id
     into vn_percalcapurlr_id
     from per_calc_apur_lr
    where aberturaecf_id = en_aberturaecf_id
      and dm_per_apur    = ev_dm_per_apur
      and dt_ini         = ed_dt_ini
      and dt_fin         = ed_dt_fin;
   --
   return vn_percalcapurlr_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_percalcapurlr_id:' || sqlerrm);
end fkg_percalcapurlr_id;

-------------------------------------------------------------------------------------------------------

-- Função o número de mesês do "tipo de período"

function fkg_meses_periodo ( ev_dm_per_apur in varchar2
                           , ed_dt_ini      in date
                           , ed_dt_fin      in date
                           )
         return number
is
   --
   vn_qtde number;
   --
begin
   --
   /*
   if ev_dm_per_apur in ('T1', 'T2', 'T3', 'T4') then
      vn_qtde := 3;
   elsif ev_dm_per_apur in ('A00', 'A12') then
      vn_qtde := 12;
   elsif ev_dm_per_apur = 'A01' then
      vn_qtde := 1;
   elsif ev_dm_per_apur = 'A02' then
      vn_qtde := 2;
   elsif ev_dm_per_apur = 'A03' then
      vn_qtde := 3;
   elsif ev_dm_per_apur = 'A04' then
      vn_qtde := 4;
   elsif ev_dm_per_apur = 'A05' then
      vn_qtde := 5;
   elsif ev_dm_per_apur = 'A06' then
      vn_qtde := 6;
   elsif ev_dm_per_apur = 'A07' then
      vn_qtde := 7;
   elsif ev_dm_per_apur = 'A08' then
      vn_qtde := 8;
   elsif ev_dm_per_apur = 'A09' then
      vn_qtde := 9;
   elsif ev_dm_per_apur = 'A10' then
      vn_qtde := 10;
   elsif ev_dm_per_apur = 'A11' then
      vn_qtde := 11;
   else
      vn_qtde := 0;
   end if;*/
   --
   vn_qtde := round(MONTHS_BETWEEN(ed_dt_fin, ed_dt_ini));
   --
   return vn_qtde;
   --
exception
   when others then 
      return 0;
end fkg_meses_periodo;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela PER_CALC_APUR_LP conforme chave única

function fkg_percalcapurlp_id ( en_aberturaecf_id  in per_calc_apur_lp.aberturaecf_id%type
                              , ev_dm_per_apur     in per_calc_apur_lp.dm_per_apur%type
                              , ed_dt_ini          in per_calc_apur_lp.dt_ini%type
                              , ed_dt_fin          in per_calc_apur_lp.dt_fin%type
                              )
         return per_calc_apur_lp.id%type
is
   --
   vn_percalcapurlp_id per_calc_apur_lp.id%type;
   --
begin
   --
   select id
     into vn_percalcapurlp_id
     from per_calc_apur_lp
    where aberturaecf_id = en_aberturaecf_id
      and dm_per_apur    = ev_dm_per_apur
      and dt_ini         = ed_dt_ini
      and dt_fin         = ed_dt_fin;
   --
   return vn_percalcapurlp_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_percalcapurlp_id:' || sqlerrm);
end fkg_percalcapurlp_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela ctrl_saldo_part_b_lr conforme chave única
function fkg_ctrlsaldopartblr_id ( en_planoconta_id      in plano_conta.id%type
                                 , ev_dm_cod_tributo     in ctrl_saldo_part_b_lr.dm_cod_tributo%type
                                 )
         return ctrl_saldo_part_b_lr.id%type
is
   --
   vn_ctrlsaldopartblr_id ctrl_saldo_part_b_lr.id%type;
   --
begin
   --
   select id
     into vn_ctrlsaldopartblr_id
     from ctrl_saldo_part_b_lr
    where planoconta_id   = en_planoconta_id
      and dm_cod_tributo  = ev_dm_cod_tributo;
   --
   return vn_ctrlsaldopartblr_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_ctrlsaldopartblr_id:' || sqlerrm);
end fkg_ctrlsaldopartblr_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela PER_CALC_APUR_LA conforme chave única

function fkg_percalcapurla_id ( en_aberturaecf_id  in per_calc_apur_la.aberturaecf_id%type
                              , ev_dm_per_apur     in per_calc_apur_la.dm_per_apur%type
                              , ed_dt_ini          in per_calc_apur_la.dt_ini%type
                              , ed_dt_fin          in per_calc_apur_la.dt_fin%type
                              )
         return per_calc_apur_la.id%type
is
   --
   vn_percalcapurla_id per_calc_apur_la.id%type;
   --
begin
   --
   select id
     into vn_percalcapurla_id
     from per_calc_apur_la
    where aberturaecf_id = en_aberturaecf_id
      and dm_per_apur    = ev_dm_per_apur
      and dt_ini         = ed_dt_ini
      and dt_fin         = ed_dt_fin;
   --
   return vn_percalcapurla_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_percalcapurla_id:' || sqlerrm);
end fkg_percalcapurla_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela PER_CALC_APUR_II conforme chave única

function fkg_percalcapurii_id ( en_aberturaecf_id  in per_calc_apur_ii.aberturaecf_id%type
                              , ev_dm_per_apur     in per_calc_apur_ii.dm_per_apur%type
                              , ed_dt_ini          in per_calc_apur_ii.dt_ini%type
                              , ed_dt_fin          in per_calc_apur_ii.dt_fin%type
                              )
         return per_calc_apur_ii.id%type
is
   --
   vn_percalcapurii_id per_calc_apur_ii.id%type;
   --
begin
   --
   select id
     into vn_percalcapurii_id
     from per_calc_apur_ii
    where aberturaecf_id = en_aberturaecf_id
      and dm_per_apur    = ev_dm_per_apur
      and dt_ini         = ed_dt_ini
      and dt_fin         = ed_dt_fin;
   --
   return vn_percalcapurii_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_percalcapurii_id:' || sqlerrm);
end fkg_percalcapurii_id;

-------------------------------------------------------------------------------------------------------

-- Função que retorna o ID da tabela INF_MULT_DECL_PAIS

function fkg_infmultdeclpais_id ( en_empresa_id in empresa.id%type
                                , en_ano_ref    in inf_mult_decl_pais.ano_ref%type
                                ) return inf_mult_decl_pais.id%type
is
   --
   vn_infmultdeclpais_id   inf_mult_decl_pais.id%type;
   --
begin
   --
   vn_infmultdeclpais_id := null;
   --
   if nvl(en_empresa_id,0) > 0
    and nvl(en_ano_ref,0) > 0 then
      --
      select id 
        into vn_infmultdeclpais_id
        from inf_mult_decl_pais
       where empresa_id = en_empresa_id
         and ano_ref    = en_ano_ref;
      --
   end if;
   --
   return vn_infmultdeclpais_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_infmultdeclpais_id:' || sqlerrm);
end fkg_infmultdeclpais_id;

-------------------------------------------------------------------------------------------------------

-- Função que verifica se existe o ID na tabela INF_MULT_DECL_PAIS

function fkg_exist_infmultdeclpais ( en_infmultdeclpais_id in inf_mult_decl_pais.id%type
                                   ) return boolean
is
   --
   vn_exist number;
   --
begin
   --
   vn_exist := 0;
   --
   if nvl(en_infmultdeclpais_id,0) > 0 then
      --
      select 1
        into vn_exist
        from inf_mult_decl_pais
       where id = en_infmultdeclpais_id;
      --
   end if;
   --
   if nvl(vn_exist,0) = 1 then
      return true;
   else
      return false;
   end if;
   --
exception
   when no_data_found then
      return (false);
   when others then
      raise_application_error(-20101, 'Erro na fkg_exist_infmultdeclpais:' || sqlerrm);
end fkg_exist_infmultdeclpais;

-------------------------------------------------------------------------------------------------------

-- Função que verifica se recupera o código de identificação do registro a partir

function fkg_declpaisapais_id ( en_infmultdeclpais_id in inf_mult_decl_pais.id%type
                              , en_jurisdicaosecf_id  in jurisdicao_secf.id%type
                              ) return decl_pais_a_pais.id%type
is
   --
   vn_declpaisapais_id        decl_pais_a_pais.id%type;
   --
begin
   --
   vn_declpaisapais_id := null;
   --
   if nvl(en_infmultdeclpais_id,0) > 0 then
      --
      select id 
        into vn_declpaisapais_id
        from decl_pais_a_pais
       where infmultdeclpais_id = en_infmultdeclpais_id
         and nvl(jurisdicaosecf_id,0)  = nvl(en_jurisdicaosecf_id,0);
      --
   end if;
   --
   return vn_declpaisapais_id;
   --
exception
   when no_data_found then
      return vn_declpaisapais_id;
   when others then
      raise_application_error(-20101, 'Erro na fkg_declpaisapais_id:' || sqlerrm);
end fkg_declpaisapais_id;

-------------------------------------------------------------------------------------------------------

-- Função que verifica se recupera o código de identificação do registro da tabela decl_pais_a_pais_ent_integr a partir dos campos chave

function fkg_declpaisapaisentintegr_id ( en_declpaisapais_id       in decl_pais_a_pais.id%type
                                       , en_jurisdicaosecf_id      in jurisdicao_secf.id%type
                                       , ev_nome                   in varchar2
                                       , ev_tin                    in varchar2
                                       , en_jurisdicaosecf_id_tin  in jurisdicao_secf.id%type
                                       , ev_ni                     in varchar2
                                       , en_jurisdicaosecf_id_in   in jurisdicao_secf.id%type
                                       , ev_tipo_ni                in varchar2
                                       , ev_dm_tip_end             in varchar2
                                       , ev_endereco               in varchar2
                                       , ev_num_tel                in varchar2
                                       , ev_email                  in varchar2
                                       ) return decl_pais_a_pais_ent_integr.id%type
is
   --
   vn_declpaisapaisentintegr_id        decl_pais_a_pais_ent_integr.id%type;
   --
begin
   --
   vn_declpaisapaisentintegr_id := null;
   --
   if nvl(en_declpaisapais_id,0) > 0 
    and trim(ev_nome) is not null
    and trim(ev_tin) is not null
    and trim(ev_dm_tip_end) is not null
    and trim(ev_endereco) is not null then
      --
      select id
        into vn_declpaisapaisentintegr_id
        from decl_pais_a_pais_ent_integr
       where declpaisapais_id              = en_declpaisapais_id
         and nvl(jurisdicaosecf_id,0)      = nvl(en_jurisdicaosecf_id,0)
         and nome                          = ev_nome
         and tin                           = ev_tin
         and nvl(jurisdicaosecf_id_tin,0)  = nvl(en_jurisdicaosecf_id_tin,0)
         and nvl(ni,' ')                   = nvl(ev_ni,' ')
         and nvl(jurisdicaosecf_id_in,0)   = nvl(en_jurisdicaosecf_id_in,0)
         and nvl(tipo_ni,' ')              = nvl(ev_tipo_ni,' ')
         and nvl(dm_tip_end,' ')           = nvl(ev_dm_tip_end,' ')
         and endereco                      = ev_endereco
         and nvl(num_tel,' ')              = nvl(ev_num_tel,' ')
         and nvl(email,' ')                = nvl(ev_email,' ');
      --
   end if;
   --
   return vn_declpaisapaisentintegr_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_declpaisapaisentintegr_id:' || sqlerrm);
end fkg_declpaisapaisentintegr_id;


-------------------------------------------------------------------------------------------------------

-- Função que verifica se recupera o código de identificação do registro da tabela decl_pais_a_pais_obs_adic a partir dos campos chave
function fkg_declpaisapaisobsadic_id ( en_empresa_id        in empresa.id%type
                                     , ed_dt_ref            in decl_pais_a_pais_obs_adic.dt_ref%type
                                     , en_jurisdicaosecf_id in jurisdicao_secf.id%type
                                     ) return decl_pais_a_pais_obs_adic.id%type 
is
   --
   vn_declpaisapaisobsadic_id           decl_pais_a_pais_obs_adic.id%type;
   --
begin
   --
   vn_declpaisapaisobsadic_id := null;
   --
   if nvl(en_empresa_id,0) > 0
    and trim(ed_dt_ref) is not null then
      --
      select id
        into vn_declpaisapaisobsadic_id
        from decl_pais_a_pais_obs_adic
       where empresa_id               = en_empresa_id
         and dt_ref                   = ed_dt_ref
         and nvl(jurisdicaosecf_id,0) = nvl(en_jurisdicaosecf_id,0);
      --
   end if;
   --
   return vn_declpaisapaisobsadic_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_declpaisapaisobsadic_id:' || sqlerrm);
end fkg_declpaisapaisobsadic_id;

-------------------------------------------------------------------------------------------------------

-- Função que Verifica se o ID ja existe na tabela decl_pais_a_pais_obs_adic 
function fkg_verif_declpaisapaisobsadic ( en_declpaisapaisobsadic_id in decl_pais_a_pais_obs_adic.id%type
                                        ) return boolean
is
   --
   vn_exist number;
   --
begin
   --
   vn_exist := null;
   --
   if nvl(en_declpaisapaisobsadic_id,0) > 0 then
      --
      select 1
        into vn_exist
        from decl_pais_a_pais_obs_adic
       where id = en_declpaisapaisobsadic_id;
      --
   end if;
   --
   if nvl(vn_exist,0) > 0 then
      return true;
   else
      return false;
   end if;
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_verif_declpaisapaisobsadic:' || sqlerrm);
end fkg_verif_declpaisapaisobsadic;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela lanc_part_a_lalur conforme chave única
function fkg_lancpartalalur_id ( en_perapurlr_id  in lanc_part_a_lalur.perapurlr_id%type
                               , en_tabdinecf_id  in lanc_part_a_lalur.tabdinecf_id%type
                               /*, en_dm_tipo       in lanc_part_a_lalur.dm_tipo%type*/
                               )
         return lanc_part_a_lalur.id%type
is
   --
   vn_lancpartalalur_id lanc_part_a_lalur.id%type;
   --
begin
   --
   select id
   into vn_lancpartalalur_id   
   from lanc_part_a_lalur   
   where perapurlr_id   = en_perapurlr_id
     and tabdinecf_id   = en_tabdinecf_id
     /*and dm_tipo        = en_dm_tipo*/;
   --
   return vn_lancpartalalur_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_lancpartalalur_id:' || sqlerrm);
end fkg_lancpartalalur_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela lanc_part_a_lacs conforme chave única
function fkg_lancpartalacs_id ( en_perapurlr_id  in lanc_part_a_lacs.perapurlr_id%type
                               , en_tabdinecf_id  in lanc_part_a_lacs.tabdinecf_id%type
                               /*, en_dm_tipo       in lanc_part_a_lacs.dm_tipo%type*/
                               )
         return lanc_part_a_lacs.id%type
is
   --
   vn_lancpartalacs_id lanc_part_a_lacs.id%type;
   --
begin
   --
   select id
   into vn_lancpartalacs_id   
   from lanc_part_a_lacs   
   where perapurlr_id   = en_perapurlr_id
     and tabdinecf_id   = en_tabdinecf_id
     /*and dm_tipo        = en_dm_tipo*/;
   --
   return vn_lancpartalacs_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_lancpartalacs_id:' || sqlerrm);
end fkg_lancpartalacs_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela ccr_lanc_part_a_lalur conforme chave única
function fkg_ccrlancpartalalur_id ( en_lancpartalalur_id  in ccr_lanc_part_a_lalur.lancpartalalur_id%type
                                  , en_planoconta_id  in ccr_lanc_part_a_lalur.planoconta_id%type
                                  , en_centrocusto_id in ccr_lanc_part_a_lalur.centrocusto_id%type
                                  )
         return ccr_lanc_part_a_lalur.id%type
is
   --
   --#69546 inclusao do parametro en_centrocusto_id
   vn_ccrlancpartalalur_id ccr_lanc_part_a_lalur.id%type;
   --
begin
   --
   select id
   into vn_ccrlancpartalalur_id   
   from ccr_lanc_part_a_lalur   
   where lancpartalalur_id   = en_lancpartalalur_id
     and nvl(centrocusto_id, 0) = nvl(en_centrocusto_id,0) --#69546
     and planoconta_id       = en_planoconta_id;
   --
   return vn_ccrlancpartalalur_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_ccrlancpartalalur_id:' || sqlerrm);
end fkg_ccrlancpartalalur_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela ccr_lanc_part_a_lacs conforme chave única
function fkg_ccrlancpartalacs_id ( en_lancpartalacs_id  in ccr_lanc_part_a_lacs.lancpartalacs_id%type
                                 , en_planoconta_id  in ccr_lanc_part_a_lacs.planoconta_id%type
                                 , en_centrocusto_id in ccr_lanc_part_a_lacs.centrocusto_id%type
                                 )
         return ccr_lanc_part_a_lacs.id%type
is
   --
   --#69546 inlcusao parametro en_centrocusto_id
   vn_ccrlancpartalacs_id ccr_lanc_part_a_lacs.id%type;
   --
begin
   --
   select id
   into vn_ccrlancpartalacs_id   
   from ccr_lanc_part_a_lacs   
   where lancpartalacs_id   = en_lancpartalacs_id
     and nvl(centrocusto_id, 0) = nvl(en_centrocusto_id,0) --#69546
     and planoconta_id      = en_planoconta_id;
   --
   return vn_ccrlancpartalacs_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_ccrlancpartalacs_id:' || sqlerrm);
end fkg_ccrlancpartalacs_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela conta_part_b_lalur conforme chave única
function fkg_contapartblalur_id ( en_lancpartalalur_id  in conta_part_b_lalur.lancpartalalur_id%type
                                 , en_planoconta_id  in conta_part_b_lalur.planoconta_id%type
                                 )
         return conta_part_b_lalur.id%type
is
   --
   vn_contapartblalur_id conta_part_b_lalur.id%type;
   --
begin
   --
   select id
   into vn_contapartblalur_id   
   from conta_part_b_lalur   
   where lancpartalalur_id   = en_lancpartalalur_id
     and planoconta_id       = en_planoconta_id;
   --
   return vn_contapartblalur_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_contapartblalur_id:' || sqlerrm);
end fkg_contapartblalur_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela conta_part_b_lacs conforme chave única
function fkg_contapartblacs_id ( en_lancpartalacs_id  in conta_part_b_lacs.lancpartalacs_id%type
                               , en_planoconta_id     in conta_part_b_lacs.planoconta_id%type
                               )
         return conta_part_b_lacs.id%type
is
   --
   vn_ccrlancpartalacs_id ccr_lanc_part_a_lacs.id%type;
   --
begin
   --
   select id
   into vn_ccrlancpartalacs_id   
   from conta_part_b_lacs   
   where lancpartalacs_id   = en_lancpartalacs_id
     and planoconta_id      = en_planoconta_id;
   --
   return vn_ccrlancpartalacs_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_contapartblacs_id:' || sqlerrm);
end fkg_contapartblacs_id;

-------------------------------------------------------------------------------------------------------
-- Função retorna se cfop gera receita ou nao
function fkg_cfop_gera_rec (en_empresa_id in PARAM_CFOP_RECEITA_EMPRESA.EMPRESA_ID%type,
                            en_cfop_id    in PARAM_CFOP_RECEITA_EMPRESA.CFOP_ID%type)
                            return boolean is
   --
   vv_existe varchar2(1) := 'N';
   --
begin
   --
   begin
      select 'S'
        into vv_existe
        from PARAM_CFOP_RECEITA_EMPRESA p
       where p.empresa_id   = en_empresa_id
         and p.cfop_id      = en_cfop_id;
   exception
      when no_data_found then
         vv_existe := 'N';
      when too_many_rows then
         vv_existe := 'S';
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
end fkg_cfop_gera_rec;        
-------------------------------------------------------------------------------------------------------
-- Função retorna "true" se o código da moeda para o tipo de tabela (DM_TAB_MOEDA)-(0-Bacen/1-CBC) pais
-- for válido e "false" se não for, conforme ID

function fkg_tipo_moeda_id_valido ( en_tipo_moeda_id  in tipo_moeda.id%TYPE 
                                  , en_dm_tab_moeda   in tipo_moeda.dm_tab_moeda %TYPE )
         return boolean
is

   vn_dummy number := 0;

begin

   if nvl(en_tipo_moeda_id,0) > 0 and 
      nvl(en_dm_tab_moeda,0) > 0  then

      select 1
        into vn_dummy
        from tipo_moeda p
       where id = en_tipo_moeda_id
	     and dm_tab_moeda = en_dm_tab_moeda;

   end if;
   --
   if nvl(vn_dummy,0) > 0 then
      return true;
   else
      return false;
   end if;

exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_tipo_moeda_id_valido: ' || sqlerrm);
end fkg_tipo_moeda_id_valido;     
-------------------------------------------------------------------------------------------------------
-- Função para verificar se existe registro de erro gravados no log_generico (ECF) - Lucro Exploração
function fkg_ver_erro_log_generico_ecf( en_referencia_id in Log_Generico_inv.referencia_id%type )
         return number
is
   --
   vn_qtde      number := 0;
   --
begin
   --
   select count(1)
     into vn_qtde
     from Log_Generico li,
          csf_tipo_log tc
    where li.referencia_id  = en_referencia_id
      and li.obj_referencia = 'PER_LUCR_EXPL' 	
      and tc.id             = li.csftipolog_id
      and tc.dm_grau_sev    = 1;  -- erro
   --
   if nvl(vn_qtde,0) > 0 then
      return 1;  -- erro
   else
      return 0;  -- só aviso/informação
   end if;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Problemas em pk_csf_secf.fkg_ver_erro_log_generico_ecf. Erro = '||sqlerrm);
end fkg_ver_erro_log_generico_ecf;
-------------------------------------------------------------------------------------------------------
end pk_csf_secf;
/
