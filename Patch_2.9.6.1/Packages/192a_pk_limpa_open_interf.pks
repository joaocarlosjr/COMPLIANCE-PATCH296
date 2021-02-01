create or replace package csf_own.pk_limpa_open_interf is
   --
-----------------------------------------------------------------------------------------------------------------------------------------------------------
    -- 
    -- Em 26/01/2021  - Wendel Albino
    -- Redmine #75492 - Não implementadoo processo de Limpa Open Interface para as novas views
    -- Rotina Alterada- pkb_limpa_inventario   -> inclusao das novas views vw_csf_invent_inf_comp_merc_st 
    --                - pkb_limpa_nf_mercantis -> inclusao das novas views vw_csf_nf_inf_compl_op_ent_st, vw_csf_nf_inf_compl_op_sai_st 
    --
    -- Em 12/11/2020  - Wendel Albino
    -- Redmine #70990 - Ajuste pk_limpa_open_interf
    -- Rotina Alterada- pkb_limpar, pkb_limpar_empr -> incluida chamada da nova procedure (pkb_limpa_nf_mercantis_nfce) OBJETO 13
    --                -   para limpar views de integracao de notas modelos 65.
    --                -   E alterada a procedure pkb_limpa_nf_mercantis para limpar somente <> 65.
    --
    -- Em 29/10/2020  - Wendel Albino
    -- Redmine #72357 - Limpa open interface
    -- Rotina Alterada- pkb_limpar, pkb_limpar_empr -> incluida chamada da nova procedure (pkb_limpa_conhec_transp_ep)
    --                -   para limpar views de integracao de CTE de emissao propria.
    --
    -- Em 16/09/2020 - Eduardo Linden
    -- Redmine #70754 - Troca do campo CNPJ para o registro Y560 - ECF (PL/SQL)
    -- Trocar o campo CPF_CNPJ_ESTAB para COD_PART nas views VW_CSF_DET_EXP_COM_IG e VW_CSF_DET_EXP_COM_IG_FF.
    -- Rotina afetada: pkb_limpa_secf
    -- Liberado para Release 295 e os patchs 2.9.4.3 e 2.9.3.6.
    --
    -- Em 18/11/2019 - Allan Magrini
    -- Redmine #58231: Alteração do desprocessamento - Limpeza das views (Cadastros Gerais)
    -- Adicionado o cursor c_csf_pc_referen_ff_emp e colocada na fase 37 para verificar o cursor c_csf_pc_referen_ff e na fase 41 c_csf_pc_referen_ff_emp
    -- para pegar as informações do delete
    -- Rotina Alterada:  pkb_limpar_empr, pkb_limpa_cad
    --
    -- Em 11/09/2019 - Allan Magrini
    -- Redmine #58231: Alteração do desprocessamento - Limpeza das views (Cadastros Gerais)
    -- Colocada passagem de parametro na chamada da pkb_limpa_cad.
    -- Rotina Alterada:  pkb_limpar_empr, pkb_limpa_cad
    --
    -- Em 19/08/2019 - Eduardo Linden
    -- Redmine #57710: Criar nova rotina de limpeza - pk_limpa_open_interf.pkb_limpar_empr
    -- Criação de rotina de limpeza de interface por empresa, baseada na rotina pkb_limpar.
    -- Rotina Criada:  pkb_limpar_empr
    --
    -- Em 15/02/2019 - Karina de Paula
    -- Redmine #51625 - Alterar a integracao dos novos campos view VW_CSF_NOTA_FISCAL_LOCAL para VW_CSF_NOTA_FISCAL_LOCAL_FF
    -- Rotina Alterada: pkb_limpa_nf_mercantis => Incluída a exclusão da view vw_csf_nota_fiscal_local_ff
    --
    -- Em 15/01/2019 - Eduardo Linden
    -- Redmine #49826 - Processos de Integração e Validação do Controle de Produção e Estoque - Bloco K.
    -- Inclusão das novas tabelas de interfaces para o processo de limpeza: VW_CSF_PROD_CJTA_ORDPROD, VW_CSF_PROD_CJTA_ITEMPROD, VW_CSF_PROD_CJTA_INSCONS,
    -- VW_CSF_PROD_CJTA_INDTERC, VW_CSF_PROD_CJTA_INDTERC_IP e VW_CSF_PROD_CJTA_INDTERC_IC
    -- Rotina Alterada: pkb_limpa_ctrl_prod_estoque
    --
--
-----------------------------------------------------------------------------------------------------------------------------------------------------------
    --* Redmine: #21208
    --* Atividade: 7.1 001 ¿ Processo de Apagar dados das Tabelas Open-Interface (VW_CSF)
    --* Desenvolvedor: Marcos Garcia
    --* Rotina: pkb_limpar
    --
    -- Em 08/03/2017 - Angela Inês.
    -- Redmine #29141 - Correção nos processos que utilizam SYSDATE como condição de pesquisa de período.
    -- Alterar os processos que utilizam "sysdate" incluindo o comando "trunc" para eliminar a hora.
    -- Rotina: pkb_limpa_ctrl_prod_estoque.
    --
    -- Em 29/06/2017 - Marcos Garcia
    -- Redmine #32388 - Processo que faz a limpeza nas views(open-interface)
    -- Modificação no processo de limpeza(Objeto cadastro), irá agora fazer um teste antes de limpar as views
    -- o teste informa se o cliente trabalha com a nuvem ou não. Sendo na nuvem limpa a partir das tabelas FF
    -- caso contrario limpa todas as views do objeto cadastro.
    --
    -- Em 03/07/2017 - Fábio Tavares
    -- Implementação: do processo que apaga as Views do Sped ECF
    -- Rotina: pkb_limpa_secf.
    --
    -- Em 18/07/2017 - Marcelo Ono
    -- Redmine #33575 - Implementação do processo que limpa a View (VW_CSF_REG_NF_SERV_CONT_DIFAL)
    -- Rotina: pkb_limpa_nfs_cont.
    --
    -- Em 02/10/2017 - Marcelo Ono
    -- Redmine #34948 - Correções no processo de Integração Table/view 06 Nota Fiscal Mercantil NFe 4.00
    -- Implementação do processo que limpa a View (VW_CSF_ITEMNF_RASTREAB)
    -- Rotina: pkb_limpa_nf_mercantis.
    --
    -- Em 11/10/2017 - Fábio Tavares
    -- Redmine #33860 - Integração de dados do Sped Reinf - Limpeza de View
    -- Rotina: pkb_limpa_reinf.
    --
    -- Em 15/01/2018 - Angela Inês.
    -- Redmine #38478 - Incluir o processo de Informação sobre Exportação na limpeza das Tabelas/Views de Integração.
    -- Alterar o processo para considerar o Objeto de integração '53-Informação sobre Exportação'.
    -- Rotina: pkb_limpa_infexp.
    --
    -- Em 17/01/2018 - Angela Inês.
    -- Redmine #38572 - Alterar o processo para limpar o Objeto de integração '53-Informação sobre Exportação'.
    -- Considerar a própria data do documento de Informação sobre Exportação quando as datas inicial e final forem nulas.
    -- Rotina: pkb_limpa_infexp.
    -- Redmine #38580 - Alterar o processo para limpar o Objeto de integração '53-Informação sobre Exportação'.
    -- O campo NRO_RE pode ser nulo, portanto considerar essa condição ao recuperar os registros de Informação sobre Exportação vinculados com Notas Fiscais.
    -- Rotina: pkb_limpa_infexp.
    --
    -- Em 22/01/2018 - Angela Inês.
    -- Redmine #38740 - Correção nos processos de Informação Sobre Exportação - Recuperação dos registros.
    -- Alterar os objetos que utilizam a tabela de Informação Sobre Exportação e considerar a DATA DE AVERBAÇÃO (DT_AVB) ao invés de considerar a DATA DA
    -- DECLARAÇÃO (DT_DE), para recuperação dos registros.
    -- Rotina: pkb_limpa_infexp.
    --
    -- Em 08/02/2018 - Karina de Paula
    -- Redmine #39221 - Alteração nos processos de Informações sobre Exportação - Coluna CHC_EMB.
    -- Rotina Alterada: pkb_limpa_infexp => Incluído a coluna chc_emb no cursor c_infexp, nos parâmetros de entrada e cláusula where do cursor c_infexpnf
    -- Alterado o delete das views vw_csf_oper_export_ind_nf, vw_csf_infor_export_nf e vw_csf_infor_exportacao_ff incluindo nova coluna chc_emb
   --
    -- Em 08/02/2018 - Marcelo Ono
    -- Redmine #39282 - Implementação do processo que limpa a view (VW_CSF_PESSOA_INFO_PIR)
    -- Rotina: pkb_limpa_cad.
    --
    -- Em 09/02/2018 - Marcelo Ono
    -- Redmine #39287 - Implementação do processo que limpa a view (VW_CSF_PIR_INFO_EXT).
    -- Rotina: pkb_limpa_pgto_imp.
    --
    -- Em 15/02/2018 - Angela Inês.
    -- Redmine #39400 - Alterações conforme guia prático da EFD ICMS/IPI.
    -- Incluir a coluna QTD_DEST na view de Integração VW_CSF_OUTR_MOVTO_INTER_MERC, e na tabela OUTR_MOVTO_INTER_MERC.
    -- Rotina: pkb_limpa_ctrl_prod_estoque.
    --
    -- Em 23/02/2018 - Karina de Paula
    -- Redmine #39669 - Ajuste Leiaute e Documentação - INFOR. EXPORTAÇÃO
    -- Analisado e alterado a posiçã do campo CHC_EMB nas alterações executadas pelo Redmine #39221
    --
    -- Em 13/07/2018 - Marcos Ferreira
    -- Redmine #40480 - Limpeza de Open Interface - layout Controle de Estoque
    -- Defeito: Não está limpando todas as Vws de Controle de Estoque
    -- Correção: Algumas Vws utilizam data de operação, data de abertura de os, e existe violação da chave na deleção, pois
    --           a Vw pai, utiliza datas como período de apuração.
    --           Fiz correção em alguns cursores para contemplar o período de apuração e alguns deletes precisei remover a data
    --           da clausula Where para dar certo.
    --
    -- Em 18/10/2018 - Karina de Paula
    -- Redmine #39990 - Adpatar o processo de geração da DIRF para gerar os registros referente a pagamento de rendimentos a participantes localizados no exterior
    -- Rotina Alterada: pkb_limpa_dirf => Incluída a rotina para RPDE
    --
    -- Em 09/11/2018 - Karina de Paula
    -- Redmine #43321 - Falha no processo "Limpa Open Interface" (FRONERI)
    -- Rotina Alterada: pkb_limpa_cad => Reorganizados os nomes dos cursores FF para levar o mesmo nome da view, alterada a ordem de alguns
    -- deletes para seguir o mesmo padrão. Criado o loop c_csf_pc_referen_ff para deleção da VW_CSF_PC_REFEREN e VW_CSF_PC_REFEREN_FF e retirada
    -- a deleção dessas views do loop c_csf_plano_conta_ff.
    -- Criada delete no tratamento de clientes na nuvem para as views:  VW_CSF_NAT_OPER_SERV / VW_CSF_PARAM_IMP_NAT_OPER_SERV / VW_CSF_NAT_OPER_TIPOIMP / VW_CSF_PC_REFEREN_PERIOD / VW_CSF_PC_AGLUT_CONTABIL
    -- VW_CSF_AGLUT_CONTABIL / VW_CSF_PARAM_ITEM_ENTR / VW_CSF_PARAM_OPER_FISCAL_ENTR
    --  c_csf_subgrupo_pat_ff, c_csf_rec_imp_subgrupo_pat_ff, c_csf_infor_util_bem_ff /c_csf_bem_ativo_imob_compl_ff/c_csf_recimp_bemativo_imob_ff
    -- c_csf_nf_bem_ativo_imob_ff / c_csf_itnf_bem_ativo_imob_ff / csf_obs_lancto_fiscal_ff
    --
    -- Em 24/12/2018 - Angela Inês.
    -- Redmine #49824 - Processos de Integração e Validações de Nota Fiscal (vários modelos).
    -- Incluir os processos de integração, validações api e ambiente, para a tabela/view VW_CSF_ITEMNF_RES_ICMS_ST e tabela ITEMNF_RES_ICMS_ST. Esse processo se
    -- refere aos modelos de notas fiscais 01-Nota Fiscal, e 55-Nota Fiscal Eletrônica, e são utilizados para montagem do Registro C176-Ressarcimento de ICMS e
    -- Fundo de Combate à Pobreza (FCP) em Operações com Substituição Tributária (Código 01, 55), do arquivo Sped Fiscal.
    -- Rotina: pkb_limpa_nf_mercantis.
    --

--|VARIAVEIS|--
   --
   gn_multorg_id     mult_org.id%type;
   gn_objintegr_id   obj_integr.id%type;
   gn_usuario_id     neo_usuario.id%type;
   gn_empresa_id     empresa.id%type;
   --
   gd_dt_ini         date;
   gd_dt_fin         date;
   --
   gv_cod_mult_org   mult_org.cd%type;
   gv_nome_usuario   neo_usuario.nome%type;
   gv_desc_objintegr obj_integr.descr%type;
   gv_cd_objintegr   obj_integr.cd%type;
   gv_cnpj           varchar2(14);
   --
   gv_tipo_sistema   varchar2(5);
   --
-----------------------------------------------------------------
--| PROCESSO QUE INICIA A LIMPEZA OPEN-INTEFACE |--
-----------------------------------------------------------------
   procedure pkb_limpar ( en_multorg_id   in mult_org.id%type
	                , en_objintegr_id in obj_integr.id%type
	                , en_usuario_id   in neo_usuario.id%type
	                , ed_dt_ini       in date default null
	                , ed_dt_fin       in date default null
	                );
   --
-------------------------------------------------------------------
--| PROCESSO QUE INICIA A LIMPEZA POR EMPRESA, PROCESSO PUBLICO |--
-------------------------------------------------------------------
   procedure pkb_limpar_empr ( en_empresa_id   in empresa.id%type
                             , en_objintegr_id in obj_integr.id%type
                             , en_usuario_id   in neo_usuario.id%type
                             , ed_dt_ini       in date default null
                             , ed_dt_fin       in date default null
                             );
   --
end pk_limpa_open_interf;
/
