create or replace package body csf_own.pk_csf is

-------------------------------------------------------------------------------------------------------
-- Corpo do pacote de funções para o CSF
-------------------------------------------------------------------------------------------------------

----Função que retorna o id da tabela PARAM_ITEM_ENTR, conforme sua unique.
function fkg_paramitementr_id ( en_empresa_id     in number
                              , ev_cnpj_orig      in varchar2
                              , en_ncm_id_orig    in number
                              , ev_cod_item_orig  in varchar2
                              , en_item_id_dest   in number )
return param_item_entr.id%type
is
   --
   vn_fase number;
   vn_id   number;
   --
begin
   --
   vn_fase := 1;
   --
   begin
      --
      select pi.id
        into vn_id
        from param_item_entr pi
       where pi.empresa_id    = en_empresa_id
         and pi.cnpj_orig     = ev_cnpj_orig
         and pi.ncm_id_orig   = en_ncm_id_orig
         and pi.cod_item_orig = ev_cod_item_orig
         and pi.item_id_dest  = en_item_id_dest;
      --
   exception
      when others then
         --
         vn_id := null;
         --
   end;
   --
   return vn_id;
   --
exception
   when others then
      --
      return null;
      --
end;
-------------------------------------------------------------

--| Função que retorna o id da tabela PARAM_OPER_FISCAL_ENTR, conforme sua unique.
function fkg_paramoperfiscalentr_id ( en_empresa_id         in number
                                    , en_cfop_id_orig       in number
                                    , ev_cnpj_orig          in varchar2
                                    , en_ncm_id_orig        in number
                                    , en_item_id_orig       in number
                                    , en_codst_id_icms_orig in number
                                    , en_codst_id_ipi_orig  in number )
return param_oper_fiscal_entr.id%type
is
   --
   vn_fase number;
   vn_id   number;
   --
begin
   --
   vn_fase := 1;
   --
   select p.id
     into vn_id
     from param_oper_fiscal_entr p
    where  empresa_id                 = en_empresa_id
      and  cfop_id_orig               = en_cfop_id_orig
      and  nvl(cnpj_orig, '0')        = nvl(ev_cnpj_orig, '0')         --null
      and  nvl(ncm_id_orig, 0)        = nvl(en_ncm_id_orig, 0)         --null
      and  nvl(item_id_orig, 0)       = nvl(en_item_id_orig, 0)        --null
      and  nvl(codst_id_icms_orig, 0) = nvl(en_codst_id_icms_orig, 0)  --null
      and  nvl(codst_id_ipi_orig, 0)  = nvl(en_codst_id_ipi_orig, 0);  --null
   --
   return vn_id;
   --
exception
   when others then
      --
      return null;
      --
end fkg_paramoperfiscalentr_id;

------------------------------------------------------------------------


-- Função formata o valor na mascara deseja pelo usuário
function fkg_formata_num ( en_num in number
                         , ev_mascara in varchar2
                         )
         return varchar2
is
   --
begin
   --
   if trim(ev_mascara) is not null then
      --
      return rtrim(ltrim(to_char(en_num, ev_mascara)));
      --
   else
      --
      return null;
      --
   end if;
   --
exception
   when others then
      return null;
end fkg_formata_num;

----------------------------------------------------------------------------------------------------

--| Função retorno o valor do Parâmetro Global Formato Data do Sistema
function fkg_param_global_csf_form_data
         return param_global_csf.valor%type
is
   --
   vv_paramglobalcsf_valor param_global_csf.valor%type := null;
   --
begin
   --
   select valor
     into vv_paramglobalcsf_valor
     from param_global_csf
    where cd = 'FORMATO_DATA';
   --
   return vv_paramglobalcsf_valor;
   --
exception
   when others then
      return 'dd/mm/rrrr';
end fkg_param_global_csf_form_data;

-------------------------------------------------------------------------------------------------------

-- Função retor do ID da Mult-Organização conforme código

function fkg_multorg_id ( ev_multorg_cd in mult_org.cd%type )
         return mult_org.id%type
is
   --
   vn_multorg_id mult_org.id%type;
   --
begin
   --
   select id
     into vn_multorg_id
     from mult_org
    where cd = ev_multorg_cd;
   --
   return vn_multorg_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_multorg_id:' || sqlerrm);
end fkg_multorg_id;

-------------------------------------------------------------------------------------------------------

-- Função verifica se o ID da Mult-Organização é valido

function fkg_valida_multorg_id ( en_multorg_id in mult_org.id%type )
         return boolean
is
   --
   vn_dummy number;
   --
begin
   --
   select distinct 1
     into vn_dummy
     from mult_org
    where id = en_multorg_id;
   --
   return (nvl(vn_dummy,0) > 0);
   --
exception
   when others then
      return false;
end fkg_valida_multorg_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna MULTORG_ID da Empresa

function fkg_multorg_id_empresa ( en_empresa_id in empresa.id%type )
         return mult_org.id%type
is
   --
   vn_multorg_id mult_org.id%type;
   --
begin
   --
   select multorg_id
     into vn_multorg_id
     from empresa
    where id = en_empresa_id;
   --
   return vn_multorg_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_multorg_id_empresa:' || sqlerrm);
end fkg_multorg_id_empresa;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da empresa Matriz

function fkg_empresa_id_matriz ( en_empresa_id  in empresa.id%type )
         return empresa.id%type
is
   --
   vn_empresa_id empresa.id%type;
   --
begin
   --
   select nvl(e.ar_empresa_id, e.id)
     into vn_empresa_id
     from empresa e
    where e.id = en_empresa_id;
   --
   return vn_empresa_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_id_matriz:' || sqlerrm);
end fkg_empresa_id_matriz;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Msg_WebServ

function fkg_Msg_WebServ_id ( en_cd  in Msg_WebServ.cd%TYPE )
         return Msg_WebServ.id%TYPE
is

   vn_msgwebserv_id  Msg_WebServ.id%TYPE;

begin

   select id
     into vn_msgwebserv_id
     from Msg_WebServ
    where cd = en_cd;

   return vn_msgwebserv_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Msg_WebServ_id:' || sqlerrm);
end fkg_Msg_WebServ_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o tipo de efeito da mensagem do webserv

function fkg_Efeito_Msg_WebServ ( en_msgwebserv_id  in Msg_WebServ.id%TYPE
                                , en_cd             in Msg_WebServ.cd%TYPE )
         return Msg_WebServ.dm_efeito%TYPE
is

   vn_dm_efeito Msg_WebServ.dm_efeito%TYPE := null;

begin

   select dm_efeito
     into vn_dm_efeito
     from Msg_WebServ
    where (id = en_msgwebserv_id or cd = en_cd);

   return vn_dm_efeito;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Efeito_sg_WebServ:' || sqlerrm);
end fkg_Efeito_Msg_WebServ;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tebale Mod_Fiscal

function fkg_Mod_Fiscal_id ( ev_cod_mod  in Mod_Fiscal.cod_mod%TYPE )
         return Mod_Fiscal.id%TYPE
is

   vn_modfiscal_id  Mod_Fiscal.id%TYPE;

begin

   select id
     into vn_modfiscal_id
     from Mod_Fiscal
    where cod_mod = ev_cod_mod;

   return vn_modfiscal_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Mod_Fiscal_id:' || sqlerrm);
end fkg_Mod_Fiscal_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Tipo_Servico

function fkg_Tipo_Servico_id ( ev_cod_lst  in Tipo_Servico.cod_lst%TYPE )
         return Tipo_Servico.id%TYPE
is
   --
   vn_tpservico_id Tipo_Servico.id%TYPE := 0;
   vv_cod_lst      Tipo_Servico.cod_lst%TYPE;
   --
begin
   --
   begin
      --
      select id
        into vn_tpservico_id
        from Tipo_Servico
       where cod_lst = ev_cod_lst;
      --
   exception
      when others then
      --
      vn_tpservico_id := 0;
      --
   end;
   --
   if nvl(vn_tpservico_id,0) = 0 then
      --
      begin
         --
         select max(id)
           into vn_tpservico_id
           from Tipo_Servico
          where to_number(replace(cod_lst, '.', '')) = to_number(replace(ev_cod_lst, '.', ''));
      exception
         when others then
         vn_tpservico_id := null;
      end;
      --
   end if;
   --
   return vn_tpservico_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Tipo_Servico_id:' || sqlerrm);
end fkg_Tipo_Servico_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela Classe_Enq_IPI

function fkg_Classe_Enq_IPI_id ( ev_cl_enq  in Classe_Enq_IPI.cl_enq%TYPE )
         return Classe_Enq_IPI.id%TYPE
is

   vn_classenqipi_id  Classe_Enq_IPI.id%TYPE;

begin

   select id
     into vn_classenqipi_id
     from Classe_Enq_IPI
    where cl_enq = ev_cl_enq;

   return vn_classenqipi_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Classe_Enq_IPI_id:' || sqlerrm);
end fkg_Classe_Enq_IPI_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna o CL_ENQ da tabela Classe_Enq_IPI conforme ID

function fkg_Classe_Enq_IPI_cd ( en_classeenqipi_id  in Classe_Enq_IPI.id%TYPE )
         return classe_enq_ipi.cl_enq%type
is

   vv_cl_enq  classe_enq_ipi.cl_enq%type;

begin

   select cl_enq
     into vv_cl_enq
     from Classe_Enq_IPI
    where id = en_classeenqipi_id;

   return vv_cl_enq;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Classe_Enq_IPI_cd:' || sqlerrm);
end fkg_Classe_Enq_IPI_cd;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Selo_Contr_IPI

function fkg_Selo_Contr_IPI_id ( ev_cod_selo_ipi  in Selo_Contr_IPI.cod_selo_ipi%TYPE )
         return Selo_Contr_IPI.id%TYPE
is

   vn_selocontripi_id  Selo_Contr_IPI.id%TYPE;

begin

   select id
     into vn_selocontripi_id
     from Selo_Contr_IPI
    where cod_selo_ipi = ev_cod_selo_ipi;

   return vn_selocontripi_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Selo_Contr_IPI_id:' || sqlerrm);
end fkg_Selo_Contr_IPI_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o CD da tabela Selo_Contr_IPI conforme ID

function fkg_Selo_Contr_IPI_cd ( en_selocontripi_id  in Selo_Contr_IPI.id%TYPE )
         return selo_contr_ipi.cod_selo_ipi%type
is

   vv_cod_selo_ipi  selo_contr_ipi.cod_selo_ipi%type;

begin

   select cod_selo_ipi
     into vv_cod_selo_ipi
     from Selo_Contr_IPI
    where id = en_selocontripi_id;

   return vv_cod_selo_ipi;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Selo_Contr_IPI_cd:' || sqlerrm);
end fkg_Selo_Contr_IPI_cd;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Unidade

function fkg_Unidade_id ( en_multorg_id  in mult_org.id%type
                        , ev_sigla_unid  in Unidade.sigla_unid%TYPE
                        )
         return Unidade.id%TYPE
is

   vn_unidade_id  Unidade.id%TYPE;

begin

   select id
     into vn_unidade_id
     from Unidade
    where multorg_id = en_multorg_id
      and sigla_unid = ev_sigla_unid;

   return vn_unidade_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Unidade_id:' || sqlerrm);
end fkg_Unidade_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Tipo_Item

function fkg_Tipo_Item_id ( ev_cd  in Tipo_Item.cd%TYPE )
         return Tipo_Item.id%TYPE
is

   vn_tipoitem_id  Tipo_Item.id%TYPE;
   vv_tipoitem_cd  Tipo_Item.cd%TYPE;

begin
   --
   vv_tipoitem_cd := lpad(ev_cd, 2, '0');
   --
   select id
     into vn_tipoitem_id
     from Tipo_Item
    where cd = vv_tipoitem_cd;

   return vn_tipoitem_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Tipo_Item_id:' || sqlerrm);
end fkg_Tipo_Item_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela Nat_Oper

function fkg_Nat_Oper_id ( en_multorg_id in mult_org.id%type
                         , ev_cod_nat    in Nat_Oper.cod_nat%TYPE )
         return Nat_Oper.id%TYPE
is

   vn_natoper_id  Nat_Oper.id%TYPE;

begin

   select id
     into vn_natoper_id
     from Nat_Oper
    where cod_nat = ev_cod_nat
      and multorg_id = en_multorg_id;

   return vn_natoper_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Nat_Oper_id:' || sqlerrm);
end fkg_Nat_Oper_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela Orig_Proc

function fkg_Orig_Proc_id ( en_cd  in Orig_Proc.cd%TYPE )
         return Orig_Proc.id%TYPE
is

   vn_origproc_id  Orig_Proc.id%TYPE;

begin

   select id
     into vn_origproc_id
     from Orig_Proc
    where cd = en_cd;

   return vn_origproc_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Orig_Proc_id:' || sqlerrm);
end fkg_Orig_Proc_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna o CD da tabela Orig_Proc conforme ID

function fkg_Orig_Proc_cd ( en_origproc_id  in Orig_Proc.id%TYPE )
         return Orig_Proc.cd%TYPE
is

   vn_origproc_cd  Orig_Proc.cd%TYPE;

begin

   select cd
     into vn_origproc_cd
     from Orig_Proc
    where id = en_origproc_id;

   return vn_origproc_cd;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Orig_Proc_cd:' || sqlerrm);
end fkg_Orig_Proc_cd;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela Sit_Docto

function fkg_Sit_Docto_id ( ev_cd  in Sit_Docto.cd%TYPE )
         return Sit_Docto.id%TYPE
is

   vn_sitdocto_id  Sit_Docto.id%TYPE;
   vv_cd  Sit_Docto.cd%TYPE;

begin

   vv_cd := lpad(ev_cd, 2, '0');

   select id
     into vn_sitdocto_id
     from Sit_Docto
    where cd = vv_cd;

   return vn_sitdocto_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Sit_Docto_id:' || sqlerrm);
end fkg_Sit_Docto_id;

-------------------------------------------------------------------------------------------------------
--| Função retorna o CD da tabela Sit_Docto

function fkg_Sit_Docto_cd ( en_sitdoc_id  in Sit_Docto.id%TYPE )
         return Sit_Docto.cd%TYPE
is

   vn_sitdocto_cd  Sit_Docto.cd%TYPE := null;

begin

  if nvl(en_sitdoc_id, 0) > 0  then
     --
     select cd
       into vn_sitdocto_cd
       from Sit_Docto
      where id = en_sitdoc_id;
     --
  end if;

   return vn_sitdocto_cd;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Sit_Docto_cd:' || sqlerrm);
end fkg_Sit_Docto_cd;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela Infor_Comp_Dcto_Fiscal

function fkg_Infor_Comp_Dcto_Fiscal_id ( en_multorg_id in mult_org.id%type
                                       , en_cod_infor  in Infor_Comp_Dcto_Fiscal.cod_infor%TYPE )
         return Infor_Comp_Dcto_Fiscal.id%TYPE
is

   vn_infcompdctofis_id  Infor_Comp_Dcto_Fiscal.id%TYPE;

begin

   select id
     into vn_infcompdctofis_id
     from Infor_Comp_Dcto_Fiscal
    where cod_infor = trim(en_cod_infor)
      and multorg_id = en_multorg_id;

   return vn_infcompdctofis_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Infor_Comp_Dcto_Fiscal_id:' || sqlerrm);
end fkg_Infor_Comp_Dcto_Fiscal_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela Tipo_Imposto

function fkg_Tipo_Imposto_id ( en_cd  in Tipo_Imposto.cd%TYPE )
         return Tipo_Imposto.id%TYPE
is

   vn_tipoimp_id  Tipo_Imposto.id%TYPE;

begin

   select id
     into vn_tipoimp_id
     from Tipo_Imposto
    where cd = en_cd;

   return vn_tipoimp_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Tipo_Imposto_id:' || sqlerrm);
end fkg_Tipo_Imposto_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela Cod_ST

function fkg_Cod_ST_id ( ev_cod_st      in Cod_ST.cod_st%TYPE
                       , en_tipoimp_id  in Cod_ST.id%TYPE )
         return Cod_ST.id%TYPE
is

   vn_codst_id  Cod_ST.id%TYPE;

begin

   select cst.id
     into vn_codst_id
     from Cod_ST          cst
    where cst.cod_st      = ev_cod_st
      and cst.tipoimp_id  = en_tipoimp_id;

   return vn_codst_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Cod_ST_id:' || sqlerrm);
end fkg_Cod_ST_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela Aj_Obrig_Rec

function fkg_Aj_Obrig_Rec_id ( ev_cd          in Aj_Obrig_Rec.cd%TYPE
                             , en_tipoimp_id  in Aj_Obrig_Rec.id%TYPE )
         return Aj_Obrig_Rec.id%TYPE
is

   vn_ajobrigrec_id  Aj_Obrig_Rec.id%TYPE;

begin

   select id
     into vn_ajobrigrec_id
     from Aj_Obrig_Rec
    where cd          = ev_cd
      and tipoimp_id  = en_tipoimp_id;

   return vn_ajobrigrec_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Aj_Obrig_Rec_id:' || sqlerrm);
end fkg_Aj_Obrig_Rec_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela Genero

function fkg_Genero_id ( ev_cod_gen  in Genero.cod_gen%TYPE )
         return Genero.id%TYPE
is

   vn_genero_id  Genero.id%TYPE;

begin

   select id
     into vn_genero_id
     from Genero
    where cod_gen = ev_cod_gen;

   return vn_genero_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Genero_id:' || sqlerrm);
end fkg_Genero_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Ncm

function fkg_Ncm_id ( ev_cod_ncm  in Ncm.cod_ncm%TYPE )
         return Ncm.id%TYPE
is

   vn_ncm_id  Ncm.id%TYPE;

begin

   select id
     into vn_ncm_id
     from Ncm
    where cod_ncm = ev_cod_ncm;

   return vn_ncm_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Ncm_id(' || ev_cod_ncm || '):' || sqlerrm);
end fkg_Ncm_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela EX_TIPI

function fkg_ex_tipi_id ( ev_cod_ex_tipi  in EX_TIPI.cod_ex_tipi%TYPE
                        , en_ncm_id       in Ncm.id%TYPE )
         return EX_TIPI.id%TYPE
is

   vn_extipi_id EX_TIPI.id%TYPE := null;

begin

   select id
     into vn_extipi_id
     from EX_TIPI
    where ncm_id       = en_ncm_id
      and cod_ex_tipi  = ev_cod_ex_tipi;

   return vn_extipi_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_ex_tipi_id:' || sqlerrm);
end fkg_ex_tipi_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Código da tabela EX_TIPI

function fkg_ex_tipi_cod ( en_extipi_id  in ex_tipi.id%type )
         return ex_tipi.cod_ex_tipi%type
is

   vv_cod_ex_tipi ex_tipi.cod_ex_tipi%type := null;

begin

   select cod_ex_tipi
     into vv_cod_ex_tipi
     from ex_tipi
    where id = en_extipi_id;

   return vv_cod_ex_tipi;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_ex_tipi_cod:' || sqlerrm);
end fkg_ex_tipi_cod;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela Pais

function fkg_Pais_siscomex_id ( ev_cod_siscomex  in Pais.cod_siscomex%TYPE )
         return Pais.id%TYPE
is

   vn_pais_id  Pais.id%TYPE;

begin

   select id
     into vn_pais_id
     from Pais
    where cod_siscomex = ev_cod_siscomex;

   return vn_pais_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Pais_siscomex_id:' || sqlerrm);
end fkg_Pais_siscomex_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela Pais conforme sigla do pais

function fkg_Pais_sigla_id ( ev_sigla_pais  in Pais.sigla_pais%TYPE )
         return Pais.id%TYPE
is

   vn_pais_id  Pais.id%TYPE;

begin

   select id
     into vn_pais_id
     from Pais
    where sigla_pais = ev_sigla_pais;

   return vn_pais_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Pais_sigla_id:' || sqlerrm);
end fkg_Pais_sigla_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela Estado

function fkg_Estado_ibge_id ( ev_ibge_estado  in Estado.ibge_estado%TYPE )
         return Estado.id%TYPE
is

   vn_estado_id  Estado.id%TYPE;

begin

   select id
     into vn_estado_id
     from Estado
    where ibge_estado = ev_ibge_estado;

   return vn_estado_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Estado_ibge_id:' || sqlerrm);
end fkg_Estado_ibge_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela Cidade

function fkg_Cidade_ibge_id ( ev_ibge_cidade  in Cidade.ibge_cidade%TYPE )
         return Cidade.id%TYPE
is

   vn_cidade_id  Cidade.id%TYPE;

begin

   select id
     into vn_cidade_id
     from Cidade
    where ibge_cidade = ev_ibge_cidade;

   return vn_cidade_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Cidade_ibge_id:' || sqlerrm);
end fkg_Cidade_ibge_id;
--
-- ========================================================================================================= --
--| Função retorna o ID da tabela Pessoa, conforme MultOrg_ID e CPF/CNPJ
--
function fkg_Pessoa_id_cpf_cnpj ( en_multorg_id  in mult_org.id%type
                                , en_cpf_cnpj    in varchar2
                                ) return Pessoa.id%TYPE is
   --
   vn_pessoa_id  Pessoa.id%TYPE := null;
   --
begin
   --
   -- NÃO ALTERE A REGRA DESSAS ROTINAS SEM CONVERSAR COM EQUIPE
   --
   if rtrim(ltrim(en_cpf_cnpj)) is not null then
      --
      begin
         select max(p.id)
	   into vn_pessoa_id
           from Pessoa    p
              , Juridica  j
          where p.multorg_id = en_multorg_id
            and j.pessoa_id  = p.id
            and j.num_cnpj   = to_number( substr(en_cpf_cnpj, 1, 8) )
            and j.num_filial = to_number( substr(en_cpf_cnpj, 9, 4) )
            and j.dig_cnpj   = to_number( substr(en_cpf_cnpj, 13, 2) );
      exception
         when others then
            vn_pessoa_id := null;
     end;
     --
     if nvl(vn_pessoa_id,0) <= 0 then
        --
        begin
           select max(p.id)
             into vn_pessoa_id
             from Pessoa    p
                , Fisica    f
            where p.multorg_id = en_multorg_id
              and f.pessoa_id  = p.id
              and f.num_cpf    = to_number( substr(en_cpf_cnpj, 1, 9) )
              and f.dig_cpf    = to_number( substr(en_cpf_cnpj, 10, 2) );
        exception
           when others then
              vn_pessoa_id := null;
        end;
        --
      end if;
      --
   end if;
   --
   return vn_pessoa_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Pessoa_id_cpf_cnpj:' || sqlerrm);
end fkg_Pessoa_id_cpf_cnpj;
--
-- ========================================================================================================= --
--| Função retorna o ID da tabela Empresa

function fkg_Empresa_id ( en_multorg_id  in mult_org.id%type
                        , ev_cod_matriz  in Empresa.cod_matriz%TYPE
                        , ev_cod_filial  in Empresa.cod_filial%TYPE
                        )
         return Empresa.id%TYPE
is

   vn_empresa_id  Empresa.id%TYPE;

begin

   select id
     into vn_empresa_id
     from Empresa
    where multorg_id  = en_multorg_id
      and cod_matriz  = ev_cod_matriz
      and cod_filial  = ev_cod_filial;

   return vn_empresa_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Empresa_id:' || sqlerrm);
end fkg_Empresa_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna "true" se a NF existe e "false" se não existe

function fkg_existe_nf ( en_nota_fiscal  in Nota_Fiscal.id%TYPE )
         return boolean
is

   vn_lixo  number;

begin

   select 1
     into vn_lixo
     from Nota_Fiscal
    where id = en_nota_fiscal;

   return true;

exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_nf: ' || sqlerrm);
end fkg_existe_nf;

-------------------------------------------------------------------------------------------------------

--| Função retorna "true" se a UF for válida, e "false" se não for.
function fkg_uf_valida ( ev_sigla_estado  in Estado.Sigla_Estado%TYPE )
         return boolean
is

   vn_dummy number := 0;

begin

   if ev_sigla_estado is not null then

      if ev_sigla_estado = 'EX' then
         --
         vn_dummy := 1;
         --
      else
         --
         select 1
           into vn_dummy
           from Estado   e
              , Pais     p
          where e.sigla_estado  = ev_sigla_estado
            and p.id            = e.pais_id
            and p.sigla_pais    = 'BR';
         --
      end if;

   end if;

   if nvl(vn_dummy,0) > 0 then
      return true;
   else
      return false;
   end if;

exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_uf_valida: ' || sqlerrm);
end fkg_uf_valida;

-------------------------------------------------------------------------------------------------------

--| Função retorna "true" se o IBGE do UF for válide e "false" se não for

function fkg_ibge_uf_valida ( ev_ibge_estado  in Estado.ibge_estado%TYPE )
         return boolean
is

   vn_dummy number := 0;

begin

   if ev_ibge_estado is not null then

      select 1
        into vn_dummy
        from Estado   e
           , Pais     p
       where e.ibge_estado   = ev_ibge_estado
         and p.id            = e.pais_id
         and p.sigla_pais    = 'BR';

   end if;

   if nvl(vn_dummy,0) > 0 then
      return true;
   else
      return false;
   end if;

exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_ibge_uf_valida: ' || sqlerrm);
end fkg_ibge_uf_valida;

-------------------------------------------------------------------------------------------------------

--| Função retorna "True" se o IBGE da cidade for válido e "false" se não for

function fkg_ibge_cidade ( ev_ibge_cidade  in Cidade.ibge_cidade%TYPE )
         return boolean
is

   vn_dummy number := 0;

begin

   if ev_ibge_cidade is not null then

      select 1
        into vn_dummy
        from Cidade
       where ibge_cidade = ev_ibge_cidade;

   end if;

   if nvl(vn_dummy,0) > 0 then
      return true;
   else
      return false;
   end if;

exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_ibge_cidade: ' || sqlerrm);
end fkg_ibge_cidade;

-------------------------------------------------------------------------------------------------------

--| Função retorna "true" se o código do pais for válido e "false" se não for

function fkg_codpais_siscomex_valido ( en_cod_siscomex  in Pais.cod_siscomex%TYPE )
         return boolean
is

   vn_dummy number := 0;

begin

   if nvl(en_cod_siscomex,0) > 0 then

      select 1
        into vn_dummy
        from Pais p
       where cod_siscomex = en_cod_siscomex;

   end if;

   if nvl(vn_dummy,0) > 0 then
      return true;
   else
      return false;
   end if;

exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_codpais_siscomex_valido: ' || sqlerrm);
end fkg_codpais_siscomex_valido;

-------------------------------------------------------------------------------------------------------

-- Função retorna a descrição do valor do domino

function fkg_dominio ( ev_dominio   in Dominio.dominio%TYPE
                     , ev_vl        in Dominio.vl%TYPE )
         return Dominio.descr%TYPE
is

  vv_descr Dominio.descr%TYPE;

begin

   select d.descr
     into vv_descr
     from dominio d
    where dominio  = upper(ev_dominio)
      and vl       = upper(ev_vl);

   return vv_descr;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_dominio: ' || sqlerrm);
end fkg_dominio;

-------------------------------------------------------------------------------------------------------

-- Função retorna "true" se o ID da empresa for válido e "false" se não for

function fkg_empresa_id_valido ( en_empresa_id  in Empresa.id%TYPE )
         return boolean
is

   vn_dummy number := 0;

begin

   if nvl(en_empresa_id,0) > 0 then

      select 1
        into vn_dummy
        from Empresa
       where id = en_empresa_id;

   end if;
   if nvl(vn_dummy,0) > 0 then
      return true;
   else
      return false;
   end if;

exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_id_valido: ' || sqlerrm);
end fkg_empresa_id_valido;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela Pessoa

function fkg_Pessoa_id_valido ( en_pessoa_id  in Pessoa.id%TYPE )
         return boolean
is

   vn_dummy number := 0;

begin

   if nvl(en_pessoa_id,0) > 0 then

      select 1
        into vn_dummy
        from Pessoa
       where id = en_pessoa_id;

   end if;

   if nvl(vn_dummy,0) > 0 then
      return true;
   else
      return false;
   end if;

exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_Pessoa_id_valido:' || sqlerrm);
end fkg_Pessoa_id_valido;

-------------------------------------------------------------------------------------------------------

-- Função retorna a pessoa pelo MultOrg_ID e cod_part

function fkg_pessoa_id_cod_part ( en_multorg_id  in mult_org.id%type
                                , ev_cod_part    in Pessoa.cod_part%TYPE
                                )
         return Pessoa.id%TYPE
is

   vn_pessoa_id Pessoa.id%TYPE := null;

begin

   if trim(ev_cod_part) is not null then

      select p.id
        into vn_pessoa_id
        from Pessoa  p
       where p.multorg_id  = en_multorg_id
         and p.cod_part    = ev_cod_part;

   end if;

   return vn_pessoa_id;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_pessoa_id_cod_part: ' || sqlerrm);
end fkg_pessoa_id_cod_part;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da NAT_OPER pelo cod_nat

function fkg_natoper_id_cod_nat ( en_multorg_id in mult_org.id%type
                                , ev_cod_nat    in Nat_Oper.cod_nat%TYPE )
         return Nat_Oper.id%TYPE
is

  vn_natoper_id  Nat_Oper.id%TYPE;

begin

   if ev_cod_nat is not null then

      select nop.id
        into vn_natoper_id
        from Nat_Oper  nop
       where nop.cod_nat = trim(ev_cod_nat)
         and multorg_id = en_multorg_id;

   end if;

   return vn_natoper_id;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_natoper_id_cod_nat: ' || sqlerrm);
end fkg_natoper_id_cod_nat;

-------------------------------------------------------------------------------------------------------

--| Função retorna o nome da empresa

function fkg_nome_empresa ( en_empresa_id  in Empresa.id%TYPE
                          )
         return Pessoa.nome%TYPE
is

   vv_nome  Pessoa.nome%TYPE := null;

begin

   if nvl(en_empresa_id,0) > 0
      then
      --
      select p.nome
        into vv_nome
        from Empresa  e
           , Pessoa   p
       where e.id          = en_empresa_id
         and p.id          = e.pessoa_id;
      --
   end if;

   return vv_nome;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_nome_empresa: ' || sqlerrm);
end fkg_nome_empresa;

-------------------------------------------------------------------------------------------------------

--| Função retorna a data de emissão da nota fiscal

function fkg_dt_emiss_nf ( en_notafiscal_id in Nota_Fiscal.id%TYPE )
         return Nota_Fiscal.dt_emiss%TYPE
is

  vd_dt_emiss  Nota_Fiscal.dt_emiss%TYPE;

begin

   if nvl(en_notafiscal_id,0) > 0 then

      select nf.dt_emiss
        into vd_dt_emiss
        from Nota_Fiscal nf
       where nf.id = en_notafiscal_id;

   end if;

   return vd_dt_emiss;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_dt_emiss_nf: ' || sqlerrm);
end fkg_dt_emiss_nf;

-------------------------------------------------------------------------------------------------------

--| Função retorna "true" se o item_id é válido e "false" se não é

function fkg_item_id_valido ( en_item_id  in Item.id%TYPE )
         return boolean
is

   vn_dummy number := 0;

begin

   if nvl(en_item_id,0) > 0 then

      select 1
        into vn_dummy
        from Item
       where id = en_item_id;

   end if;

   if nvl(vn_dummy,0) > 0 then
      return true;
   else
      return false;
   end if;

exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_item_id_valido:' || sqlerrm);
end fkg_item_id_valido;

-------------------------------------------------------------------------------------------------------

-- Função retorna o DM_ST_PROC (Situação do Processo) da Nota Fiscal

function fkg_st_proc_nf ( en_notafiscal_id  in Nota_Fiscal.id%TYPE )
         return Nota_Fiscal.dm_st_proc%TYPE
is

   vn_dm_st_proc  Nota_Fiscal.dm_st_proc%TYPE := -1;

begin

   if nvl(en_notafiscal_id,0) > 0 then
      --
      select nf.dm_st_proc
        into vn_dm_st_proc
        from Nota_Fiscal nf
       where nf.id = en_notafiscal_id;
      --
   end if;

   return vn_dm_st_proc;

exception
   when no_data_found then
      return -1;
   when others then
      raise_application_error(-20101, 'Erro na fkg_st_proc_nf:' || sqlerrm);
end fkg_st_proc_nf;

-------------------------------------------------------------------------------------------------------

-- Função retorna a Chave da Nota Fiscal

function fkg_chave_nf ( en_notafiscal_id   in      Nota_Fiscal.id%TYPE )
         return Nota_Fiscal.nro_chave_nfe%TYPE
is

  vv_nro_chave_nfe Nota_Fiscal.nro_chave_nfe%TYPE := null;

begin

   if nvl(en_notafiscal_id,0) > 0 then
      --
      select nro_chave_nfe
        into vv_nro_chave_nfe
        from Nota_Fiscal
       where id = en_notafiscal_id;
      --
   end if;

   return vv_nro_chave_nfe;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_chave_nf:' || sqlerrm);
end fkg_chave_nf;

-------------------------------------------------------------------------------------------------------

-- Função retorna um número positivo aleatório na faixa de 1 a 999999999

function fkg_numero_aleatorio ( en_num in number
                              , en_ini in number
                              , en_fim in number )
         return number
is

   vn_valor number   := 0;
   vn_number number  := 0;

begin

   vn_number := nvl(en_num,0);

   dbms_random.initialize (vn_number);

   loop
      --
      vn_valor := abs(dbms_random.random);
      --
      if vn_valor between nvl(en_ini,0) and nvl(en_fim,0) then
         --
         dbms_random.terminate;
         exit;
         --
      end if;
      --
   end loop;

   return vn_valor;

--exception
--   when others then
--      raise_application_error(-20101, 'Erro na fkg_numero_aleatorio:' || sqlerrm);
end fkg_numero_aleatorio;

-------------------------------------------------------------------------------------------------------

-- Cálculo do dígito verificador com modulo 11

function fkg_mod_11 ( ev_codigo in varchar2 )
         return number
is
   --
   vn_fase         number := 0;
   vn_compr_digito number;
   vn_soma_cod_dig number;
   vn_j            number;
   vn_resto_dig    number;
   vn_dig          number(2);
   --
begin
   --
   vn_fase := 1;
   --
   vn_compr_digito := length(ev_codigo);
   vn_soma_cod_dig := 0;
   vn_j            := 2;
   --
   vn_fase := 2;
   --
   for i in 1 .. vn_compr_digito loop
      --
      vn_fase := 3;
      --
      vn_soma_cod_dig := vn_soma_cod_dig + (to_number(substr(ev_codigo,(vn_compr_digito - (i - 1)),1)) *  vn_j);
      --
      vn_fase := 3.1;
      --
      if ( vn_j mod 9) = 0 then
         vn_j := 2;
      else
         vn_j := vn_j + 1;
      end if;
      --
   end loop;
   --
   vn_fase := 4;
   --
   vn_resto_dig := (vn_soma_cod_dig mod 11);
   vn_dig       := 11 - vn_resto_dig;
   --
   vn_fase := 5;
   --
   if vn_resto_dig in (0,1) then
      vn_dig := 0;
   end if;

   return (vn_dig);

--exception
  -- when others then
      --raise_application_error(-20101, 'Erro na fkg_mod_11 (' || vn_fase || '-' || ev_codigo || '):' || sqlerrm);
end fkg_mod_11;

-------------------------------------------------------------------------------------------------------

-- Função retorna o tipo de ambiente (Produção/Homologação) parametrizado para a empresa

function fkg_tp_amb_empresa ( en_empresa_id  in Empresa.id%TYPE )
         return Empresa.dm_tp_amb%TYPE
is

   vn_dm_tp_amb Empresa.dm_tp_amb%TYPE := null;

begin

   if nvl(en_empresa_id,0) > 0 then
      --
      select e.dm_tp_amb
        into vn_dm_tp_amb
        from Empresa  e
       where e.id = en_empresa_id;
      --
   end if;

   return vn_dm_tp_amb;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_tp_amb_empresa:' || sqlerrm);
end fkg_tp_amb_empresa;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Tipo de impressão (Retrato/Paisagem) parametrizado na empresa

function fkg_tp_impr_empresa ( en_empresa_id  in Empresa.id%TYPE )
         return Empresa.dm_tp_impr%TYPE
is

   vn_dm_tp_impr Empresa.dm_tp_impr%TYPE := null;

begin

   if nvl(en_empresa_id,0) > 0 then
      --
      select e.dm_tp_impr
        into vn_dm_tp_impr
        from Empresa  e
       where e.id = en_empresa_id;
      --
   end if;

   return vn_dm_tp_impr;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_tp_impr_empresa:' || sqlerrm);
end fkg_tp_impr_empresa;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Tipo de impressão (Retrato/Paisagem) parametrizado na empresa

function fkg_forma_emiss_empresa ( en_empresa_id  in Empresa.id%TYPE )
         return Empresa.dm_forma_emiss%TYPE
is

   vn_dm_forma_emiss Empresa.dm_forma_emiss%TYPE := null;

begin

   if nvl(en_empresa_id,0) > 0 then
      --
      select e.dm_forma_emiss
        into vn_dm_forma_emiss
        from Empresa  e
       where e.id = en_empresa_id;
      --
   end if;

   return vn_dm_forma_emiss;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_forma_emiss_empresa:' || sqlerrm);
end fkg_forma_emiss_empresa;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da nota Fiscal a partir do número da chave de acesso

function fkg_notafiscal_id_pela_chave ( en_nro_chave_nfe  in Nota_Fiscal.nro_chave_nfe%TYPE )
         return Nota_Fiscal.id%TYPE
is

   vn_notafiscal_id  Nota_Fiscal.id%TYPE := null;

begin

   if en_nro_chave_nfe is not null then
      --
      select max(nf.id)
        into vn_notafiscal_id
        from Nota_Fiscal  nf
       where nf.nro_chave_nfe = en_nro_chave_nfe;
      --
   end if;

   return vn_notafiscal_id;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_notafiscal_id_pela_chave:' || sqlerrm);
end fkg_notafiscal_id_pela_chave;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do Lote conforme o número do recibo de envio fornecido pelo SEFAZ

function fkg_Lote_id_pelo_nro_recibo ( en_nro_recibo in Lote.nro_recibo%TYPE )
         return Lote.id%TYPE
is

   vn_lote_id Lote.id%TYPE := null;

begin

   select id
     into vn_lote_id
     from Lote
    where nro_recibo = en_nro_recibo;

   return vn_lote_id;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_Lote_id_pelo_nro_recibo:' || sqlerrm);
end fkg_Lote_id_pelo_nro_recibo;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do Cfop

function fkg_cfop_id ( en_cd  in Cfop.cd%TYPE )
         return Cfop.id%TYPE
is

   vn_cfop_id Cfop.id%TYPE := null;

begin

   select id
     into vn_cfop_id
     from Cfop
    where cd = en_cd;

   return vn_cfop_id;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cfop_id:' || sqlerrm);
end fkg_cfop_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna a inscrição estadual da empresa

function fkg_inscr_est_empresa ( en_empresa_id  in Empresa.id%TYPE )
         return Juridica.ie%TYPE
is

   vv_ie  Juridica.ie%TYPE := null;

begin

   if nvl(en_empresa_id,0) > 0 then
      --
      select j.ie
        into vv_ie
        from Empresa   e
           , Juridica  j
       where e.id         = en_empresa_id
         and j.pessoa_id  = e.pessoa_id;
      --
   end if;

   return vv_ie;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_inscr_est_empresa:' || sqlerrm);
end fkg_inscr_est_empresa;

-------------------------------------------------------------------------------------------------------

--| Função retorna "1" se a nota fiscal está inutilizada e "0" se não está

function fkg_nf_inutiliza ( en_empresa_id  in Empresa.id%TYPE
                          , ev_cod_mod     in Mod_Fiscal.cod_mod%TYPE
                          , en_serie       in Nota_Fiscal.serie%TYPE
                          , en_nro_nf      in Nota_Fiscal.nro_nf%TYPE
                          )
         return number is

   vn_retorno number := 0;

begin

   select distinct 1
     into vn_retorno
     from Inutiliza_Nota_Fiscal  inf
        , Mod_Fiscal             mf
    where inf.empresa_id = en_empresa_id
      and inf.serie      = en_serie
      and en_nro_nf between inf.nro_ini and inf.nro_fim
      and inf.dm_situacao = 2 -- Concluído
      and mf.id          = inf.modfiscal_id
      and mf.cod_mod     = ev_cod_mod;

   return vn_retorno;

exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_nf_inutiliza:' || sqlerrm);
end fkg_nf_inutiliza;

-------------------------------------------------------------------------------------------------------

-- Função retorna se 1 se o Estado Obrigado o CODIF e 0 se não Obriga

function fkg_Estado_Obrig_Codif ( ev_sigla_estado  in Estado.sigla_estado%TYPE )
         return Estado.dm_obrig_codif%TYPE
is

   vn_dm_obrig_codif  Estado.dm_obrig_codif%TYPE := null;

begin

   select dm_obrig_codif
     into vn_dm_obrig_codif
     from Estado
    where sigla_estado = ev_sigla_estado;

   return vn_dm_obrig_codif;

exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_Estado_Obrig_Codif:' || sqlerrm);
end fkg_Estado_Obrig_Codif;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do estado conforme a sigla de UF

function fkg_Estado_id ( ev_sigla_estado  in Estado.sigla_estado%TYPE )
         return Estado.id%TYPE
is

   vn_estado_id  Estado.id%TYPE := null;

begin

   select id
     into vn_estado_id
     from Estado
    where sigla_estado = upper(ev_sigla_estado);

   return vn_estado_id;

exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_Estado_id:' || sqlerrm);
end fkg_Estado_id;

-------------------------------------------------------------------------------------------------------
FUNCTION fkg_converte ( ev_string            IN varchar2
                      , en_espacamento       IN number DEFAULT 0
                      , en_remove_spc_extra  IN number DEFAULT 1
                      , en_ret_carac_espec   IN number DEFAULT 1 -- 1-padrão,  2-NF-e, 3-(º > < " Ø µ &), 4-Mantem & (E comercial)
                      , en_ret_tecla         in number default 1 -- retira comandos CHR
                      , en_ret_underline     in number default 1 -- retira underline: 1 - sim, 0 - não
                      , en_ret_chr10         in number default 1 -- retira comandos CHR10 se a string original não vier com o caractere "\n"
                      )
         RETURN VARCHAR2 IS

      vv_valor2      varchar2(32767);
      vv_valor3      varchar2(32767);
      vi             number;
      vb_carac_espec boolean;

      -- Para implementação futura segue a lista de caracteres ascii válidos
      --  0 a 9 = chr(48) a chr(57)
      --  A a Z = chr(65) a chr(90)
      --  a a z = chr(97) a chr(122)

BEGIN
    --
    vi := 0;
    vb_carac_espec := false;
    --
    -- Remove os caracteres especiais.
    /*IF nvl(en_ret_carac_espec, 0) = 1 THEN
       --vv_valor2 := nvl(ltrim(rtrim(translate(ev_string, 'ÇçåÅâÂãÃáÁàÀäÄêÊéÉèÈëËîÎíÍìÌïÏôÔÕõóÓòÒöÖûÛúÚùÙüÜÿŸýÝñÑÐ\ˆ“&¤¶¦æÆø×ƒØ¿®±¾½¼«»ðßµþÞ¯÷œ¸·!¨*+=_{}[];|<>?ªº°§¹²³™š£¢¬´`~^¿¢€¥‰†‡„‹›¦ ¡•§·º…–—''’'
       vv_valor2 := nvl(ltrim(rtrim(translate(ev_string, 'ÇçåÅâÂãÃáÁàÀäÄêÊéÉèÈëËîÎíÍìÌïÏôÔÕõóÓòÒöÖûÛúÚùÙüÜÿŸýÝñÑÐ\ˆ“&¤¶¦æÆø×ƒØ¿®±¾½¼«»ðßµþÞ¯÷œ¸·!¨*_{}[];|<>?ªº°§¹²³™š£¢¬´`~^¿¢€¥‰†‡„‹›¦ ¡•§·º…–—''’'
                                                       , 'CcaAaAaAaAaAaAeEeEeEeEiIiIiIiIoOOooOoOoOuUuUuUuUyYyYnND '))), ' ');
    ELSE
       vv_valor2 := nvl(ev_string, ' ');
    END IF;*/
    --
    IF nvl(en_ret_carac_espec, 0) = 1 THEN
       --vv_valor2 := nvl(ltrim(rtrim(translate(ev_string, 'ÇçåÅâÂãÃáÁàÀäÄêÊéÉèÈëËîÎíÍìÌïÏôÔÕõóÓòÒöÖûÛúÚùÙüÜÿŸýÝñÑÐ\ˆ“&¤¶¦æÆø×ƒØ¿®±¾½¼«»ðßµþÞ¯÷œ¸·!¨*+=_{}[];|<>?ªº°§¹²³™š£¢¬´`~^¿¢€¥‰†‡„‹›¦ ¡•§·º…–—''’'
       --vv_valor2 := nvl(ltrim(rtrim(translate(ev_string, 'ÇçåÅâÂãÃáÁàÀäÄêÊéÉèÈëËîÎíÍìÌïÏôÔÕõóÓòÒöÖûÛúÚùÙüÜÿŸýÝñÑÐ\ˆ“&¤¶¦æÆø×ƒØ¿®±¾½¼«»ðßµþÞ¯÷œ¸·!¨*_{}[];|<>?ªº°§¹²³™š£¢¬´`~^¿¢€¥‰†‡„‹›¦ ¡•§·º…–—''’'
       vv_valor2 := nvl(ev_string, ' ');
       -- Converte o caractere especial \n "New line" por chr(10) "Enter"
       if instr(vv_valor2, '\n') > 0 then
          vb_carac_espec := true;
          vv_valor2      := replace(vv_valor2, '\n', chr(10));
       end if;
       --
       vv_valor2 := nvl(ltrim(rtrim(translate(vv_valor2, 'ÇçåÅâÂãÃáÁàÀäÄêÊéÉèÈëËîÎíÍìÌïÏôÔÕõóÓòÒöÖûÛúÚùÙüÜÿŸýÝñÑÐ\ˆ“&¤¶¦æÆø×ƒØ¿®±¾½¼«»ðßµþÞ¯÷œ¸·!¨*{}[];|<>?ªº°§¹²³™š£¢¬´`~^¿¢€¥‰†‡„‹›¦ ¡•§·º…–—''’'
                                                       , 'CcaAaAaAaAaAaAeEeEeEeEiIiIiIiIoOOooOoOoOuUuUuUuUyYyYnND '))), ' ');
       --
    ELSIF nvl(en_ret_carac_espec, 0) = 2 THEN -- NF-e
       vv_valor2 := nvl(ev_string, ' ');
       -- Converte o caractere especial \n "New line" por chr(10) "Enter"	
       if instr(vv_valor2, '\n') > 0 then
          vb_carac_espec := true;
          vv_valor2      := replace(vv_valor2, '\n', chr(10));
       end if;
       --
        vv_valor2 := nvl(ltrim(rtrim(translate(vv_valor2, 'º“&<>´`’„"''’' , ' '))), ' ');
       --
     ELSIF nvl(en_ret_carac_espec, 0) = 3 THEN -- 
       --vv_valor2 := nvl(ltrim(rtrim(translate(ev_string, 'ÇçåÅâÂãÃáÁàÀäÄêÊéÉèÈëËîÎíÍìÌïÏôÔÕõóÓòÒöÖûÛúÚùÙüÜÿŸýÝñÑÐ\ˆ“&¤¶¦æÆø×ƒØ¿®±¾½¼«»ðßµþÞ¯÷œ¸·!¨*+=_{}[];|<>?ªº°§¹²³™š£¢¬´`~^¿¢€¥‰†‡„‹›¦ ¡•§·º…–—''’'
       --vv_valor2 := nvl(ltrim(rtrim(translate(ev_string, 'ÇçåÅâÂãÃáÁàÀäÄêÊéÉèÈëËîÎíÍìÌïÏôÔÕõóÓòÒöÖûÛúÚùÙüÜÿŸýÝñÑÐ\ˆ“&¤¶¦æÆø×ƒØ¿®±¾½¼«»ðßµþÞ¯÷œ¸·!¨*_{}[];|<>?ªº°§¹²³™š£¢¬´`~^¿¢€¥‰†‡„‹›¦ ¡•§·º…–—''’'
       vv_valor2 := nvl(ev_string, ' ');
       -- Converte o caractere especial \n "New line" por chr(10) "Enter"
       if instr(vv_valor2, '\n') > 0 then
          vb_carac_espec := true;
          vv_valor2      := replace(vv_valor2, '\n', chr(10));
       end if;
       --
       vv_valor2 := nvl(ltrim(rtrim(translate(vv_valor2, 'ÇçåÅâÂãÃáÁàÀäÄêÊéÉèÈëËîÎíÍìÌïÏôÔÕõóÓòÒöÖûÛúÚùÙüÜÿŸýÝñÑÐ\ˆ“¤¶¦æÆ×ƒ¿®±¾½¼«»ðßþÞ¯÷œ¸·!¨*{}[];|?ª§¹²³™š£¢¬´`~^¿¢€¥‰†‡„‹›¦ ¡•§·…–—''’'
                                                       , 'CcaAaAaAaAaAaAeEeEeEeEiIiIiIiIoOOooOoOoOuUuUuUuUyYyYnND '))), ' ');
       --
    ELSIF nvl(en_ret_carac_espec, 0) = 4 THEN -- Mantem & (E comercial)
       vv_valor2 := nvl(ev_string, ' ');
       -- Converte o caractere especial \n "New line" por chr(10) "Enter"
       if instr(vv_valor2, '\n') > 0 then
          vb_carac_espec := true;
          vv_valor2      := replace(vv_valor2, '\n', chr(10));
       end if;
       --
       vv_valor2 := nvl(ltrim(rtrim(translate(vv_valor2, 'ÇçåÅâÂãÃáÁàÀäÄêÊéÉèÈëËîÎíÍìÌïÏôÔÕõóÓòÒöÖûÛúÚùÙüÜÿŸýÝñÑÐ\ˆ“¤¶¦æÆø×ƒØ¿®±¾½¼«»ðßµþÞ¯÷œ¸·!¨*{}[];|<>?ªº°§¹²³™š£¢¬´`~^¿¢€¥‰†‡„‹›¦ ¡•§·º…–—''’'
                                                       , 'CcaAaAaAaAaAaAeEeEeEeEiIiIiIiIoOOooOoOoOuUuUuUuUyYyYnND '))), ' ');
       --
	ELSE
       vv_valor2 := nvl(ev_string, ' ');
    END IF;
    --
    if nvl(en_ret_underline, 0) = 1 then
       --
       vv_valor2 := replace(vv_valor2, '_', '');
       --
    end if;
    --
    vv_valor2 := REPLACE( vv_valor2, chr(183), '');
    --vv_valor2 := REPLACE( vv_valor2, chr(36), '');
    --
    --| limpa caracteres de 0 ate 31
    for vi in 0 .. 31 loop
       --
       if nvl(vi,0) <> 10 then
          vv_valor2 := REPLACE( vv_valor2, chr(vi), '');
       end if;
       --
    end loop;
    --
    -- Não permite que haja mais de um espaço entre as palavras
    IF nvl(en_remove_spc_extra, 0) = 1 THEN
       WHILE instr(vv_valor2, '  ') > 0 LOOP
          vv_valor2 := REPLACE(vv_valor2, '  ', ' ');
       END LOOP;
       -- Retirar o chr(10) se a string original não vier com o caractere "\n"
       if vb_carac_espec = false and en_ret_chr10 = 1 then 
          vv_valor2 := REPLACE( vv_valor2, chr(10), '');
       end if; 
       --
    END IF;
    --
    vv_valor3 := NULL;
    --
    vi := 0;
    --
    IF nvl(en_espacamento, 0) > 0 THEN
       FOR vi IN 1 .. length(vv_valor2) LOOP
          vv_valor3 := vv_valor3 || substr(vv_valor2, vi, 1) || lpad(' ', en_espacamento, ' ');
       END LOOP;
    ELSE
       vv_valor3 := vv_valor2;
    END IF;
    --
    if nvl(en_ret_tecla,0) = 1 then
       -- retira o CHR(10) do inicio do texto
       while ascii(substr(vv_valor3,1,1)) = 10 loop
          --
	  vv_valor3 := substr(vv_valor3,2,length(vv_valor3));
	  --
       end loop;
       --
       -- retira o CHR(10) do final do texto
       while ascii(substr(vv_valor3,length(vv_valor3),1)) = 10 loop
          --
	  vv_valor3 := substr(vv_valor3,1,length(vv_valor3) - 1);
	  --
       end loop;
       --
       vv_valor3 := REPLACE( vv_valor3, chr(9), '');
       vv_valor3 := REPLACE( vv_valor3, chr(27), '');
       vv_valor3 := REPLACE( vv_valor3, chr(13), '');
       vv_valor3 := REPLACE( vv_valor3, chr(31), '');
       --
    end if;
    --
    -- Limpa caracteres Unicode
    if nvl(en_ret_carac_espec, 0) not in (2,3,4) then	
       vv_valor3 := ASCIISTR(vv_valor3);
       vv_valor3 := REPLACE( vv_valor3, '\0081', '');
       vv_valor3 := REPLACE( vv_valor3, '\00AD', '');
       vv_valor3 := REPLACE( vv_valor3, '\00BF', '');
       vv_valor3 := REPLACE( vv_valor3, '\00A9', '');
    end if;
    --
    --vv_valor3 := REPLACE( ASCIISTR(vv_valor3), '\0090', '');
    --
    RETURN trim(vv_valor3);
    --
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE <> -20001 THEN
         raise_application_error(-20001, 'Erro na fkg_converte : ' || SQLERRM);
      END IF;
      RAISE;

END fkg_converte;

-------------------------------------------------------------------------------------------------------

-- Função retorna uma String com as informações de Duplicatas

function fkg_String_dupl ( en_notafiscal_id  in Nota_Fiscal.id%TYPE
                         , en_monta_nro_fat  in number default 0 )
         return varchar2
is
   --
   -- Em 26/07/2018 - Redmine #45214 - Incluído novo parâmetro de entrada EN_MONTA_NRO_FAT: 0-Não monta o Nro da Fatura, 1-Sim, monta o Nro da Fatura.
   -- Rotinas que utilizam essa função: pb_gera_danfe_nfe e pk_emiss_nfse.
   --
   vv_string varchar2(4000) := null;
   vv_montou varchar2(1) := 'N';
   vv_param_value  varchar2(1) := '0';
   vn_multorg_id   mult_org.id%type;
   vn_empresa_id   empresa.id%type;
   vv_erro         varchar2(4000);
   MODULO_SISTEMA  constant number := fkg_ret_id_modulo_sistema('EMISSAO_DOC');
   GRUPO_SISTEMA   constant number := fkg_ret_id_grupo_sistema(MODULO_SISTEMA, 'DANFE');
   --
   cursor c_dup is
   select cob.nro_fat
        , cob.descr_tit
        , case when nvl(cob.descr_tit,'0') = '0' then '0' else '1' end existe_descr_tit
        , dup.nro_parc
        , dup.dt_vencto
        , dup.vl_dup
     from Nota_Fiscal_Cobr   cob
        , nfcobr_dup         dup
    where cob.notafiscal_id  = en_notafiscal_id
      and dup.nfcobr_id      = cob.id
    order by dup.dt_vencto;
   --
Begin
   --
   if nvl(en_notafiscal_id,0) > 0 then
      --
      -- Recupera empresa_id e multorg_id
      vn_empresa_id := fkg_empresa_notafiscal(en_notafiscal_id);
      vn_multorg_id := fkg_multorg_id_empresa(vn_empresa_id);
      --
      -- Busca o Parametro para checar se 
      if not fkg_ret_vl_param_geral_sistema (en_multorg_id => vn_multorg_id,
                                             en_empresa_id => vn_empresa_id,
                                             en_modulo_id  => MODULO_SISTEMA,
                                             en_grupo_id   => GRUPO_SISTEMA,
                                             ev_param_name => 'EXIBE_DESCR_TIT_DANFE',
                                             sv_vlr_param  => vv_param_value,
                                             sv_erro       => vv_erro) then
         --
         vv_param_value := '0';
         --
      end if;
      --
      --
      vv_string := null;
      vv_montou := 'N';
      --
      for rec in c_dup loop
         --
         if nvl(en_monta_nro_fat,0) = 0 then -- 0-Não monta o Nro da Fatura
            --
            vv_string := vv_string ||
                         case when (vv_param_value = ('0')) or (vv_param_value = ('1') and rec.existe_descr_tit = 0) then 
                                 ' Fat: '||rec.nro_parc||' Venc: '||to_char(rec.dt_vencto,'dd/mm/yy')||' Vlr: '||trim(to_char(rec.vl_dup,'9G999G999G999G990D00'))
                              when vv_param_value = ('1') then case when rec.existe_descr_tit > 0 then 
                                 ' Titulo: '||rec.descr_tit else '' end
                              when vv_param_value = ('2') then 
                                 'Fat: '||rec.nro_parc||' Venc: '||to_char(rec.dt_vencto,'dd/mm/yy')||' Vlr: '||trim(to_char(rec.vl_dup,'9G999G999G999G990D00')) || case when rec.existe_descr_tit > 0 then ' Titulo: '||rec.descr_tit else '' end
                         end
                         ||case when length(trim(replace(vv_string,'|',''))) > 0 then ' | ' else '' end;
            --
         else -- nvl(en_monta_nro_fat,0) = 1 -- 1-Sim, monta o Nro da Fatura
            --
            if nvl(vv_montou,'N') = 'N' then
               --
               vv_montou := 'S';
               vv_string := 
                            case when (vv_param_value = ('0')) or (vv_param_value = ('1') and rec.existe_descr_tit = 0) then 
                                    ' Nro Fat.: '||rec.nro_fat||', Fat: '||rec.nro_parc||' Venc: '||to_char(rec.dt_vencto,'dd/mm/yy')||' Vlr: '||trim(to_char(rec.vl_dup,'9G999G999G999G990D00'))
                                 when vv_param_value = ('1') then case when rec.existe_descr_tit > 0 then 
                                    ' Titulo: '||rec.descr_tit else '' end
                                 when vv_param_value = ('2') then 
                                    'Nro Fat.: '||rec.nro_fat||', Fat: '||rec.nro_parc||' Venc: '||to_char(rec.dt_vencto,'dd/mm/yy')||' Vlr: '||trim(to_char(rec.vl_dup,'9G999G999G999G990D00')) || case when rec.existe_descr_tit > 0 then ' Titulo: '||rec.descr_tit else '' end
                            end
                            ||case when length(trim(replace(vv_string,'|',''))) > 0 then ' | ' else '' end;
               --
            else
               --
               vv_string := vv_string ||
                            case when (vv_param_value = ('0')) or (vv_param_value = ('1') and rec.existe_descr_tit = 0) then 
                                    ' Fat: '||rec.nro_parc||' Venc: '||to_char(rec.dt_vencto,'dd/mm/yy')||' Vlr: '|| trim(to_char(rec.vl_dup,'9G999G999G999G990D00'))
                                 when vv_param_value = ('1') then case when rec.existe_descr_tit > 0 then 
                                    ' Titulo: '||rec.descr_tit else '' end
                                 when vv_param_value = ('2') then 
                                    'Fat: '||rec.nro_parc||' Venc: '||to_char(rec.dt_vencto,'dd/mm/yy')||' Vlr: '|| trim(to_char(rec.vl_dup,'9G999G999G999G990D00')) || case when rec.existe_descr_tit > 0 then ' Titulo: '||rec.descr_tit else '' end
                            end
                            ||case when length(trim(replace(vv_string,'|',''))) > 0 then ' | ' else '' end;
               --
            end if;
            --
         end if;
         --
      end loop;
      --
   end if;

   return vv_string;

exception
   when others then
      raise_application_error(-20101, 'Erro na fkg_String_dupl:' || sqlerrm);
end fkg_String_dupl;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da Nota Fiscal conforme Empresa, Número, modelo, serie e tipo (entrada/saída)

function fkg_busca_notafiscal_id ( en_multorg_id       in mult_org.id%type
                                 , en_empresa_id       in empresa.id%type
                                 , ev_cod_mod          in mod_fiscal.cod_mod%type
                                 , ev_serie            in nota_fiscal.serie%type
                                 , en_nro_nf           in nota_fiscal.nro_nf%type
                                 , en_dm_ind_oper      in nota_fiscal.dm_ind_oper%type
                                 , en_dm_ind_emit      in nota_fiscal.dm_ind_emit%type
                                 , ev_cod_part         in pessoa.cod_part%type
                                 , en_dm_arm_nfe_terc  in nota_fiscal.dm_arm_nfe_terc%type default 0
                                 , ed_dt_emiss         in nota_fiscal.dt_emiss%type default null
                                 )
         return nota_fiscal.id%type
is
   --
   vn_fase             number := 0;
   vn_notafiscal_id    nota_fiscal.id%type := 0;
   vn_pessoa_id        pessoa.id%type;
   vn_modfiscal_id     mod_fiscal.id%type;
   vv_cpf_cnpj         varchar2(14);
   vn_num_cnpj_empr    juridica.num_cnpj%type;
   vn_num_filial_empr  juridica.num_filial%type;
   vn_dig_cnpj_empr    juridica.dig_cnpj%type;
   --
begin
   --
   vn_fase := 1;
   --
   vn_pessoa_id := pk_csf.fkg_pessoa_id_cod_part ( en_multorg_id  => en_multorg_id
                                                 , ev_cod_part    => trim(ev_cod_part)
                                                 );
   --
   vn_fase := 2;
   --
   vn_modfiscal_id := pk_csf.fkg_Mod_Fiscal_id ( ev_cod_mod => trim(ev_cod_mod) );
   --
   vn_fase := 3;
   --
   vv_cpf_cnpj := trim( pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => vn_pessoa_id ) );
   --
   vn_fase := 4;
   --| recupera CNPJ da empresa
   begin
      select j.num_cnpj
           , j.num_filial
           , j.dig_cnpj
        into vn_num_cnpj_empr
           , vn_num_filial_empr
           , vn_dig_cnpj_empr
        from empresa e
           , juridica j
       where e.id = en_empresa_id
         and j.pessoa_id = e.pessoa_id;
      --
   exception
      when others then
         vn_num_cnpj_empr   := 0;
         vn_num_filial_empr := 0;
         vn_dig_cnpj_empr   := 0;
   end;
   --
   vn_fase := 5;
   --
   if en_dm_ind_emit = 1 then
      --
      vn_fase := 6;
      -- 06-Nota Fiscal/Conta de Energia Elétrica
      -- 21-Nota Fiscal de Serviço de Comunicação
      -- 22-Nota Fiscal de Serviço de Telecomunicação
      -- 28-Nota Fiscal/Conta de Fornecimento de Gás Canalizado
      -- 29-Nota Fiscal/Conta de Fornecimento de Água Canalizada
      --
      if ev_cod_mod in ('06', '21', '22', '28', '29', '66') then
         --
         vn_fase := 7;
         --
         begin
            select nf.id
              into vn_notafiscal_id
              from Nota_Fiscal nf
             where nf.empresa_id     in (select e.id
                                           from juridica j
                                              , empresa e
                                          where j.num_cnpj   = vn_num_cnpj_empr
                                            and j.num_filial = vn_num_filial_empr
                                            and j.dig_cnpj   = vn_dig_cnpj_empr
                                            and e.pessoa_id  = j.pessoa_id)
               and nf.dm_ind_emit     = en_dm_ind_emit
               and nf.serie           = trim(ev_serie)
               and nf.nro_nf          = en_nro_nf
               and nf.dm_arm_nfe_terc = nvl(en_dm_arm_nfe_terc,0)
               and nf.modfiscal_id    = vn_modfiscal_id
               and trunc(nf.dt_emiss) = trunc(ed_dt_emiss)
               and ( ( vv_cpf_cnpj is not null
                       and ( nf.pessoa_id in ( select j.pessoa_id from juridica j where ( lpad(j.num_cnpj, 8, '0') || lpad(j.num_filial, 4, '0') || lpad(j.dig_cnpj, 2, '0') ) = vv_cpf_cnpj ) -- juridica
                             or
                             nf.pessoa_id in ( select f.pessoa_id from fisica f where ( lpad(f.num_cpf, 9, '0') || lpad(f.dig_cpf, 2, '0') ) = vv_cpf_cnpj ) -- fisica
                           )
                     )
                     or ( nf.pessoa_id = vn_pessoa_id )
                   );
         exception
            when no_data_found then
               --
               vn_fase := 8;
               --
               begin
                  select nf.id
                    into vn_notafiscal_id
                    from Nota_Fiscal nf
                   where nf.empresa_id     in (select e.id
                                                  from juridica j
                                                     , empresa e
                                                 where j.num_cnpj   = vn_num_cnpj_empr
                                                   and j.num_filial = vn_num_filial_empr
                                                   and j.dig_cnpj   = vn_dig_cnpj_empr
                                                   and e.pessoa_id  = j.pessoa_id)
                     and nf.dm_ind_emit     = en_dm_ind_emit
                     and nf.serie           = trim(ev_serie)
                     and nf.nro_nf          = en_nro_nf
                     and nf.dm_arm_nfe_terc = nvl(en_dm_arm_nfe_terc,0)
                     and nf.modfiscal_id    = vn_modfiscal_id
                     and trunc(nf.dt_emiss) = trunc(ed_dt_emiss)
                     and nf.pessoa_id      is null
                     and nf.dm_st_proc not in (4,6,7,8); -- 4-Autorizada, 6-Denegada, 7-Cancelada, 8-Inutilizada
               exception
                  when no_data_found then
                     return -1;
               end;
         end;
         --
      else
         --
         vn_fase := 9;
         --
         begin
            select nf.id
              into vn_notafiscal_id
              from Nota_Fiscal nf
             where nf.empresa_id     in (select e.id
                                            from juridica j
                                               , empresa e
                                           where j.num_cnpj   = vn_num_cnpj_empr
                                             and j.num_filial = vn_num_filial_empr
                                             and j.dig_cnpj   = vn_dig_cnpj_empr
                                             and e.pessoa_id  = j.pessoa_id)
               and nf.dm_ind_emit     = en_dm_ind_emit
               and nf.serie           = trim(ev_serie)
               and nf.nro_nf          = en_nro_nf
               and nf.dm_arm_nfe_terc = nvl(en_dm_arm_nfe_terc,0)
               and nf.modfiscal_id    = vn_modfiscal_id
               and ( ( vv_cpf_cnpj is not null
                       and ( nf.pessoa_id in ( select j.pessoa_id from juridica j where ( lpad(j.num_cnpj, 8, '0') || lpad(j.num_filial, 4, '0') || lpad(j.dig_cnpj, 2, '0') ) = vv_cpf_cnpj ) -- juridica
                             or
                             nf.pessoa_id in ( select f.pessoa_id from fisica f where ( lpad(f.num_cpf, 9, '0') || lpad(f.dig_cpf, 2, '0') ) = vv_cpf_cnpj ) -- fisica
                           )
                     )
                     or ( nf.pessoa_id = vn_pessoa_id )
                   );
         exception
            when no_data_found then
               --
               vn_fase := 10;
               --
               begin
                  select nf.id
                    into vn_notafiscal_id
                    from Nota_Fiscal nf
                   where nf.empresa_id     in (select e.id
                                                 from juridica j
                                                    , empresa e
                                                where j.num_cnpj   = vn_num_cnpj_empr
                                                  and j.num_filial = vn_num_filial_empr
                                                  and j.dig_cnpj   = vn_dig_cnpj_empr
                                                  and e.pessoa_id  = j.pessoa_id)
                     and nf.dm_ind_emit     = en_dm_ind_emit
                     and nf.serie           = trim(ev_serie)
                     and nf.nro_nf          = en_nro_nf
                     and nf.dm_arm_nfe_terc = nvl(en_dm_arm_nfe_terc,0)
                     and nf.modfiscal_id    = vn_modfiscal_id
                     and nf.pessoa_id      is null
                     and nf.dm_st_proc not in (4,6,7,8); -- 4-Autorizada, 6-Denegada, 7-Cancelada, 8-Inutilizada
               exception
                  when no_data_found then
                     return -1;
               end;
         end;
         --
      end if;
      --
   else
      --
      vn_fase := 11;
      --
      if ev_cod_mod in ('06', '21', '22', '28', '29', '66') then
         --
         vn_fase := 12;
         --
         begin
            select nf.id
              into vn_notafiscal_id
              from Nota_Fiscal nf
             where nf.empresa_id     in (select e.id
                                           from juridica j
                                              , empresa e
                                          where j.num_cnpj   = vn_num_cnpj_empr
                                            and j.num_filial = vn_num_filial_empr
                                            and j.dig_cnpj   = vn_dig_cnpj_empr
                                            and e.pessoa_id  = j.pessoa_id)
               and nf.dm_ind_emit     = en_dm_ind_emit
               and nf.serie           = trim(ev_serie)
               and nf.nro_nf          = en_nro_nf
               and nf.dm_arm_nfe_terc = nvl(en_dm_arm_nfe_terc,0)
               and nf.modfiscal_id    = vn_modfiscal_id
               and trunc(nf.dt_emiss) = trunc(ed_dt_emiss);
         exception
            when no_data_found then
               return -1;
         end;
         --
      else
         --
         vn_fase := 13;
         --
         begin
            select nf.id
              into vn_notafiscal_id
              from Nota_Fiscal nf
             where nf.empresa_id     in (select e.id
                                           from juridica j
                                              , empresa e
                                          where j.num_cnpj   = vn_num_cnpj_empr
                                            and j.num_filial = vn_num_filial_empr
                                            and j.dig_cnpj   = vn_dig_cnpj_empr
                                            and e.pessoa_id  = j.pessoa_id)
               and nf.dm_ind_emit     = en_dm_ind_emit
               and nf.serie           = trim(ev_serie)
               and nf.nro_nf          = en_nro_nf
               and nf.dm_arm_nfe_terc = nvl(en_dm_arm_nfe_terc,0)
               and nf.modfiscal_id    = vn_modfiscal_id;
         exception
            when no_data_found then
               return -1;
            when too_many_rows then
               --
               vn_fase := 14;
               --
               begin
                  select min(nf.id)
                    into vn_notafiscal_id
                    from Nota_Fiscal nf
                   where nf.empresa_id     in (select e.id
                                                 from juridica j
                                                    , empresa e
                                                where j.num_cnpj   = vn_num_cnpj_empr
                                                  and j.num_filial = vn_num_filial_empr
                                                  and j.dig_cnpj   = vn_dig_cnpj_empr
                                                  and e.pessoa_id  = j.pessoa_id)
                     and nf.dm_ind_emit     = en_dm_ind_emit
                     and nf.serie           = trim(ev_serie)
                     and nf.nro_nf          = en_nro_nf
                     and nf.dm_arm_nfe_terc = nvl(en_dm_arm_nfe_terc,0)
                     and nf.modfiscal_id    = vn_modfiscal_id;
               exception
                  when no_data_found then
                     return -1;
               end;
         end;
         --
      end if;
      --
   end if;
   --
   return vn_notafiscal_id;
   --
exception
   when no_data_found then
      return -1;
   when others then
      raise_application_error(-20101, 'Erro na fkg_busca_notafiscal_id - vn_fase ('||vn_fase||'). Parâmetros: en_empresa_id: '||en_empresa_id||
                                      ', ev_cod_mod: '||ev_cod_mod||', ev_serie: '||ev_serie||', en_nro_nf: '||en_nro_nf||', en_dm_ind_oper: '||en_dm_ind_oper||
                                      ', en_dm_ind_emit: '||en_dm_ind_emit||', ev_cod_part: '||ev_cod_part||', en_dm_arm_nfe_terc: '||en_dm_arm_nfe_terc||
                                      ', ed_dt_emiss: '||ed_dt_emiss||'. Erro: '||sqlerrm);
end fkg_busca_notafiscal_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o campo EMPRESA_ID conforme o multorg_id e (CPF ou CNPJ)

function fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id  in mult_org.id%type
                                      , ev_cpf_cnpj    in varchar2
                                      )
         return Empresa.id%TYPE
is

   vn_empresa_id Empresa.id%TYPE := null;

begin

   if length(ev_cpf_cnpj) = 14 then
      --
      select e.id
        into vn_empresa_id
        from Empresa   e
           , Juridica  j
       where j.num_cnpj     = to_number( substr(ev_cpf_cnpj, 1, 8) )
         and j.num_filial   = to_number( substr(ev_cpf_cnpj, 9, 4) )
         and j.dig_cnpj     = to_number( substr(ev_cpf_cnpj, 13, 2) )
         and e.pessoa_id    = j.pessoa_id
         and e.dm_situacao  = 1 -- Ativo
         and e.multorg_id   = en_multorg_id;
      --
   elsif length(ev_cpf_cnpj) = 11 then
      --
      select e.id
        into vn_empresa_id
        from Empresa   e
           , Fisica    f
       where f.num_cpf      = to_number( substr(ev_cpf_cnpj, 1, 9) )
         and f.dig_cpf      = to_number( substr(ev_cpf_cnpj, 10, 2) )
         and e.pessoa_id    = f.pessoa_id
         and e.dm_situacao  = 1 -- Ativo
         and e.multorg_id   = en_multorg_id;
      --
   end if;

   return vn_empresa_id;

exception
   when no_data_found then
      return null;
   when others then
      return null;
end fkg_empresa_id_pelo_cpf_cnpj;

-------------------------------------------------------------------------------------------------------

-- Função retorna o campo EMPRESA_ID conforme a multorg_id e Incrição Estadual

function fkg_empresa_id_pelo_ie ( en_multorg_id  in mult_org.id%type
                                , ev_ie          in juridica.ie%type
                                )
         return Empresa.id%TYPE
is

   vn_empresa_id Empresa.id%TYPE := null;

begin
   --
   select e.id
     into vn_empresa_id
     from Empresa   e
        , juridica  j
    where trim(j.ie)    = trim(ev_ie)
      and e.pessoa_id   = j.pessoa_id
      and e.multorg_id  = en_multorg_id;
   --
   return vn_empresa_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      return null;
end fkg_empresa_id_pelo_ie;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da empresa, pelo CNPJ ou pelo Cód. Matriz e Filial

function fkg_empresa_id2 ( en_multorg_id        in             mult_org.id%type
                         , ev_cod_matriz        in             Empresa.cod_matriz%TYPE  default null
                         , ev_cod_filial        in             Empresa.cod_filial%TYPE  default null
                         , ev_empresa_cpf_cnpj  in             varchar2                 default null -- CPF/CNPJ da empresa
                         )
         return empresa.id%TYPE
is

   vn_fase            number                       := 0;
   vn_empresa_id      Empresa.id%TYPE              := null;

Begin
   --
   vn_fase := 1;
   --
   -- Busca o ID da empresa
   if trim( ev_empresa_cpf_cnpj ) is not null then
      --
      vn_fase := 1.1;
      --
      vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id  => en_multorg_id
                                                           , ev_cpf_cnpj    => ev_empresa_cpf_cnpj
                                                           );
      --
   end if;
   --
   vn_fase := 1.2;
   --
   if nvl(vn_empresa_id,0) <= 0
      and trim( ev_cod_matriz ) is not null and trim( ev_cod_filial ) is not null then
      --
      vn_fase := 1.3;
      --
      vn_empresa_id := pk_csf.fkg_Empresa_id ( en_multorg_id  => en_multorg_id
                                             , ev_cod_matriz  => ev_cod_matriz
                                             , ev_cod_filial  => ev_cod_filial
                                             );
      --
   end if;
   --
   return vn_empresa_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_id2:' || sqlerrm);
end fkg_empresa_id2;

-------------------------------------------------------------------------------------------------------

-- Procedimento responsável por retornar informações da Nota Fiscal

procedure pkb_inform_nf ( en_notafiscal_id      in  Nota_Fiscal.id%TYPE
                        , sn_lote_id             out Nota_Fiscal.lote_id%TYPE
                        , sv_cd_sitdocto         out Sit_Docto.cd%TYPE
                        , sn_nro_nf              out Nota_Fiscal.nro_nf%TYPE
                        , sv_serie               out Nota_Fiscal.serie%TYPE
                        , sn_dm_st_proc          out Nota_Fiscal.dm_st_proc%TYPE
                        , sd_dt_st_proc          out Nota_Fiscal.dt_st_proc%TYPE
                        , sn_dm_forma_emiss      out Nota_Fiscal.dm_forma_emiss%TYPE
                        , sn_dm_impressa         out Nota_Fiscal.dm_impressa%TYPE
                        , sn_dm_st_email         out Nota_Fiscal.dm_st_email%TYPE
                        , sn_dm_tp_amb           out Nota_Fiscal.dm_tp_amb%TYPE
                        , sd_dt_aut_sefaz        out Nota_Fiscal.dt_aut_sefaz%TYPE
                        , sn_dm_aut_sefaz        out Nota_Fiscal.dm_aut_sefaz%TYPE
                        , sv_nro_chave_nfe       out Nota_Fiscal.nro_chave_nfe%TYPE
                        , sn_cNF_nfe             out Nota_Fiscal.cNF_nfe%TYPE
                        , sn_dig_verif_chave     out Nota_Fiscal.dig_verif_chave%TYPE
                        , sn_nro_protocolo       out Nota_Fiscal.nro_protocolo%TYPE
                        , sn_nro_protocolo_canc  out Nota_Fiscal_Canc.nro_protocolo%TYPE
                        , sd_dt_canc             out Nota_Fiscal_Canc.dt_canc%TYPE
                        )
is

begin

   if nvl(en_notafiscal_id,0) > 0 then
      --
      select nf.lote_id
           , sd.cd
           , nf.nro_nf
           , nf.serie
           , nf.dm_st_proc
           , nf.dt_st_proc
           , nf.dm_forma_emiss
           , nf.dm_impressa
           , nf.dm_st_email
           , nf.dm_tp_amb
           , nf.dt_aut_sefaz
           , nf.dm_aut_sefaz
           , nf.nro_chave_nfe
           , nf.cNF_nfe
           , nf.dig_verif_chave
           , nf.nro_protocolo
           , nfc.nro_protocolo
           , nfc.dt_canc
        into sn_lote_id
           , sv_cd_sitdocto
           , sn_nro_nf
           , sv_serie
           , sn_dm_st_proc
           , sd_dt_st_proc
           , sn_dm_forma_emiss
           , sn_dm_impressa
           , sn_dm_st_email
           , sn_dm_tp_amb
           , sd_dt_aut_sefaz
           , sn_dm_aut_sefaz
           , sv_nro_chave_nfe
           , sn_cNF_nfe
           , sn_dig_verif_chave
           , sn_nro_protocolo
           , sn_nro_protocolo_canc
           , sd_dt_canc
        from Nota_Fiscal       nf
           , Sit_Docto         sd
           , Nota_Fiscal_Canc  nfc
       where nf.id = en_notafiscal_id
         and sd.id = nf.sitdocto_id
         and nfc.notafiscal_id(+) = nf.id;
      --
   end if;

exception
   when no_data_found then
      sn_lote_id             := null;
      sv_cd_sitdocto         := null;
      sn_nro_nf              := null;
      sv_serie               := null;
      sn_dm_st_proc          := null;
      sd_dt_st_proc          := null;
      sn_dm_forma_emiss      := null;
      sn_dm_impressa         := null;
      sn_dm_st_email         := null;
      sn_dm_tp_amb           := null;
      sd_dt_aut_sefaz        := null;
      sn_dm_aut_sefaz        := null;
      sv_nro_chave_nfe       := null;
      sn_cNF_nfe             := null;
      sn_dig_verif_chave     := null;
      sn_nro_protocolo       := null;
      sn_nro_protocolo_canc  := null;
      sd_dt_canc             := null;
   when others then
      raise_application_error(-20101, 'Erro na pkb_inform_nf:' || sqlerrm);
end pkb_inform_nf;

-------------------------------------------------------------------------------------------------------

--| Função retorna a Sigla do Tipo de Imposto

function fkg_Tipo_Imposto_Sigla ( en_cd  in Tipo_Imposto.cd%TYPE )
         return Tipo_Imposto.Sigla%TYPE
is

   vv_Sigla  Tipo_Imposto.Sigla%TYPE;

begin

   select sigla
     into vv_Sigla
     from Tipo_Imposto
    where cd = en_cd;

   return vv_Sigla;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Tipo_Imposto_Sigla:' || sqlerrm);
end fkg_Tipo_Imposto_Sigla;

-------------------------------------------------------------------------------------------------------

--| Função retorna o COD_PART pelo ID da pessoa

function fkg_pessoa_cod_part ( en_pessoa_id in pessoa.id%type )
         return pessoa.cod_part%type
is

   vv_cod_part pessoa.cod_part%type := null;

begin

   select p.cod_part
     into vv_cod_part
     from pessoa p
    where p.id = en_pessoa_id;

   return vv_cod_part;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_pessoa_cod_part:' || sqlerrm);
end fkg_pessoa_cod_part;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Contador conforme en_multorg_id e COD_PART

function fkg_contador_id ( en_multorg_id  in mult_org.id%type
                         , ev_cod_part    in pessoa.cod_part%type
                         )
         return contador.id%type
is

   vn_contador_id contador.id%type;

begin
   --
   select c.id
     into vn_contador_id
     from pessoa       p
        , contador     c
    where p.multorg_id = en_multorg_id
      and p.cod_part   = trim(ev_cod_part)
      and c.pessoa_id  = p.id;
   --
   return vn_contador_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_contador_id:' || sqlerrm);
end fkg_contador_id;

-------------------------------------------------------------------------------------------------------

-- Retorna o ID do usuário do Sistema conforme multorg_id e ID_ERP

function fkg_neo_usuario_id_conf_erp ( en_multorg_id  in mult_org.id%type
                                     , ev_id_erp      in neo_usuario.id_erp%type
                                     )
         return neo_usuario.id%type
is

   vn_neo_usuario_id neo_usuario.id%type := null;

   vv_id_erp neo_usuario.id_erp%type := null;

begin
   --
   vv_id_erp := trim( pk_csf.fkg_converte( ev_id_erp ) );
   --
   if vv_id_erp is not null then
      --
      begin
         select id
           into vn_neo_usuario_id
           from neo_usuario
          where multorg_id  = en_multorg_id
            and id_erp      = vv_id_erp;
      exception
         when no_data_found then
            -- Foi incluida essa nova verificacao em funcao do campo id_erp na integracao receber o vlr do login
            -- Nos casos de cadastro manual de usuario o campo id_erp pode ficar nulo, nao retornando o id
            begin
               select id
                 into vn_neo_usuario_id
                 from neo_usuario
                where multorg_id  = en_multorg_id
                  and login       = vv_id_erp;
            exception
               when others then
                  return (null);
            end;
      end;
      --
   end if;
   --
   return vn_neo_usuario_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_neo_usuario_id_conf_erp:' || sqlerrm);
end fkg_neo_usuario_id_conf_erp;
-------------------------------------------------------------------------------------------------------
-- Retorna o ID da impressora vinculada a série (tabela EMPRESA_PARAM_SERIE)
procedure pkb_impressora_id_serie ( en_empresa_id    in  Empresa.id%TYPE
                                 , en_modfiscal_id  in  Mod_Fiscal.Id%TYPE
                                 , ev_serie         in  Nota_Fiscal.serie%TYPE
                                 , en_nfusuario_id  in  nota_fiscal.usuario_id%type
                                 , sn_impressora_id out nota_fiscal.impressora_id%type
                                 , sn_qtd_impr      out nota_fiscal.vias_danfe_custom%type)
is


begin
   --
    begin
      select s.impressora_id
            ,nvl(s.max_qtd_impressao,1) max_qtd_impressao
        into sn_impressora_id
            ,sn_qtd_impr
        from empresa_param_serie s
            ,impressora i
       where s.impressora_id = i.id
         and s.empresa_id    = en_empresa_id
         and s.modfiscal_id  = en_modfiscal_id
         and s.serie         = ev_serie
         and i.dm_situacao   = 1; /*impressora ativa*/
     exception
       when no_data_found then
         begin
           select n.impressora_id
             into sn_impressora_id
             from NEO_USUARIO n
                 ,impressora i
            where n.impressora_id = i.id
              and i.dm_situacao   = 1 -- impressora ativa
              and n.id = en_nfusuario_id;
            if sn_impressora_id is not null then
               begin
                 select nvl(e.max_qtd_impressao,1) max_qtd_impressao
                   into sn_qtd_impr
                   from empresa e
                  where e.id = en_empresa_id;
                exception
                  when no_data_found then
                    sn_qtd_impr :=1;--por padrao receberá 1
                end;
            end if;
          exception
          when no_data_found then
            begin
              select e.impressora_id
                    ,nvl(e.max_qtd_impressao,1) max_qtd_impressao
               into sn_impressora_id
                ,sn_qtd_impr
               from empresa e
                    ,impressora i
              where e.impressora_id = i.id
                and e.id = en_empresa_id
                and i.dm_situacao = 1; -- impressora ativa
             exception
             when no_data_found then
                 sn_impressora_id := null;
                 sn_qtd_impr      := null;
             end;
          end;
       end;
   --
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pkb_impressora_id_serie:' || sqlerrm);
end pkb_impressora_id_serie;
-------------------------------------------------------------------------------------------------------

-- Retorna o ID da impressora vinculada ao usuário

function fkg_impressora_id_usuario ( en_usuario_id in neo_usuario.id%type )
         return impressora.id%type
is

    vn_impressora_id impressora.id%type;

begin
   --
   select u.impressora_id
     into vn_impressora_id
     from neo_usuario u
        , impressora  i
    where u.id           = en_usuario_id
      and i.id           = u.impressora_id
      and i.dm_situacao  = 1; -- Ativa
   --
   return vn_impressora_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_impressora_id_usuario:' || sqlerrm);
end fkg_impressora_id_usuario;

-------------------------------------------------------------------------------------------------------

-- Retorna o ID da impressora vincutada a empresa

function fkg_impressora_id_empresa ( en_empresa_id in empresa.id%type )
         return impressora.id%type
is

    vn_impressora_id impressora.id%type;

begin
   --
   select e.impressora_id
     into vn_impressora_id
     from empresa     e
        , impressora  i
    where e.id           = en_empresa_id
      and i.id           = e.impressora_id
      and i.dm_situacao  = 1; -- Ativa
   --
   return vn_impressora_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_impressora_id_empresa:' || sqlerrm);
end fkg_impressora_id_empresa;

-------------------------------------------------------------------------------------------------------

-- Função retorna "true" se for uma NFe de emissão própria já autorizada, cancelada, denegada ou inutulizada, não pode ser re-integrada
function fkg_nfe_nao_integrar ( en_notafiscal_id  in nota_fiscal.id%Type )
         return boolean
is
   --
   vn_ret number := 0;
   --
begin
   --
   return false;
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_nfe_nao_integrar:' || sqlerrm);
end fkg_nfe_nao_integrar;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela CSF_TIPO_LOG conforme o identificador TIPO_LOG

function fkg_csf_tipo_log_id ( en_tipo_log in csf_tipo_log.cd_compat%type )
         return csf_tipo_log.id%type
is
   --
   vn_csftipolog_id csf_tipo_log.id%type := null;
   --
begin
   --
   if nvl(en_tipo_log,0) > 0 then
      --
      select id
        into vn_csftipolog_id
        from csf_tipo_log
       where cd_compat = en_tipo_log;
      --
   end if;
   --
   return vn_csftipolog_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_csf_tipo_log_id:' || sqlerrm);
end fkg_csf_tipo_log_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna um valor criptografado em MD5
function fkg_md5 ( ev_valor in varchar2 )
         return varchar2
is
   --
   v_input varchar2(2000) := ev_valor;
   hexkey varchar2(50) := null;
   --
begin
   --
   hexkey := rawtohex(dbms_obfuscation_toolkit.md5(input => utl_raw.cast_to_raw(v_input)));
   return lower(nvl(hexkey,''));
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na fkg_md5:' || sqlerrm);
end fkg_md5;

-------------------------------------------------------------------------------------------------------

--| Função retorna o CNPJ ou CPF conforme a empresa

function fkg_cnpj_ou_cpf_empresa ( en_empresa_id in Empresa.Id%type )
         return varchar2
is

   vv_cnpj_cpf varchar2(14) := null;

begin
   --
   if nvl(en_empresa_id,0) > 0 then
      --
      begin
         --
         select ( lpad(j.NUM_CNPJ, 8, '0') || lpad(j.NUM_FILIAL, 4, '0') || lpad(j.DIG_CNPJ, 2, '0') ) docto
           into vv_cnpj_cpf
           from empresa   e
              , juridica  j
          where e.id         = en_empresa_id
            and j.pessoa_id  = e.pessoa_id;
          --
      exception
         when others then
            vv_cnpj_cpf := null;
      end;
      --
      if trim(vv_cnpj_cpf) is null then
         --
         begin
            --
            select ( lpad(f.NUM_CPF, 9, '0') || lpad(f.DIG_CPF, 2, '0') ) docto
              into vv_cnpj_cpf
              from empresa  e
                 , fisica   f
             where e.id         = en_empresa_id
               and f.pessoa_id  = e.pessoa_id;
            --
         exception
            when others then
               vv_cnpj_cpf := null;
         end;
         --
      end if;
      --
   end if;
   --
   return vv_cnpj_cpf;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cnpj_ou_cpf_empresa:' || sqlerrm);
end fkg_cnpj_ou_cpf_empresa;

-------------------------------------------------------------------------------------------------------

--| Função retorna o CNAE conforme a empresa

function fkb_retorna_cnae ( en_empresa_id in empresa.id%type )
         return varchar2
is

   vv_cnae varchar2(7) := null;

begin
   --
   if nvl(en_empresa_id,0) > 0 then
      --
      select ju.cnae
        into vv_cnae
        from empresa  em
           , juridica ju
       where em.id        = en_empresa_id
         and ju.pessoa_id = em.pessoa_id;
      --
   end if;
   --
   return vv_cnae;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkb_retorna_cnae:' || sqlerrm);
end fkb_retorna_cnae;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID do usuário
function fkg_usuario_id ( ev_login       in neo_usuario.login%type )
         return neo_usuario.id%type
is

   vn_usuario_id neo_usuario.id%type := null;

begin
   --
   if ev_login is not null then
      --
      select u.id
        into vn_usuario_id
        from neo_usuario u
       where u.login = ev_login;
      --
   end if;
   --
   return vn_usuario_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_usuario_id:' || sqlerrm);
end fkg_usuario_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna TRUE se a pessoa existe e FALSE se ela não existe, conforme o ID

function fkg_existe_pessoa ( en_pessoa_id in pessoa.id%type )
         return boolean
is

   vn_existe number := 0;

begin
   --
   select 1
     into vn_existe
     from pessoa
    where id = en_pessoa_id;
   --
   return (vn_existe = 1);
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_pessoa:' || sqlerrm);
end fkg_existe_pessoa;

-------------------------------------------------------------------------------------------------------

--| Função retorna "true" se o código do pais for válido e "false" se não for, conforme ID

function fkg_pais_id_valido ( en_pais_id  in Pais.id%TYPE )
         return boolean
is

   vn_dummy number := 0;

begin

   if nvl(en_pais_id,0) > 0 then

      select 1
        into vn_dummy
        from Pais p
       where id = en_pais_id;

   end if;

   if nvl(vn_dummy,0) > 0 then
      return true;
   else
      return false;
   end if;

exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_pais_id_valido: ' || sqlerrm);
end fkg_pais_id_valido;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da cidade conforme o código do IBGE

function fkg_cidade_id_ibge ( ev_ibge_cidade in cidade.ibge_cidade%type )
         return cidade.id%type
is

   vn_cidade_id cidade.id%type := null;

begin
   --
   select id
     into vn_cidade_id
     from cidade
    where ibge_cidade = trim(ev_ibge_cidade);
   --
   return vn_cidade_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cidade_id_ibge: ' || sqlerrm);
end fkg_cidade_id_ibge;

-------------------------------------------------------------------------------------------------------

--| Função retorna o IBGE da cidade conforme o ID

function fkg_ibge_cidade_id ( en_cidade_id  in Cidade.id%TYPE )
         return cidade.ibge_cidade%type
is

   vv_ibge_cidade cidade.ibge_cidade%type := null;

begin

   select ibge_cidade
     into vv_ibge_cidade
     from cidade
    where id = en_cidade_id;

   return vv_ibge_cidade;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_ibge_cidade_id: ' || sqlerrm);
end fkg_ibge_cidade_id;

-------------------------------------------------------------------------------------------------------

--| retorna o códido do siscomex conforme o id do país

function fkg_cod_siscomex_pais_id ( en_pais_id  in Pais.id%TYPE )
         return pais.cod_siscomex%type
is

   vn_cod_siscomex pais.cod_siscomex%type := null;

begin

   select cod_siscomex
     into vn_cod_siscomex
     from pais
    where id = en_pais_id;

   return vn_cod_siscomex;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cod_siscomex_pais_id: ' || sqlerrm);
end fkg_cod_siscomex_pais_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna TRUE se a unidade existe e FALSE se não existe, conforme o ID

function fkg_existe_unidade_id ( en_unidade_id in unidade.id%type )
         return boolean
is

   vn_dummy number := 0;

begin
   --
   select 1
     into vn_dummy
     from unidade
    where id = en_unidade_id;
   --
   return (vn_dummy = 1);
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_unidade_id: ' || sqlerrm);
end fkg_existe_unidade_id;

-------------------------------------------------------------------------------------------------------

-- Função retorno o CD do tipo de item conforme o ID

function fkg_cd_tipo_item_id ( en_tipoitem_id in tipo_item.id%type )
         return tipo_item.cd%type
is

   vv_cd tipo_item.cd%type;

begin
   --
   select cd
     into vv_cd
     from tipo_item
    where id = en_tipoitem_id;
   --
   return vv_cd;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cd_tipo_item_id: ' || sqlerrm);
end fkg_cd_tipo_item_id;

-------------------------------------------------------------------------------------------------------

-- Função Retorna o Código da ANP do produto

function fkg_cod_anp_valido ( ev_cod_anp in cod_anp.cd%type )
         return boolean
is

   vn_dummy number := 0;

begin
   --
   select 1
     into vn_dummy
     from cod_anp
    where cd = ev_cod_anp;
   --
   return (vn_dummy = 1);
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cod_anp_valido: ' || sqlerrm);
end fkg_cod_anp_valido;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da Coversão de Unidade conforme Item e Unidade

function fkg_id_conv_unid ( en_item_id     in item.id%type
                          , ev_unidade_id  in unidade.id%type )
         return conversao_unidade.id%Type
is

   vn_convunid_id conversao_unidade.id%Type := null;

begin
   --
   select max(id)
     into vn_convunid_id
     from conversao_unidade
    where item_id     = en_item_id
      and unidade_id  = ev_unidade_id;
   --
   return vn_convunid_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_id_conv_unid: ' || sqlerrm);
end fkg_id_conv_unid;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do bem do ativo imobilizado conforme empresa e código do item

function fkg_id_bem_ativo_imob ( en_empresa_id   in empresa.id%type
                               , ev_cod_ind_bem  in bem_ativo_imob.cod_ind_bem%type )
         return bem_ativo_imob.id%type
is

   vn_bemativoimob_id bem_ativo_imob.id%type;

begin
   --
   select id
     into vn_bemativoimob_id
     from bem_ativo_imob
    where empresa_id = en_empresa_id
      and cod_ind_bem = trim(ev_cod_ind_bem);
   --
   return vn_bemativoimob_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_id_bem_ativo_imob: ' || sqlerrm);
end fkg_id_bem_ativo_imob;

-------------------------------------------------------------------------------------------------------

-- Função returna TRUE se existe o bem ID ou FALSE se não existe, conforme o ID

function fkg_existe_bem_ativo_imob ( en_bemativoimob_id in bem_ativo_imob.id%type )
         return boolean
is

   vn_dummy number := 0;

begin
   --
   select 1
     into vn_dummy
     from bem_ativo_imob
    where id = en_bemativoimob_id;
   --
   return (vn_dummy = 1);
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_bem_ativo_imob: ' || sqlerrm);
end fkg_existe_bem_ativo_imob;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da Utilização do Bem conforme Bem, Conta Contábil e Centro de Custo

function fkg_id_infor_util_bem ( en_bemativoimob_id in bem_ativo_imob.id%type
                               , ev_cod_ccus        in infor_util_bem.cod_ccus%type )
         return infor_util_bem.id%type
is

   vn_inforutilbem_id infor_util_bem.id%type := null;

begin
   --
   select id
     into vn_inforutilbem_id
     from infor_util_bem
    where bemativoimob_id    = en_bemativoimob_id
      and trim(cod_ccus)     = trim(ev_cod_ccus);
   --
   return vn_inforutilbem_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_id_infor_util_bem: ' || sqlerrm);
end fkg_id_infor_util_bem;

-------------------------------------------------------------------------------------------------------

-- Função verifica se existe o ID da Informação Complementar do Documento Fiscal

function fkg_existe_Inf_Comp_Dcto_Fis ( en_infcompdctofis_id in infor_comp_dcto_fiscal.id%type )
         return boolean
is

   vn_dummy number := 0;

begin
   --
   select 1
     into vn_dummy
     from infor_comp_dcto_fiscal
    where id = en_infcompdctofis_id;
   --
   return (vn_dummy = 1);
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_Inf_Comp_Dcto_Fis: ' || sqlerrm);
end fkg_existe_Inf_Comp_Dcto_Fis;

-------------------------------------------------------------------------------------------------------

--| Função Retorna o ID da Observação do Lançamento Fiscal

function fkg_id_obs_lancto_fiscal ( en_multorg_id in mult_org.id%type
                                  , ev_cod_obs    in obs_lancto_fiscal.cod_obs%type )
         return obs_lancto_fiscal.id%type
is

   vn_obslanctofiscal_id obs_lancto_fiscal.id%type;

begin
   --
   select id
     into vn_obslanctofiscal_id
     from obs_lancto_fiscal
    where cod_obs = trim(ev_cod_obs)
      and multorg_id = en_multorg_id;
   --
   return vn_obslanctofiscal_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_id_obs_lancto_fiscal: ' || sqlerrm);
end fkg_id_obs_lancto_fiscal;

-------------------------------------------------------------------------------------------------------

--| Função verifica se existe da Observação do Lançamento Fiscal

function fkg_existe_obs_lancto_fiscal ( en_obslanctofiscal_id in obs_lancto_fiscal.id%type )
         return boolean
is

   vn_dummy number := 0;

begin
   --
   select 1
     into vn_dummy
     from obs_lancto_fiscal
    where id = en_obslanctofiscal_id;
   --
   return (vn_dummy = 1);
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_obs_lancto_fiscal: ' || sqlerrm);
end fkg_existe_obs_lancto_fiscal;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID do inventário

function fkg_inventario_id ( en_empresa_id     in empresa.id%type
                           , en_item_id        in item.id%type
                           , en_unidade_id     in unidade.id%type
                           , ed_dt_inventario  in inventario.dt_inventario%type
                           , en_dm_ind_prop    in inventario.dm_ind_prop%type
                           , en_pessoa_id      in pessoa.id%type
                           )
         return inventario.id%type
is

   vn_inventario_id inventario.id%type;

begin
   --
   select id into vn_inventario_id
     from inventario
    where empresa_id        = en_empresa_id
      and item_id           = en_item_id
      and unidade_id        = en_unidade_id
      and dt_inventario     = ed_dt_inventario
      and dm_ind_prop       = en_dm_ind_prop
      and nvl(pessoa_id,0)  = nvl(en_pessoa_id,0);
   --
   return vn_inventario_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_inventario_id: ' || sqlerrm);
end fkg_inventario_id;

-------------------------------------------------------------------------------------------------------

--| Função verifica se existe o ID do inventário

function fkg_existe_inventario ( en_inventario_id in inventario.id%type )
         return boolean
is

    vn_dummy number := 0;

begin
    --
    select 1
      into vn_dummy
      from inventario
     where id = en_inventario_id;
    --
    if nvl(vn_dummy,0) > 0 then
       return true;
    else
       return false;
    end if;
    --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_inventario: ' || sqlerrm);
end fkg_existe_inventario;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da informação complementar do inventario

function fkg_invent_cst_id ( en_inventario_id  in inventario.id%type
                           , en_codst_id       in cod_st.id%type
                           )
         return invent_cst.id%type
is

   vn_invent_cst_id invent_cst.inventario_id%type;

begin
   --
   select id into vn_invent_cst_id
     from invent_cst
    where inventario_id     = en_inventario_id
      and codst_id          = en_codst_id;
   --
   return vn_invent_cst_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_invent_cst_id: ' || sqlerrm);
end fkg_invent_cst_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID do inventário para a table de informacao complementar

function fkg_inventario_info_compl_id ( en_empresa_id     in empresa.id%type
                                      , en_item_id        in item.id%type
                                      , ed_dt_inventario  in inventario.dt_inventario%type
                                      )
         return inventario.id%type
is

   vn_inventario_id inventario.id%type;

begin
   --
   select id into vn_inventario_id
     from inventario
    where empresa_id        = en_empresa_id
      and item_id           = en_item_id
      and dt_inventario     = ed_dt_inventario;
   --
   return vn_inventario_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_inventario_info_compl_id: ' || sqlerrm);
end fkg_inventario_info_compl_id;

-------------------------------------------------------------------------------------------------------

--| Função verifica se existe o ID do inventário

function fkg_existe_invent_cst ( en_invent_cst_id in invent_cst.id%type )
         return boolean
is

    vn_dummy number := 0;

begin
    --
    select 1
      into vn_dummy
      from invent_cst
     where id = en_invent_cst_id;
    --
    if nvl(vn_dummy,0) > 0 then
       return true;
    else
       return false;
    end if;
    --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_inventario: ' || sqlerrm);
end fkg_existe_invent_cst;

-------------------------------------------------------------------------------------------------------

--| Conforme o ID da Pessoa Retorna o Nome

function fkg_nome_pessoa_id ( en_pessoa_id  in pessoa.id%type )
         return pessoa.nome%type
is

   vv_nome pessoa.nome%type;

begin
   --
   select nome
     into vv_nome
     from pessoa
    where id = en_pessoa_id;
   --
   return vv_nome;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_nome_pessoa_id: ' || sqlerrm);
end fkg_nome_pessoa_id;

-------------------------------------------------------------------------------------------------------
/*
-- Download de arquivo
procedure pkb_download ( en_id         in number
                       , ev_file_name  in varchar2
                       , ev_tabela     in varchar2
                       , ev_coluna_id  in varchar2
                       , ev_campo      in varchar2
                       , ev_diretorio  in varchar2 )
is

   vblob     blob;
   vtamanho  integer;
   vfile     utl_file.file_type;
   vamount   binary_integer := 32767;
   vposicao  integer := 1;
   vbuffer   raw(32767);
   varquivo  varchar2(30);

begin
   --
   execute immediate ('select ' || ev_campo || ' from ' ||  ev_tabela || ' where ' || ev_coluna_id || ' = ' || en_id)
      into vblob;
   --
   vtamanho := dbms_lob.getlength(vblob);
   --
   vfile := utl_file.fopen( ev_diretorio, ev_file_name, 'wb', 32767 );
   --
   while vposicao < vtamanho loop
      --
      if vposicao + vamount > vtamanho then
         vamount := (vtamanho + 1) - vposicao;
      end if;
      --
      dbms_lob.read(vblob, vamount, vposicao, vbuffer);
      --
      utl_file.put_raw(vfile, vbuffer, true);
      --
      utl_file.fflush(vfile);
      --
      vposicao := vposicao + vamount;
      --
   end loop;
   --
   utl_file.fclose(vfile);
   --
exception
   when others then
        raise_application_error (-20001,'erro na pk_csf.pkb_download : ' || sqlerrm);
end pkb_download; */

-------------------------------------------------------------------------------------------------------
/*
--| Upload de arquivo
procedure pkb_upload ( en_id         in number
                     , ev_file_name  in varchar2
                     , ev_tabela     in varchar2
                     , ev_coluna_id  in varchar2
                     , ev_campo      in varchar2
                     , ev_diretorio  in varchar2 )
is

   src_file      bfile;
   dst_file      blob := empty_blob();
   lgh_file      binary_integer;
   vn_fase       number;

begin
   --
   vn_fase := 1;
   --
   src_file := bfilename(ev_diretorio, ev_file_name);

   -- insert a null record to lock
   vn_fase := 2;
   --
   execute immediate ('delete from ' || ev_tabela || ' where ' || ev_coluna_id || ' = ' || en_id);
   --
   vn_fase := 3;
   --
   execute immediate ('insert into ' || ev_tabela || ' ( ' ||  ev_coluna_id || ',' ||  ev_campo || ', tp ) values ( ' ||  en_id || ', empty_blob(),1)');
   --
   -- lock record
   --
   vn_fase := 4;
   --
   execute immediate ('select ' || ev_campo || ' from ' ||  ev_tabela ||
                      ' where ' || ev_coluna_id || ' = ' || en_id ||
                 ' for update')
      into dst_file;
   --
   vn_fase := 5;
   --
   -- open the file
   dbms_lob.fileopen(src_file, dbms_lob.file_readonly);
   --
   vn_fase := 5;
   --
   -- determine length
   lgh_file := dbms_lob.getlength(src_file);
   --
   vn_fase := 7;
   --
   -- read the file
   dbms_lob.loadfromfile(dst_file, src_file, lgh_file);
   --
   vn_fase := 8;
   --
   -- update the blob field
   execute immediate ('update ' || ev_tabela   || ' set ' || ev_campo || ' = :valor
                        where ' || ev_coluna_id || ' = :id ')
     using dst_file, en_id;

   vn_fase := 9;

   -- close file
   dbms_lob.fileclose(src_file);
   --
   vn_fase := 10;
   --
   commit;
   --
exception
   when others then
        rollback;
        raise_application_error (-20001,'erro na pk_csf.pkb_upload, ev_diretorio : ' || ev_diretorio || ', file : ' || ev_file_name || ', fase : ' || vn_fase || ', erro : ' ||  sqlerrm);
end pkb_upload; */

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da Unidade Organizacional conforme EMPRESA_ID e código UO

function fkg_unig_org_id ( en_empresa_id    in  empresa.id%type
                         , ev_cod_unid_org  in  unid_org.cd%type )
         return unid_org.id%type
is

   vn_unidorg_id unid_org.id%type;

begin
   --
   select uo.id
     into vn_unidorg_id
     from unid_org uo
    where uo.empresa_id  = en_empresa_id
      and uo.cd          = ev_cod_unid_org;
   --
   return vn_unidorg_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_unig_org_id: ' || sqlerrm);
end fkg_unig_org_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o codigo da Unidade Organizacional conforme o ID

function fkg_unig_org_cd ( en_unidorg_id    in  unid_org.id%type )
         return unid_org.cd%type
is

   vv_unidorg_cd unid_org.cd%type;

begin
   --
   if nvl(en_unidorg_id, 0) > 0 then
      --
      select uo.cd
        into vv_unidorg_cd
        from unid_org uo
       where uo.id  = en_unidorg_id;
      --
   end if;
   --
   return vv_unidorg_cd;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_unig_org_cd: ' || sqlerrm);
end fkg_unig_org_cd;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do Sistema de Origem conforme a Sigla

function fkg_sist_orig_id ( en_multorg_id in  sist_orig.multorg_id%type
                          , ev_sigla      in  sist_orig.sigla%type )
         return sist_orig.id%type
is

   vn_sistorig_id  sist_orig.id%type;

begin
   --
   select so.id
     into vn_sistorig_id
     from sist_orig so
    where upper(so.sigla) = upper(ev_sigla)
      and multorg_id      = en_multorg_id;
   --
   return vn_sistorig_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_sist_orig_id: ' || sqlerrm);
end fkg_sist_orig_id;

-------------------------------------------------------------------------------------------------------
-- Função retorna o Sigla do Sistema de Origem conforme o ID

function fkg_sist_orig_sigla ( en_sistorig_id  in  sist_orig.id%type )
         return sist_orig.sigla%type
is

   vv_sistorig_sigla  sist_orig.sigla%type := null;

begin
   --
   if nvl(en_sistorig_id, 0) > 0 then
      --
      select so.sigla
        into vv_sistorig_sigla
        from sist_orig so
        where id = en_sistorig_id;
      --
   end if;
   --
   return vv_sistorig_sigla;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_sist_orig_sigla: ' || sqlerrm);
end fkg_sist_orig_sigla;

-------------------------------------------------------------------------------------------------------

-- Função retorna o parâmetro de impressa automática 0-Não ou 1-Sim, conforme ID da empresa

function fkg_empresa_impr_aut ( en_empresa_id  in  empresa.id%type )
         return empresa.dm_impr_aut%type
is

   vn_dm_impr_aut empresa.dm_impr_aut%type;

begin
   --
   select e.dm_impr_aut
     into vn_dm_impr_aut
     from empresa e
    where e.id = en_empresa_id;
   --
   return vn_dm_impr_aut;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_impr_aut: ' || sqlerrm);
end fkg_empresa_impr_aut;

-------------------------------------------------------------------------------------------------------

-- Retorna true se a IBGE_UF for o mesmo da empresa, e false se não for

function fkg_uf_ibge_igual_empresa ( en_empresa_id   in  empresa.id%type
                                   , ev_ibge_estado  in  estado.ibge_estado%type )
         return boolean
is

   vn_dummy number := 0;

begin
   --
   if nvl(en_empresa_id,0) > 0 and ev_ibge_estado is not null then
      --
      select 1
        into vn_dummy
        from empresa  e
           , pessoa   p
           , cidade   c
           , estado   es
       where e.id            = en_empresa_id
         and p.id            = e.pessoa_id
         and c.id            = p.cidade_id
         and es.id           = c.estado_id
         and es.ibge_estado  = ev_ibge_estado;
      --
      if nvl(vn_dummy,0) = 1 then
         return true;
      else
         return false;
      end if;
      --
   else
      --
      return false;
      --
   end if;
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_impr_aut: ' || sqlerrm);
end fkg_uf_ibge_igual_empresa;

-------------------------------------------------------------------------------------------------------

-- verifica se o código do IBGE do estado corresponde a sigla do estado

function fkg_compara_ibge_com_sigla_uf ( ev_ibge_estado   in  estado.ibge_estado%type
                                       , ev_sigla_estado  in  estado.sigla_estado%type )
         return boolean
is

   vn_dummy number := 0;

begin
   --
   select 1
     into vn_dummy
     from estado es
    where es.ibge_estado   = ev_ibge_estado
      and es.sigla_estado  = ev_sigla_estado;
   --
   if nvl(vn_dummy,0) = 1 then
      return true;
   else
      return false;
   end if;
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_impr_aut: ' || sqlerrm);
end fkg_compara_ibge_com_sigla_uf;

-------------------------------------------------------------------------------------------------------

-- Função retorna a sigla do estado conforme o ID

function fkg_Estado_id_sigla ( en_estado_id in estado.id%type )
         return estado.sigla_estado%type
is
   --
   vv_sigla_estado estado.sigla_estado%type := null;
   --
begin
   --
   if nvl(en_estado_id,0) > 0 then
      --
      select e.sigla_estado
        into vv_sigla_estado
        from estado e
       where e.id = en_estado_id;
      --
   end if;
   --
   return vv_sigla_estado;
   --
exception
   when no_data_found then
      return 'EX';
   when others then
      raise_application_error(-20101, 'Erro na fkg_Estado_id_sigla: ' || sqlerrm);
end fkg_Estado_id_sigla;

-------------------------------------------------------------------------------------------------------

-- Função retorna "true" se o valor é númerico ou "false" se não é

function fkg_is_numerico ( ev_valor in varchar2 )
         return boolean
is

   vn_numero number;

begin
   --
   vn_numero := to_number(ev_valor);
   --
   return true;
   --
exception
   when others then
      return false;
end fkg_is_numerico;

-------------------------------------------------------------------------------------------------------


-- Função retorna "true" se for uma NFe de emissão própria já autorizada, cancelada, denegada ou inutulizada, não pode ser re-integrada
function fkg_cte_nao_integrar ( en_conhectransp_id in             Conhec_Transp.id%TYPE )
         return boolean
is
   --
   vn_ret number := 0;
   --
begin
   --
   select 1
     into vn_ret
     from conhec_transp   cf
        , mod_fiscal      mf
    where cf.id           = en_conhectransp_id
      and cf.dm_ind_emit  = 0 -- Emissão Própria
      and ( cf.dm_st_proc in ( 4, 6, 7, 8 ) or (cf.dm_st_proc = 5 and cf.cod_msg = 204) )
      and mf.id           = cf.modfiscal_id
      and mf.cod_mod      in ('57', '67');
   --
   return true;
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cte_nao_integrar:' || sqlerrm);
--
end fkg_cte_nao_integrar;
--
-------------------------------------------------------------------------------------------------------

--| Função retorna a Sigla do Tipo de Imposto através do ID

function fkg_Tipo_Imp_Sigla ( en_id  in Tipo_Imposto.id%TYPE )
         return Tipo_Imposto.Sigla%TYPE
is

   vv_Sigla  Tipo_Imposto.Sigla%TYPE;

begin

   select sigla
     into vv_Sigla
     from Tipo_Imposto
    where id = en_id;

   return vv_Sigla;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Tipo_Imp_Sigla:' || sqlerrm);
end fkg_Tipo_Imp_Sigla;

-------------------------------------------------------------------------------------------------------

--| Função retorna o Código da tabela Cod_ST através do ID

function fkg_Cod_ST_cod ( en_id_st      in Cod_ST.id%TYPE )
         return Cod_ST.cod_st%TYPE
is

   vs_codst_id  Cod_ST.cod_st%TYPE;

begin

   select cst.cod_st
     into vs_codst_id
     from Cod_ST       cst
    where cst.id       = en_id_st;

   return vs_codst_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Cod_ST_cod:' || sqlerrm);
end fkg_Cod_ST_cod;

-------------------------------------------------------------------------------------------------------

-- função valida o formato da hora, passa o hora e o formato
function fkg_vld_formato_hora ( ev_hora     in varchar2
                              , ev_formato  in varchar2 )
                              return varchar2
is
   --
   vv_formato varchar2(8);
   --
begin
   --
   if ev_hora is not null and ev_formato is not null then
      --
      select to_char(to_date(trunc(sysdate) || ' ' || ev_hora, 'dd/mm/rrrr ' || ev_formato), ev_formato)
        into vv_formato
        from dual;
      --
      return vv_formato;
      --
   else
      --
      return null;
      --
   end if;
   --
exception
   when others then
      return null;
end fkg_vld_formato_hora;
-------------------------------------------------------------------------------------------------------

-- Função retorna o DM_ST_PROC (Situação do Processo) do Conhecimento de Transporte

function fkg_st_proc_ct ( en_conhectransp_id  in Conhec_Transp.id%TYPE )
         return Conhec_Transp.dm_st_proc%TYPE
is

   vn_dm_st_proc  Conhec_Transp.dm_st_proc%TYPE := -1;

begin

   if nvl(en_conhectransp_id,0) > 0 then
      --
      select ct.dm_st_proc
        into vn_dm_st_proc
        from Conhec_Transp ct
       where ct.id = en_conhectransp_id;
      --
   end if;

   return vn_dm_st_proc;

exception
   when no_data_found then
      return -1;
   when others then
      raise_application_error(-20101, 'Erro na fkg_st_proc_ct:' || sqlerrm);
end fkg_st_proc_ct;

-------------------------------------------------------------------------------------------------------

--| Função retorna "1" se o conhecimento de transporte está inutilizado e "0" se não está

function fkg_ct_inutiliza ( en_empresa_id  in Empresa.id%TYPE
                          , ev_cod_mod     in Mod_Fiscal.cod_mod%TYPE
                          , en_serie       in Conhec_Transp.serie%TYPE
                          , en_nro_ct      in Conhec_Transp.nro_ct%TYPE
                          )
         return number is

   vn_retorno number := 0;

begin

   select distinct 1
     into vn_retorno
     from inutiliza_conhec_transp  ict
        , Mod_Fiscal             mf
    where ict.empresa_id = en_empresa_id
      and ict.serie      = en_serie
      and en_nro_ct between ict.nro_ini and ict.nro_fim
      and mf.id          = ict.modfiscal_id
      and mf.cod_mod     = ev_cod_mod;

   return vn_retorno;

exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_ct_inutiliza:' || sqlerrm);
end fkg_ct_inutiliza;

-------------------------------------------------------------------------------------------------------

-- Função retorna a Chave do Conhecimento de Transporte

function fkg_chave_ct ( en_conhectransp_id   in      Conhec_Transp.id%TYPE )
         return Conhec_Transp.nro_chave_cte%TYPE
is

  vv_nro_chave_cte Conhec_Transp.nro_chave_cte%TYPE := null;

begin

   if nvl(en_conhectransp_id,0) > 0 then
      --
      select nro_chave_cte
        into vv_nro_chave_cte
        from Conhec_Transp
       where id = en_conhectransp_id;
      --
   end if;

   return vv_nro_chave_cte;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_chave_ct:' || sqlerrm);
end fkg_chave_ct;

-------------------------------------------------------------------------------------------------------

--| Função retorna "true" se a CT-e existe e "false" se não existe

function fkg_existe_cte ( en_conhec_transp  in Conhec_Transp.id%TYPE )
         return boolean
is

   vn_lixo  number;

begin

   select 1
     into vn_lixo
     from Conhec_Transp
    where id = en_conhec_transp;

   return true;

exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_cte: ' || sqlerrm);
end fkg_existe_cte;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do Conhec. de Transp. a partir do número da chave de acesso

function fkg_conhectransp_id_pela_chave ( en_nro_chave_cte  in Conhec_Transp.nro_chave_cte%TYPE )
         return Conhec_Transp.id%TYPE
is

   vn_conhectransp_id  Conhec_Transp.id%TYPE := null;

begin

   if en_nro_chave_cte is not null then
      --
      select max(ct.id)
        into vn_conhectransp_id
        from Conhec_Transp ct
       where ct.nro_chave_cte = en_nro_chave_cte;
      --
   end if;

   return vn_conhectransp_id;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_conhectransp_id_pela_chave:' || sqlerrm);
end fkg_conhectransp_id_pela_chave;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela Item, conforme ID Empresa, para Integração do Item por Open Interface

function fkg_item_id ( en_empresa_id in empresa.id%type
                     , ev_cod_item   in item.cod_item%type )
         return item.id%type
is
   --
   vn_item_id item.id%type;
   --
begin
   --
   begin
      select it.id
        into vn_item_id
        from item it
       where it.empresa_id = en_empresa_id
         and it.cod_item   = upper(trim(ev_cod_item));
   exception
      when others then
         vn_item_id := null;
   end;
   --
   return vn_item_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_item_id:' || sqlerrm);
end fkg_item_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela Item, conforme ID Empresa

function fkg_Item_id_conf_empr ( en_empresa_id  in  empresa.id%type
                               , ev_cod_item    in  Item.cod_item%TYPE )
         return Item.id%TYPE
is

   vn_item_id            Item.id%TYPE;
   vn_empresa_id_matriz  empresa.id%type;

begin

   --
   begin
      --
      select i.id
        into vn_item_id
        from Item i
       where i.empresa_id  = en_empresa_id
         and i.cod_item    = upper(trim(ev_cod_item));
      --
   exception
      when others then
         vn_item_id := null;
   end;
   --
   if nvl(vn_item_id,0) <= 0 then
      --
      vn_empresa_id_matriz := fkg_empresa_id_matriz(en_empresa_id);
      --
      begin
         --
         select i.id
           into vn_item_id
           from Item i
          where i.empresa_id  = vn_empresa_id_matriz
            and i.cod_item    = upper(trim(ev_cod_item));
         --
      exception
         when others then
            vn_item_id := null;
      end;
      --
   end if;
   --
   if nvl(vn_item_id,0) <= 0 then
      --
      begin
         --
         select max(i.id)
           into vn_item_id
           from empresa e
              , Item i
          where e.ar_empresa_id  = en_empresa_id
            and i.empresa_id     = e.id
            and i.cod_item       = upper(trim(ev_cod_item));
         --
      exception
         when others then
            vn_item_id := null;
      end;
      --
   end if;
   --
   if nvl(vn_item_id,0) <= 0 then
      --
      begin
         --
         select max(i.id) into vn_item_id
           from empresa e
              , empresa e2
              , empresa e3
              , Item i
          where e.id              = en_empresa_id
            and e2.id             = e.ar_empresa_id
            and e3.ar_empresa_id  = e2.id
            and i.empresa_id      = e3.id
            and i.cod_item        = upper(trim(ev_cod_item));
         --
      exception
         when others then
            vn_item_id := null;
      end;
      --
   end if;
   --
   return vn_item_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Item_id_conf_empr:' || sqlerrm);
end fkg_Item_id_conf_empr;

-------------------------------------------------------------------------------------------------------
--| Função retorna o Tipo do CT-e conforme o Id do CT-e.
--| Onde: 0 - CT-e Normal;
--|       1 - CT-e de Complemento de Valores;
--|       2 - CT-e de Anulação de Valores;
--|       3 - CT-e Substituto

function fkg_dm_tp_cte ( en_conhectransp_id   in   Conhec_Transp.Id%TYPE )
         return Conhec_Transp.dm_tp_cte%TYPE
is

   vn_dm_tp_cte Conhec_Transp.dm_tp_cte%TYPE;

begin

   select dm_tp_cte
     into vn_dm_tp_cte
     from Conhec_Transp
    where id = en_conhectransp_id;

   return vn_dm_tp_cte;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_dm_tp_cte:' || sqlerrm);
end fkg_dm_tp_cte;

-------------------------------------------------------------------------------------------------------

--| Função retorna a data de emissão do conhecimento de transporte

function fkg_dt_emiss_ct ( en_conhectransp_id in Conhec_Transp.id%TYPE )
         return Conhec_Transp.dt_hr_emissao%TYPE
is

  vd_dt_emiss Conhec_Transp.dt_hr_emissao%TYPE;

begin

   if nvl(en_conhectransp_id,0) > 0 then

      select dt_hr_emissao
        into vd_dt_emiss
        from Conhec_Transp
       where id = en_conhectransp_id;

   end if;

   return vd_dt_emiss;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_dt_emiss_ct: ' || sqlerrm);
end fkg_dt_emiss_ct;

-------------------------------------------------------------------------------------------------------

--| Função retorna o valor de prestação do serviço através do ID do conhecimento de transporte

function fkg_vl_valor_prest_ct ( en_conhectransp_id in Conhec_Transp.id%TYPE )
         return Conhec_Transp_Vlprest.vl_prest_serv%TYPE
is

  vn_vl_prest_serv Conhec_Transp_Vlprest.vl_prest_serv%TYPE;

begin

   if nvl(en_conhectransp_id,0) > 0 then

      select vl_prest_serv
        into vn_vl_prest_serv
        from Conhec_Transp_Vlprest
       where conhectransp_id = en_conhectransp_id;

   end if;

   return vn_vl_prest_serv;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_vl_valor_prest_ct: ' || sqlerrm);
end fkg_vl_valor_prest_ct;

-------------------------------------------------------------------------------------------------------

--| Função retorna o valor de ICMS através do ID do conhecimento de transporte

function fkg_vl_imp_trib_ct ( en_conhectransp_id in Conhec_Transp.id%TYPE )
         return Conhec_Transp_Imp.vl_imp_trib%TYPE
is

  vn_vl_imp_trib Conhec_Transp_Imp.vl_imp_trib%TYPE;

begin

   if nvl(en_conhectransp_id,0) > 0 then

      select p.vl_imp_trib
        into vn_vl_imp_trib
        from Conhec_Transp_Imp p
           , Tipo_Imposto i
       where conhectransp_id = en_conhectransp_id
         and p.tipoimp_id    = i.id
         and i.sigla         = 'ICMS' ;

   end if;

   return vn_vl_imp_trib;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_vl_imp_trib_ct: ' || sqlerrm);
end fkg_vl_imp_trib_ct;

-------------------------------------------------------------------------------------------------------

--| Função retorna true se o Ct-e a ser Anulado ou Substituido já foi anulado ou substtuido anteriormente.

function fkg_val_ref_anul ( en_conhectransp_id in Conhec_Transp.id%TYPE
                          , ev_nro_chave_cte_anul in conhec_transp_anul.nro_chave_cte_anul%TYPE )
         return boolean
is

   vn_qtde_anul number;

begin
   vn_qtde_anul := null;
   -- Verifica se a chave de Anulação já foi anulada anteriormente.
   if nvl(en_conhectransp_id,0) > 0 and nvl(vn_qtde_anul, 0) = 0 then

      select 1
       into vn_qtde_anul
       from conhec_transp_anul a
          , conhec_transp p
      where a.nro_chave_cte_anul = ev_nro_chave_cte_anul
        and p.id <> en_conhectransp_id
        and p.dm_st_proc = 4
        and p.id = a.conhectransp_id;

      return true;

   end if;

   -- Verifica se a chave de Anulação já foi substituida anteriormente.
   if nvl(en_conhectransp_id,0) > 0 and nvl(vn_qtde_anul, 0) = 0 then

     select 1
       into vn_qtde_anul
       from conhec_transp_subst a
          , conhec_transp p
      where a.nro_chave_cte_sub = ev_nro_chave_cte_anul
        and p.id <> en_conhectransp_id
        and p.dm_st_proc = 4
        and p.id = a.conhectransp_id;

      return true;

   end if;

exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_val_ref_anul: ' || sqlerrm);
end fkg_val_ref_anul;

-------------------------------------------------------------------------------------------------------

-- Função retorna a Forma de emissão do CT-e a partir do ID.

function fkg_dmformaemiss_pelo_id ( en_conhectransp_id  in Conhec_Transp.id%TYPE )
         return Conhec_Transp.dm_forma_emiss%TYPE
is

   vn_dmformaemiss  Conhec_Transp.dm_forma_emiss%TYPE := null;

begin

   if en_conhectransp_id > 0 then
      --
      select dm_forma_emiss
        into vn_dmformaemiss
        from Conhec_Transp ct
       where id  = en_conhectransp_id;
      --
   end if;

   return vn_dmformaemiss;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_dmformaemiss_pelo_id:' || sqlerrm);
end fkg_dmformaemiss_pelo_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna true se o Ct-e a ser Substituido já foi substtuido anteriormente.

function fkg_val_ref_cte_sub ( en_conhectransp_id   in Conhec_Transp.id%TYPE
                             , ev_nro_chave_cte_sub in Conhec_Transp_Subst.nro_chave_cte_sub%TYPE )
         return boolean
is

   vn_qtde_sub number;

begin
   vn_qtde_sub := null;
   -- Verifica se a chave de Substiuição já foi Substituido anteriormente.
   if nvl(en_conhectransp_id,0) > 0 and nvl(vn_qtde_sub, 0) = 0 then

      select 1
       into vn_qtde_sub
       from conhec_transp_subst a
          , conhec_transp p
      where a.nro_chave_cte_sub = ev_nro_chave_cte_sub
        and p.id <> en_conhectransp_id
        and p.dm_st_proc = 4
        and p.id = a.conhectransp_id;

      return true;

   end if;

   -- Verifica se a chave de Substituição já foi anulada anteriormente.
   if nvl(en_conhectransp_id,0) > 0 and nvl(vn_qtde_sub, 0) = 0 then

     select 1
       into vn_qtde_sub
       from conhec_transp_subst a
          , conhec_transp p
          , conhec_transp_anul b
      where a.nro_chave_cte_sub = ev_nro_chave_cte_sub
        and p.id <> en_conhectransp_id
        and p.dm_st_proc = 4
        and b.nro_chave_cte_anul = a.nro_chave_cte_anul
        and p.id = b.conhectransp_id
        and p.id = a.conhectransp_id;

      return true;

   end if;

exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_val_ref_cte_sub: ' || sqlerrm);
end fkg_val_ref_cte_sub;

-------------------------------------------------------------------------------------------------------

--| Função retorna CNPJ do Remente/Destinatário/Expedidor/recebedor/tomador através do Id do Conhecimento de Transporte
--| E parametro vv_pessoa onde assumir: R - Remetente, D- Destinarario, E - Expedidor, RC - Recebedor, T - Tomador, EM - Emitente

function fkg_cnpj_pelo_id ( en_conhectransp_id  in Conhec_Transp.id%TYPE
                          , vv_pessoa varchar2 )
         return conhec_transp_rem.cnpj%TYPE
is

vn_cnpj_cpf conhec_transp_rem.cnpj%TYPE;

begin

   if nvl(en_conhectransp_id,0) > 0 and vv_pessoa in ('R', 'D', 'E', 'RC', 'T', 'EM') then

      if vv_pessoa = 'R' then
         --
         select trim(fkg_converte(decode(cnpj, null, cpf, cnpj)))
           into vn_cnpj_cpf
           from conhec_transp_rem
          where conhectransp_id = en_conhectransp_id;
         --
      elsif vv_pessoa = 'D' then
         --
         select trim(fkg_converte(decode(cnpj, null, cpf, cnpj)))
           into vn_cnpj_cpf
           from conhec_transp_dest
          where conhectransp_id = en_conhectransp_id;
         --
      elsif vv_pessoa = 'E' then
         --
         select trim(fkg_converte(decode(cnpj, null, cpf, cnpj)))
           into vn_cnpj_cpf
           from conhec_transp_exped
          where conhectransp_id = en_conhectransp_id;
         --
      elsif vv_pessoa = 'RC' then
         --
         select trim(fkg_converte(decode(cnpj, null, cpf, cnpj)))
           into vn_cnpj_cpf
           from conhec_transp_receb
          where conhectransp_id = en_conhectransp_id;
         --
      elsif vv_pessoa = 'T' then
         --
         select trim(fkg_converte(decode(cnpj, null, cpf, cnpj)))
           into vn_cnpj_cpf
           from conhec_transp_tomador
          where conhectransp_id = en_conhectransp_id;
         --
       elsif vv_pessoa = 'EM' then
         --
         select trim(fkg_converte(cnpj))
           into vn_cnpj_cpf
           from conhec_transp_emit
          where conhectransp_id = en_conhectransp_id;
         --
       end if;

   end if;

   return vn_cnpj_cpf;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cnpj_pelo_id: ' || sqlerrm);
end fkg_cnpj_pelo_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna IE do Remente/Destinatário/Expedidor/recebedor/tomador através do Id do Conhecimento de Transporte
--| E parametro vv_pessoa onde assumir: R - Remetente, D- Destinarario, E - Expedidor, RC - Recebedor, T - Tomador, EM - Emitente

function fkg_ie_pelo_id ( en_conhectransp_id  in Conhec_Transp.id%TYPE
                        , vv_pessoa varchar2 )
         return conhec_transp_rem.cnpj%TYPE
is

vn_ie conhec_transp_rem.ie%TYPE;

begin

   if nvl(en_conhectransp_id,0) > 0 and vv_pessoa in ('R', 'D', 'E', 'RC', 'T', 'EM') then

      if vv_pessoa = 'R' then
         --
         select trim(fkg_converte(ie))
           into vn_ie
           from conhec_transp_rem
          where conhectransp_id = en_conhectransp_id;
         --
      elsif vv_pessoa = 'D' then
         --
         select trim(fkg_converte(ie))
           into vn_ie
           from conhec_transp_dest
          where conhectransp_id = en_conhectransp_id;
         --
      elsif vv_pessoa = 'E' then
         --
         select trim(fkg_converte(ie))
           into vn_ie
           from conhec_transp_EXPED
          where conhectransp_id = en_conhectransp_id;
         --
      elsif vv_pessoa = 'RC' then
         --
         select trim(fkg_converte(ie))
           into vn_ie
           from conhec_transp_receb
          where conhectransp_id = en_conhectransp_id;
         --
      elsif vv_pessoa = 'T' then
         --
         select trim(fkg_converte(ie))
           into vn_ie
           from conhec_transp_tomador
          where conhectransp_id = en_conhectransp_id;
         --
      elsif vv_pessoa = 'EM' then
         --
         select trim(fkg_converte(ie))
           into vn_ie
           from conhec_transp_emit
          where conhectransp_id = en_conhectransp_id;
         --
      end if;

   end if;

   return vn_ie;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_ie_pelo_id: ' || sqlerrm);
end fkg_ie_pelo_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna UF de Início da Prestação do Ct-e através do Id do Conhecimento de Transporte

function fkg_siglaufini_pelo_id ( en_conhectransp_id  in Conhec_Transp.id%TYPE )
         return conhec_transp.sigla_uf_ini%TYPE
is

vv_sigla conhec_transp.sigla_uf_ini%TYPE;

begin

   if nvl(en_conhectransp_id,0) > 0 then

      select trim(fkg_converte(sigla_uf_ini))
        into vv_sigla
        from conhec_transp
       where id = en_conhectransp_id;

      return vv_sigla;

   end if;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_siglaufini_pelo_id: ' || sqlerrm);
end fkg_siglaufini_pelo_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna UF de Final da Prestação do Ct-e através do Id do Conhecimento de Transporte

function fkg_siglauffim_pelo_id ( en_conhectransp_id  in Conhec_Transp.id%TYPE )
         return conhec_transp.sigla_uf_fim%TYPE
is

vv_sigla conhec_transp.sigla_uf_fim%TYPE;

begin

   if nvl(en_conhectransp_id,0) > 0 then

      select sigla_uf_fim
        into vv_sigla
        from conhec_transp
       where id = en_conhectransp_id;

      return vv_sigla;

   end if;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_siglauffim_pelo_id: ' || sqlerrm);
end fkg_siglauffim_pelo_id;

-------------------------------------------------------------------------------------------------------

--| Se foi informado o Ct-e de Anulação no grupo "Tomador não é contribuinte de do ICMS", o Ct-e de anulação deve existir.
--| A função retorna True se existir e False se não existir

function fkg_val_ref_cte_anul ( en_conhectransp_id   in Conhec_Transp.id%TYPE
                              , ev_nro_chave_cte_anul in Conhec_Transp_anul.nro_chave_cte_anul%TYPE )
         return boolean
is

   vn_qtde_anul number;

begin

   if nvl(en_conhectransp_id,0) > 0 and ev_nro_chave_cte_anul is not null then

     select 1
       into vn_qtde_anul
       from conhec_transp p
          , conhec_transp_anul b
      where p.id = en_conhectransp_id
        and b.nro_chave_cte_anul = ev_nro_chave_cte_anul
        and p.id = b.conhectransp_id;

      return true;

   end if;

exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_val_ref_cte_anul: ' || sqlerrm);
end fkg_val_ref_cte_anul;

-------------------------------------------------------------------------------------------------------

--| Função retorna o Cód. IBGE do Estado conformer a sigla do Estado.

function fkg_Estado_ibge_sigla ( ev_sigla_estado  in Estado.sigla_estado%TYPE )
         return Estado.ibge_estado%TYPE
is

   vn_ibge_estado  Estado.ibge_estado%TYPE;

begin

   select ibge_estado
     into vn_ibge_estado
     from Estado
    where sigla_estado = ev_sigla_estado;

   return vn_ibge_estado;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Estado_ibge_sigla:' || sqlerrm);
end fkg_Estado_ibge_sigla;

-------------------------------------------------------------------------------------------------------
--| Verifica se a empresa Utiliza Endereço de Faturamento do destinatário na emissão da NFe
function fkg_empresa_util_end_fat_nfe ( en_empresa_id  in empresa.id%type )
         return empresa.dm_util_end_fat_nfe%type
is
   --
   vn_dm_util_end_fat_nfe empresa.dm_util_end_fat_nfe%type := 0;
   --
begin
   --
   if nvl(en_empresa_id,0) > 0 then
      --
      select e.dm_util_end_fat_nfe
        into vn_dm_util_end_fat_nfe
        from empresa e
       where e.id = en_empresa_id;
      --
   end if;
   --
   return nvl(vn_dm_util_end_fat_nfe,0);
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_util_end_fat_nfe:' || sqlerrm);
end fkg_empresa_util_end_fat_nfe;

-------------------------------------------------------------------------------------------------------

--| Verifica se a empresa imprime o endereço de entrega na DANFE
function fkg_empresa_impr_end_entr_nfe ( en_empresa_id  in empresa.id%type )
         return empresa.dm_impr_end_entr_nfe%type
is
   --
   vn_dm_impr_end_entr_nfe empresa.dm_impr_end_entr_nfe%type := null;
   --
begin
   --
   if nvl(en_empresa_id,0) > 0 then
      --
      select e.dm_impr_end_entr_nfe
        into vn_dm_impr_end_entr_nfe
        from empresa e
       where e.id = en_empresa_id;
      --
   end if;
   --
   return nvl(vn_dm_impr_end_entr_nfe,0);
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_impr_end_entr_nfe:' || sqlerrm);
end fkg_empresa_impr_end_entr_nfe;

-------------------------------------------------------------------------------------------------------

--| Verifica se a empresa imprime o endereço de Retirada na DANFE
function fkg_empresa_impr_end_retir_nfe ( en_empresa_id  in empresa.id%type )
         return empresa.dm_impr_end_entr_nfe%type
is
   --
   vn_dm_impr_end_retir_nfe  empresa.DM_IMPR_END_RETIR_NFE%type := null;
   --
begin
   --
   if nvl(en_empresa_id,0) > 0 then
      --
      select e.dm_impr_end_retir_nfe
        into vn_dm_impr_end_retir_nfe
        from empresa e
       where e.id = en_empresa_id;
      --
   end if;
   --
   return nvl(vn_dm_impr_end_retir_nfe,0);
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_impr_end_retir_nfe:' || sqlerrm);
end fkg_empresa_impr_end_retir_nfe;


-------------------------------------------------------------------------------------------------------

--| Verifica se a empresa valida a unidade de médida
function fkg_empresa_valid_unid_med ( en_empresa_id  in empresa.id%type )
         return empresa.dm_valid_unid_med%type
is
   --
   vn_dm_valid_unid_med empresa.dm_valid_unid_med%type := null;
   --
begin
   --
   if nvl(en_empresa_id,0) > 0 then
      --
      select e.dm_valid_unid_med
        into vn_dm_valid_unid_med
        from empresa e
       where e.id = en_empresa_id;
      --
   end if;
   --
   return nvl(vn_dm_valid_unid_med,0);
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_valid_unid_med:' || sqlerrm);
end fkg_empresa_valid_unid_med;

-------------------------------------------------------------------------------------------------------

--| Procedimento que acetar conforme o máximo ID de cada tabela

procedure pkb_acerta_sequence
is

   vv_sql varchar2(4000) := null;

   vv_id  number := 0;

   cursor c_seq_tab is
   select st.*
     from seq_tab st
    where st.table_name <> 'NOTA_FISCAL' -- Caso seja necessário atualizar a sequence da tabela nota_fiscal, o processo deverá ser específico e com atenção aos clientes de ERP/SGI.
    order by st.id;

begin
   --
   for rec in c_seq_tab loop
      --
      vv_id := 0;
      --
      vv_sql := 'select nvl(max(id), 0) from ' || rec.table_name;
      --
      begin
         execute immediate vv_sql into vv_id;
      exception
         when others then
            vv_id := 0;
      end;
      --
      if nvl(vv_id,0) > 0 then
         --
         vv_id := nvl(vv_id,0) + 1;
         --
         pb_arruma_seq ( sequence  => rec.sequence_name
                       , nro       => vv_id );
         --
      end if;
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pkb_acerta_sequence:' || sqlerrm || ' - vv_sql: ' || vv_sql);
end pkb_acerta_sequence;

-------------------------------------------------------------------------------------------------------

--| Função verifica se o objeto esta sendo utilizado na integração
-- retorna 0 caso não esteja
-- retorna 1 caso esteja

function fkg_existe_obj_util_integr ( ev_obj_name in obj_util_integr.obj_name%type )
         return obj_util_integr.dm_ativo%type
is

   vn_dm_ativo number := 0;

begin
   --
   if trim(ev_obj_name) is not null then
      --
      select dm_ativo
        into vn_dm_ativo
        from obj_util_integr
       where obj_name = trim(ev_obj_name);
      --
   end if;
   --
   return vn_dm_ativo;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_obj_util_integr:' || sqlerrm);
end fkg_existe_obj_util_integr;

-------------------------------------------------------------------------------------------------------

--| Função retorna 0 Se a empresa Não valida totais da Nota Fiscal
--| ou 1 Se e empresa valida totais da Nota Fiscal
function fkg_valid_total_nfe_empresa ( en_empresa_id in empresa.id%type )
         return empresa.dm_valid_total_nfe%type
is
   --
   vn_dm_valid_total_nfe  empresa.dm_valid_total_nfe%type := 0;
   --
begin
   --
   if nvl(en_empresa_id,0) > 0 then
      --
      select dm_valid_total_nfe
        into vn_dm_valid_total_nfe
        from empresa
       where id = en_empresa_id;
      --
   end if;
   --
   return nvl(vn_dm_valid_total_nfe,0);
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_valid_total_nfe_empresa:' || sqlerrm);
end fkg_valid_total_nfe_empresa;

-------------------------------------------------------------------------------------------------------

--| Função retorna a sitação da empresa: 0-Inativa ou 1-Ativa

function fkg_empresa_id_situacao ( en_empresa_id  in empresa.id%type )
         return empresa.dm_situacao%type
is
   --
   vn_dm_situacao empresa.dm_situacao%type := 0;
   --
begin
   --
   if nvl(en_empresa_id,0) > 0 then
      --
      select dm_situacao
        into vn_dm_situacao
        from empresa
       where id = en_empresa_id;
      --
   end if;
   --
   return vn_dm_situacao;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_id_situacao:' || sqlerrm);
end fkg_empresa_id_situacao;

-------------------------------------------------------------------------------------------------------

--| Função retorna a sitação da empresa: 0-Inativa ou 1-Ativa

function fkg_empresa_id_certificado_ok ( en_empresa_id  in empresa.id%type )
         return boolean
is
   --
   vn_dummy number := 0;
   --
   vn_dm_tp_cert         empresa.dm_tp_cert%type;
   vv_caminho_chave_jks  empresa.caminho_chave_jks%type;
   vv_senha_chave_jks    empresa.senha_chave_jks%type;
   vv_caminho_cert_pfx   empresa.caminho_cert_pfx%type;
   vv_senha_cert_pfx     empresa.senha_cert_pfx%type;
   --
begin
   --
   if nvl(en_empresa_id,0) > 0 then
      --
      select dm_tp_cert
           , caminho_chave_jks
           , senha_chave_jks
           , caminho_cert_pfx
           , senha_cert_pfx
        into vn_dm_tp_cert
           , vv_caminho_chave_jks
           , vv_senha_chave_jks
           , vv_caminho_cert_pfx
           , vv_senha_cert_pfx
        from empresa
       where id = en_empresa_id;
      --
      if vn_dm_tp_cert = 1 then -- A1
         --
         if trim(vv_caminho_chave_jks) is not null
            and trim(vv_senha_chave_jks) is not null
            and trim(vv_caminho_cert_pfx) is not null
            and trim(vv_senha_cert_pfx) is not null
            then
            --
            vn_dummy := 1;
            --
         else
            --
            vn_dummy := 0;
            --
         end if;
         --
      else
         --
         vn_dummy := 1;
         --
      end if;
      --
   end if;
   --
   return (vn_dummy = 1);
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_id_certificado_ok:' || sqlerrm);
end fkg_empresa_id_certificado_ok;

-------------------------------------------------------------------------------------------------------

--| Função retorna o tipo de inclusão da pessoa

function fkg_pessoa_id_dm_tipo_incl ( en_pessoa_id  in pessoa.id%type )
         return pessoa.dm_tipo_incl%type
is
   --
   vn_dm_tipo_incl pessoa.dm_tipo_incl%type := 1;
   --
begin
   --
   if nvl(en_pessoa_id,0) > 0 then
      --
      select p.dm_tipo_incl
        into vn_dm_tipo_incl
        from pessoa p
       where p.id = en_pessoa_id;
      --
   end if;
   --
   return vn_dm_tipo_incl;
   --
exception
   when no_data_found then
      return 1;
   when others then
      raise_application_error(-20101, 'Erro na fkg_pessoa_id_dm_tipo_incl:' || sqlerrm);
end fkg_pessoa_id_dm_tipo_incl;

-------------------------------------------------------------------------------------------------------

-- Função retorna "true" se o Código do IBGE da cidade pertente ao estado
-- e "false" se estiver incorreto
function fkg_ibge_cidade_por_sigla_uf ( en_ibge_cidade   in  cidade.ibge_cidade%type
                                      , ev_sigla_estado  in  estado.sigla_estado%type )
         return boolean
is
   --
   vn_dummy number := 0;
   --
begin
   --
   select distinct 1
     into vn_dummy
     from cidade c
        , estado e
    where c.ibge_cidade   = en_ibge_cidade
      and e.id            = c.estado_id
      and e.sigla_estado  = ev_sigla_estado;
   --
   return (vn_dummy = 1);
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_ibge_cidade_por_sigla_uf:' || sqlerrm);
end fkg_ibge_cidade_por_sigla_uf;

-------------------------------------------------------------------------------------------------------

-- Função retorna a Versão válida do WSDL da NFE
function fkg_versaowsdl_nfe_estado ( en_estado_id in estado.id%type )
         return versao_wsdl.cd%type
is

   vv_cd versao_wsdl.cd%type := null;

begin
   --
   if nvl(en_estado_id,0) > 0 then
      --
      select v.cd
        into vv_cd
        from versao_wsdl v
       where v.dm_situacao  = 1 -- ativo
         and v.dm_serv_util = 1 -- Nfe
         and exists ( select 1 from estado_versao_wsdl e
                       where e.estado_id = en_estado_id
                         and e.VERSAOWSDL_ID = v.id
                         and e.dm_situacao = 1 -- Ativo
                    );

      --
   end if;
   --
   return vv_cd;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_versaowsdl_nfe_estado:' || sqlerrm);
end fkg_versaowsdl_nfe_estado;

-------------------------------------------------------------------------------------------------------

--| Função retorna o Tipo Modal através do ID do Ct-e
--| Onde: 01-Rodoviário;
--| 02-Aéreo;
--| 03-Aquaviário;
--| 04-Ferroviário;
--| 05-Dutoviário
function fkg_dm_modal ( en_conhectransp_id   in   Conhec_Transp.Id%TYPE )
         return Conhec_Transp.dm_modal%TYPE
is

   vv_dm_modal Conhec_Transp.dm_modal%TYPE;

begin

   select dm_modal
     into vv_dm_modal
     from Conhec_Transp
    where id = en_conhectransp_id;

   return vv_dm_modal;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_dm_modal:' || sqlerrm);
end fkg_dm_modal;

-------------------------------------------------------------------------------------------------------
--| Função retorna True se existir informações referente a produtos perigosos.

function fkg_valid_prod_peri ( en_conhectransp_id   in   Conhec_Transp.Id%TYPE )
         return boolean
is

   vn_qtde_peri number := 0;

begin

   select count(1)
     into vn_qtde_peri
     from Conhec_Transp_Peri
    where id = en_conhectransp_id;

    if vn_qtde_peri = 1 then
       return true;
    else
       return false;
    end if;

exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_valid_prod_peri:' || sqlerrm);
end fkg_valid_prod_peri;

-------------------------------------------------------------------------------------------------------
--| Função retorna a quantidade de registros de lacres aquaviários por CT-e Aquaviário

function fkg_valid_lacre_aquav ( en_conhectranspaquav_id   in   conhec_transp_aquav.id%TYPE )
         return number
is

   vn_qtde_lac_aquav number := 0;

begin

   select count(1)
     into vn_qtde_lac_aquav
     from ctaquav_lacre
    where conhectranspaquav_id = en_conhectranspaquav_id;
    
    return vn_qtde_lac_aquav;
    
exception
   when no_data_found then
      return -1;
   when others then
      raise_application_error(-20101, 'Erro na fkg_valid_lacre_aquav:' || sqlerrm);
end fkg_valid_lacre_aquav;

-------------------------------------------------------------------------------------------------------
--| Função retorna a quantidade de registros de Ordens de Coleta associados ao CT-e Rodoviário

function fkg_valid_ctrodo_occ ( en_conhectransprodo_id in ctrodo_occ.conhectransprodo_id%TYPE )
         return number
is

   vn_qtde_ctrodo_occ number := 0;

begin

   select count(1)
     into vn_qtde_ctrodo_occ
     from ctrodo_occ
    where conhectransprodo_id = en_conhectransprodo_id;

   return vn_qtde_ctrodo_occ;

exception
   when no_data_found then
      return -1;
   when others then
      raise_application_error(-20101, 'Erro na fkg_valid_ctrodo_occ:' || sqlerrm);
end fkg_valid_ctrodo_occ;

-------------------------------------------------------------------------------------------------------
--| Função retorna a quantidade de registros de Dados dos Veículos ao CT-e Rodoviário

function fkg_valid_ctrodo_veic ( en_conhectransprodo_id in ctrodo_occ.conhectransprodo_id%TYPE )
         return number
is

   vn_qtde_ctrodo_veic number := 0;

begin

   select count(1)
     into vn_qtde_ctrodo_veic
     from Ctrodo_Veic
    where conhectransprodo_id = en_conhectransprodo_id;

   return vn_qtde_ctrodo_veic;

exception
   when no_data_found then
      return -1;
   when others then
      raise_application_error(-20101, 'Erro na fkg_valid_ctrodo_veic:' || sqlerrm);
end fkg_valid_ctrodo_veic;

-------------------------------------------------------------------------------------------------------
--| Função retorna a quantidade de registros de vale pedágio ao CT-e Rodoviário

function fkg_valid_ctrodo_valeped ( en_conhectransprodo_id in ctrodo_occ.conhectransprodo_id%TYPE )
         return number
is

   vn_qtde_ctrodo_valeped number := 0;

begin

   select count(1)
     into vn_qtde_ctrodo_valeped
     from Ctrodo_Valeped
    where conhectransprodo_id = en_conhectransprodo_id;

    return vn_qtde_ctrodo_valeped;

exception
   when no_data_found then
      return -1;
   when others then
      raise_application_error(-20101, 'Erro na fkg_valid_ctrodo_valeped:' || sqlerrm);
end fkg_valid_ctrodo_valeped;

-------------------------------------------------------------------------------------------------------
--| Função retorna True se existir informações sobre os veículos e False caso não houver.

function fkg_valid_ctrodo_veic_prop ( en_ctrodoveic_id in ctrodo_veic_prop.ctrodoveic_id%TYPE )
         return boolean
is

   vn_ctrodo_veic_prop number := 0;

begin

   select count(1)
     into vn_ctrodo_veic_prop
     from Ctrodo_Veic_Prop
    where ctrodoveic_id = en_ctrodoveic_id;

    if vn_ctrodo_veic_prop > 0 then
       return true;
    else
       return false;
    end if;

exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_valid_ctrodo_veic_prop:' || sqlerrm);
end fkg_valid_ctrodo_veic_prop;

-------------------------------------------------------------------------------------------------------
--| Função retorna True se existir informações no Grupo Informações do(s) Motorista(s)

function fkg_valid_ctrodo_moto ( en_conhectransprodo_id in ctrodo_moto.conhectransprodo_id%TYPE )
         return boolean
is

   vn_ctrodo_moto number := 0;

begin

   select count(1)
     into vn_ctrodo_moto
     from ctrodo_moto
    where conhectransprodo_id = en_conhectransprodo_id;

    if vn_ctrodo_moto > 0 then
       return true;
    else
       return false;
    end if;

exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_valid_ctrodo_moto:' || sqlerrm);
end fkg_valid_ctrodo_moto;

-------------------------------------------------------------------------------------------------------
--| Função retorna o tipo de serviço do conhecimento de transporte
--| Onde: 0 - Normal; 1 - Subcontratação; 2 - Redespacho; 3 - Redespacho Intermediario

function fkg_dm_tp_serv ( en_conhectransp_id in Conhec_Transp.id%TYPE )
         return Conhec_Transp.dm_tp_serv%TYPE
is

  vn_dm_tp_serv Conhec_Transp.dm_tp_serv%TYPE;

begin

   if nvl(en_conhectransp_id,0) > 0 then

      select dm_tp_serv
        into vn_dm_tp_serv
        from Conhec_Transp
       where id = en_conhectransp_id;

   end if;

   return vn_dm_tp_serv;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_dm_tp_serv: ' || sqlerrm);
end fkg_dm_tp_serv;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela registro_in86

function fkg_registroin86_id ( en_cd  in Registro_In86.cod%TYPE )
         return Registro_In86.id%TYPE
is

   vn_RegistroIn86_id  Registro_In86.id%TYPE;

begin

   select id
     into vn_RegistroIn86_id
     from Registro_In86
    where cod = trim(en_cd);

   return vn_RegistroIn86_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_registroin86_id:' || sqlerrm);
end fkg_registroin86_id;

-------------------------------------------------------------------------------------------------------
-- Função retorna cod_mod_ref através do dm_tp_cte e ID do CTE

function fkg_ct_ref_moddoc ( en_conhectransp_id  in Conhec_Transp.id%TYPE
                           , en_dm_tp_cte        in Conhec_Transp.dm_tp_cte%TYPE )
         return varchar2
is

   vv_cod_mod_ref   varchar2(2);

begin

   if en_dm_tp_cte = 0 then
      vv_cod_mod_ref := null;
   elsif en_dm_tp_cte = 1 then
      select doc.cd
        into vv_cod_mod_ref
        from conhec_transp p
           , sit_docto doc
           , pessoa pes
       where p.nro_chave_cte in (select o.nro_chave_cte_comp
                                   from conhec_transp_compltado o
                                  where o.conhectransp_id = en_conhectransp_id)
         and p.sitdocto_id = doc.id
         and p.pessoa_id =  pes.id(+);
   elsif en_dm_tp_cte = 2 then
      select doc.cd
        into vv_cod_mod_ref
        from conhec_transp p
           , sit_docto doc
           , pessoa pes
       where p.nro_chave_cte in (select anul.nro_chave_cte_anul
                                   from conhec_transp_anul anul
                                  where anul.conhectransp_id = en_conhectransp_id)
         and p.sitdocto_id = doc.id
         and p.pessoa_id =  pes.id(+);
   elsif en_dm_tp_cte = 3 then
      select doc.cd
        into vv_cod_mod_ref
        from conhec_transp p
           , sit_docto doc
           , pessoa pes
       where p.nro_chave_cte in (select subst.nro_chave_cte_sub
                                   from conhec_transp_subst subst
                                  where subst.conhectransp_id = en_conhectransp_id)
         and p.sitdocto_id = doc.id
         and p.pessoa_id =  pes.id(+);
   end if;

   return vv_cod_mod_ref;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_ct_ref_moddoc:' || sqlerrm);
end fkg_ct_ref_moddoc;

-------------------------------------------------------------------------------------------------------
-- Função retorna serie_ref através do dm_tp_cte e ID do CTE

function fkg_ct_ref_serie ( en_conhectransp_id  in Conhec_Transp.id%TYPE
                          , en_dm_tp_cte        in Conhec_Transp.dm_tp_cte%TYPE )
         return varchar2

is

   vc_serie_ref     varchar2(5);

begin

   if en_dm_tp_cte = 0 then
      vc_serie_ref  := null;
   elsif en_dm_tp_cte = 1 then
      select p.serie||p.subserie
        into vc_serie_ref
        from conhec_transp p
           , sit_docto doc
           , pessoa pes
       where p.nro_chave_cte in (select o.nro_chave_cte_comp
                                   from conhec_transp_compltado o
                                  where o.conhectransp_id = en_conhectransp_id)
         and p.sitdocto_id = doc.id
         and p.pessoa_id =  pes.id(+);
   elsif en_dm_tp_cte = 2 then
      select p.serie||p.subserie
        into vc_serie_ref
        from conhec_transp p
           , sit_docto doc
           , pessoa pes
       where p.nro_chave_cte in (select anul.nro_chave_cte_anul
                                   from conhec_transp_anul anul
                                  where anul.conhectransp_id = en_conhectransp_id)
         and p.sitdocto_id = doc.id
         and p.pessoa_id =  pes.id(+);
   elsif en_dm_tp_cte = 3 then
      select p.serie||p.subserie
        into vc_serie_ref
        from conhec_transp p
           , sit_docto doc
           , pessoa pes
       where p.nro_chave_cte in (select subst.nro_chave_cte_sub
                                   from conhec_transp_subst subst
                                  where subst.conhectransp_id = en_conhectransp_id)
         and p.sitdocto_id = doc.id
         and p.pessoa_id =  pes.id(+);
   end if;

   return vc_serie_ref;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_ct_ref_serie:' || sqlerrm);
end fkg_ct_ref_serie;

-------------------------------------------------------------------------------------------------------
-- Função retorna num_doc_ref, através do dm_tp_cte e ID do CTE

function fkg_ct_ref_nro_nf ( en_conhectransp_id  in Conhec_Transp.id%TYPE
                           , en_dm_tp_cte        in Conhec_Transp.dm_tp_cte%TYPE )
         return number

is

   vn_num_doc_ref   number(9);

begin

   if en_dm_tp_cte = 0 then
      vn_num_doc_ref  := null;
   elsif en_dm_tp_cte = 1 then
      select p.nro_ct
        into vn_num_doc_ref
        from conhec_transp p
           , sit_docto doc
           , pessoa pes
       where p.nro_chave_cte in (select o.nro_chave_cte_comp
                                   from conhec_transp_compltado o
                                  where o.conhectransp_id = en_conhectransp_id)
         and p.sitdocto_id = doc.id
         and p.pessoa_id =  pes.id(+);
   elsif en_dm_tp_cte = 2 then
      select p.nro_ct
        into vn_num_doc_ref
        from conhec_transp p
           , sit_docto doc
           , pessoa pes
       where p.nro_chave_cte in (select anul.nro_chave_cte_anul
                                   from conhec_transp_anul anul
                                  where anul.conhectransp_id = en_conhectransp_id)
         and p.sitdocto_id = doc.id
         and p.pessoa_id =  pes.id(+);
   elsif en_dm_tp_cte = 3 then
      select p.nro_ct
        into vn_num_doc_ref
        from conhec_transp p
           , sit_docto doc
           , pessoa pes
       where p.nro_chave_cte in (select subst.nro_chave_cte_sub
                                   from conhec_transp_subst subst
                                  where subst.conhectransp_id = en_conhectransp_id)
         and p.sitdocto_id = doc.id
         and p.pessoa_id =  pes.id(+);
   end if;

   return vn_num_doc_ref;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_ct_ref_nro_nf:' || sqlerrm);
end fkg_ct_ref_nro_nf;

-------------------------------------------------------------------------------------------------------
-- Função retorna dt_doc_ref através do dm_tp_cte e ID do CTE

function fkg_ct_ref_dtdoc ( en_conhectransp_id  in Conhec_Transp.id%TYPE
                        , en_dm_tp_cte        in Conhec_Transp.dm_tp_cte%TYPE)
         return date

is

   vd_dt_doc_ref  date;

begin

   if en_dm_tp_cte = 0 then
      vd_dt_doc_ref := null;
   elsif en_dm_tp_cte = 1 then
      select p.dt_hr_emissao
        into vd_dt_doc_ref
        from conhec_transp p
           , sit_docto doc
           , pessoa pes
       where p.nro_chave_cte in (select o.nro_chave_cte_comp
                                   from conhec_transp_compltado o
                                  where o.conhectransp_id = en_conhectransp_id)
         and p.sitdocto_id = doc.id
         and p.pessoa_id =  pes.id(+);
   elsif en_dm_tp_cte = 2 then
      select p.dt_hr_emissao
        into vd_dt_doc_ref
        from conhec_transp p
           , sit_docto doc
           , pessoa pes
       where p.nro_chave_cte in (select anul.nro_chave_cte_anul
                                   from conhec_transp_anul anul
                                  where anul.conhectransp_id = en_conhectransp_id)
         and p.sitdocto_id = doc.id
         and p.pessoa_id =  pes.id(+);
   elsif en_dm_tp_cte = 3 then
      select p.dt_hr_emissao
        into vd_dt_doc_ref
        from conhec_transp p
           , sit_docto doc
           , pessoa pes
       where p.nro_chave_cte in (select subst.nro_chave_cte_sub
                                   from conhec_transp_subst subst
                                  where subst.conhectransp_id = en_conhectransp_id)
         and p.sitdocto_id = doc.id
         and p.pessoa_id =  pes.id(+);
   end if;

   return vd_dt_doc_ref;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_ct_ref_dtdoc:' || sqlerrm);
end fkg_ct_ref_dtdoc;

-------------------------------------------------------------------------------------------------------
-- Função retorna cod_part_ref através do dm_tp_cte e ID do CTE

function fkg_ct_ref_codpart ( en_conhectransp_id  in Conhec_Transp.id%TYPE
                            , en_dm_tp_cte        in Conhec_Transp.dm_tp_cte%TYPE )
         return varchar2
is

   vc_cod_part_ref  varchar2(14);

begin

   if en_dm_tp_cte = 0 then
      vc_cod_part_ref := null;
   elsif en_dm_tp_cte = 1 then
      select pes.cod_part
        into vc_cod_part_ref
        from conhec_transp p
           , sit_docto doc
           , pessoa pes
       where p.nro_chave_cte in (select o.nro_chave_cte_comp
                                   from conhec_transp_compltado o
                                  where o.conhectransp_id = en_conhectransp_id)
         and p.sitdocto_id = doc.id
         and p.pessoa_id =  pes.id(+);
   elsif en_dm_tp_cte = 2 then
      select pes.cod_part
        into vc_cod_part_ref
        from conhec_transp p
           , sit_docto doc
           , pessoa pes
       where p.nro_chave_cte in (select anul.nro_chave_cte_anul
                                   from conhec_transp_anul anul
                                  where anul.conhectransp_id = en_conhectransp_id)
         and p.sitdocto_id = doc.id
         and p.pessoa_id =  pes.id(+);
   elsif en_dm_tp_cte = 3 then
      select pes.cod_part
        into vc_cod_part_ref
        from conhec_transp p
           , sit_docto doc
           , pessoa pes
       where p.nro_chave_cte in (select subst.nro_chave_cte_sub
                                   from conhec_transp_subst subst
                                  where subst.conhectransp_id = en_conhectransp_id)
         and p.sitdocto_id = doc.id
         and p.pessoa_id =  pes.id(+);
   end if;

   return vc_cod_part_ref;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_ct_ref_codpart:' || sqlerrm);
end fkg_ct_ref_codpart;

-------------------------------------------------------------------------------------------------------

-- Procedimento retornar dados do CTe referenciado, por meio de variáveis "out"

procedure pkb_dados_ct_ref ( en_conhectransp_id  in   Conhec_Transp.id%TYPE
                           , en_dm_tp_cte        in   Conhec_Transp.dm_tp_cte%TYPE
                           , sv_cod_mod_ref      out  mod_fiscal.cod_mod%type
                           , sv_serie            out  conhec_transp.serie%type
                           , sn_nro_ct           out  conhec_transp.nro_ct%type
                           , sd_dt_hr_emissao    out  conhec_transp.dt_hr_emissao%type
                           , sv_cod_part         out  pessoa.cod_part%type
                           )
is
   --
   vv_cod_mod_ref    mod_fiscal.cod_mod%type;
   vv_serie          conhec_transp.serie%type;
   vn_nro_ct         conhec_transp.nro_ct%type;
   vd_dt_hr_emissao  conhec_transp.dt_hr_emissao%type;
   vv_cod_part       pessoa.cod_part%type;
   --
begin
   --
   if en_dm_tp_cte = 0 then       -- CT-e Normal
      --
      vv_cod_mod_ref    := null;
      vv_serie          := null;
      vn_nro_ct         := null;
      vd_dt_hr_emissao  := null;
      vv_cod_part       := null;
      --
   elsif en_dm_tp_cte = 1 then    -- CT-e de Complemento de Valores
      --
      begin
         --
         select mf.cod_mod
              , ct.serie
              , ct.nro_ct
              , ct.dt_hr_emissao
              , p.cod_part
           into vv_cod_mod_ref
              , vv_serie
              , vn_nro_ct
              , vd_dt_hr_emissao
              , vv_cod_part
           from conhec_transp ct
              , mod_fiscal    mf
              , pessoa        p
          where ct.nro_chave_cte in (select ctc.nro_chave_cte_comp
                                       from conhec_transp_compltado ctc
                                      where ctc.conhectransp_id = en_conhectransp_id)
            and mf.id         = ct.modfiscal_id
            and p.id(+)       = ct.pessoa_id;
          --
      exception
         when others then
            vv_cod_mod_ref    := null;
            vv_serie          := null;
            vn_nro_ct         := null;
            vd_dt_hr_emissao  := null;
            vv_cod_part       := null;
      end;
      --
   elsif en_dm_tp_cte = 2 then    -- CT-e de Anulação de Valores
      --
      begin
         --
         select mf.cod_mod
              , ct.serie
              , ct.nro_ct
              , ct.dt_hr_emissao
              , p.cod_part
           into vv_cod_mod_ref
              , vv_serie
              , vn_nro_ct
              , vd_dt_hr_emissao
              , vv_cod_part
           from conhec_transp ct
              , mod_fiscal    mf
              , pessoa        p
          where ct.nro_chave_cte in (select anul.nro_chave_cte_anul
                                       from conhec_transp_anul anul
                                      where anul.conhectransp_id = en_conhectransp_id)
            and mf.id         = ct.modfiscal_id
            and p.id(+)       = ct.pessoa_id;
          --
      exception
         when others then
            vv_cod_mod_ref    := null;
            vv_serie          := null;
            vn_nro_ct         := null;
            vd_dt_hr_emissao  := null;
            vv_cod_part       := null;
      end;
      --
   elsif en_dm_tp_cte = 3 then    -- CT-e Substituto
      --
      begin
         --
         select mf.cod_mod
              , ct.serie
              , ct.nro_ct
              , ct.dt_hr_emissao
              , p.cod_part
           into vv_cod_mod_ref
              , vv_serie
              , vn_nro_ct
              , vd_dt_hr_emissao
              , vv_cod_part
           from conhec_transp ct
              , mod_fiscal    mf
              , pessoa        p
          where ct.nro_chave_cte in (select subst.nro_chave_cte_sub
                                       from conhec_transp_subst subst
                                      where subst.conhectransp_id = en_conhectransp_id)
            and mf.id         = ct.modfiscal_id
            and p.id(+)       = ct.pessoa_id;
          --
      exception
         when others then
            vv_cod_mod_ref    := null;
            vv_serie          := null;
            vn_nro_ct         := null;
            vd_dt_hr_emissao  := null;
            vv_cod_part       := null;
      end;
      --
   end if;
   --
   sv_cod_mod_ref      := vv_cod_mod_ref;
   sv_serie            := vv_serie;
   sn_nro_ct           := vn_nro_ct;
   sd_dt_hr_emissao    := vd_dt_hr_emissao;
   sv_cod_part         := vv_cod_part;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pkb_dados_ct_ref:' || sqlerrm);
end pkb_dados_ct_ref;

-------------------------------------------------------------------------------------------------------
--| Função para formatar campos varchar2
--| Onde: ev_campo é o contéudo que será formatado
--|       en_qtdecasa é a quantidade de casas
--|       ev_caracter o tipo de caracte
--|       ev_lado é o lado utilizar 'D'para direita e 'E' para esquerda

function fkg_formatachar ( ev_campo    in varchar2
                         , ev_caracter in varchar2
                         , en_qtdecasa in number
                         , ev_lado     in varchar2 )
         return varchar2
is

   vv_campoform varchar2(4000) := null;
   vv_campo     varchar2(4000);

begin

   if ev_caracter is not null
      and nvl(en_qtdecasa, 0) > 0 then
         --
         if trim(ev_campo) is null then
            vv_campo := ev_caracter;
         else
            vv_campo := ev_campo;
            --
         end if;
         --
         if ev_lado = 'D' then
         --
            select rpad(nvl(vv_campo, ' '), en_qtdecasa, ev_caracter)
            into vv_campoform
            from dual;
            --
         elsif ev_lado = 'E' then
            --
            select lpad(nvl(vv_campo, ' '), en_qtdecasa, ev_caracter)
            into vv_campoform
            from dual;
         end if;
         --
   end if;

   return vv_campoform;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_formatachar:' || sqlerrm);
end fkg_formatachar;

-------------------------------------------------------------------------------------------------------
--| Procedimento para retornar valores de Impostos na tabela IMP_NOTA_FISCAL

procedure pkb_impostonf ( en_itemnf_id             in  item_nota_fiscal.id%type
                        , en_cod_tpimp             in  tipo_imposto.cd%type
                        , en_dm_tipo               in  imp_itemnf.dm_tipo%type
                        , sv_cod_st                out cod_st.cod_st%type
                        , sn_vl_base_calc          out imp_itemnf.vl_base_calc%type
                        , sn_aliq_apli             out imp_itemnf.aliq_apli%type
                        , sn_vl_imp_trib           out imp_itemnf.vl_imp_trib%type
                        , sn_perc_reduc            out imp_itemnf.perc_reduc%type
                        , sn_perc_adic             out imp_itemnf.perc_adic%type
                        , sn_qtde_base_calc_prod   out imp_itemnf.qtde_base_calc_prod%type
                        , sn_vl_aliq_prod          out imp_itemnf.vl_aliq_prod%type
                        , sn_vl_bc_st_ret          out imp_itemnf.vl_bc_st_ret%type
                        , sn_vl_icmsst_ret         out imp_itemnf.vl_icmsst_ret%type
                        , sn_perc_bc_oper_prop     out imp_itemnf.perc_bc_oper_prop%type
                        , sv_sigla_estado          out estado.sigla_estado%type
                        , sn_vl_bc_st_dest         out imp_itemnf.vl_bc_st_dest%type
                        , sn_vl_icmsst_dest        out imp_itemnf.vl_icmsst_dest%type
                        )
is

begin

   if nvl(en_itemnf_id, 0) > 0
      and nvl(en_cod_tpimp,0) > 0
      and nvl(en_dm_tipo, 0) in (0,1)
      then
      --
      begin
         --
         select cst.cod_st
              , iinf.vl_base_calc
              , iinf.aliq_apli
              , iinf.vl_imp_trib
              , iinf.perc_reduc
              , iinf.perc_adic
              , iinf.qtde_base_calc_prod
              , iinf.vl_aliq_prod
              , iinf.vl_bc_st_ret
              , iinf.vl_icmsst_ret
              , iinf.perc_bc_oper_prop
              , e.sigla_estado
              , iinf.vl_bc_st_dest
              , iinf.vl_icmsst_dest
           into sv_cod_st
              , sn_vl_base_calc
              , sn_aliq_apli
              , sn_vl_imp_trib
              , sn_perc_reduc
              , sn_perc_adic
              , sn_qtde_base_calc_prod
              , sn_vl_aliq_prod
              , sn_vl_bc_st_ret
              , sn_vl_icmsst_ret
              , sn_perc_bc_oper_prop
              , sv_sigla_estado
              , sn_vl_bc_st_dest
              , sn_vl_icmsst_dest
           from imp_itemnf       iinf
              , tipo_imposto     ti
              , cod_st           cst
              , estado           e
          where iinf.itemnf_id   = en_itemnf_id
            and iinf.dm_tipo     = nvl(en_dm_tipo, 0)
            and ti.id            = iinf.tipoimp_id
            and ti.cd            = en_cod_tpimp
            and cst.id(+)        = iinf.codst_id
            and e.id(+)          = iinf.estado_id;
         --
      exception
         when others then
            sv_cod_st                := null;
            sn_vl_base_calc          := null;
            sn_aliq_apli             := null;
            sn_vl_imp_trib           := null;
            sn_perc_reduc            := null;
            sn_perc_adic             := null;
            sn_qtde_base_calc_prod   := null;
            sn_vl_aliq_prod          := null;
            sn_vl_bc_st_ret          := null;
            sn_vl_icmsst_ret         := null;
            sn_perc_bc_oper_prop     := null;
            sv_sigla_estado          := null;
            sn_vl_bc_st_dest         := null;
            sn_vl_icmsst_dest        := null;
      end;
      --
   end if;

exception
   when others then
      raise_application_error(-20101, 'Erro na pkb_impostonf:' || sqlerrm);
end pkb_impostonf;

-------------------------------------------------------------------------------------------------------
--| Procedimento para retornar valores de Impostos na tabela CONHEC_TRANSP_IMP

procedure pkb_impostoct ( en_conhectransp_id       in  conhec_transp.id%TYPE
                        , en_cod_tpimp             in  tipo_imposto.cd%type
                        , sv_cod_st                out cod_st.cod_st%type
                        , sn_vl_base_calc          out conhec_transp_imp.vl_base_calc%type
                        , sn_aliq_apli             out conhec_transp_imp.aliq_apli%type
                        , sn_vl_imp_trib           out conhec_transp_imp.vl_imp_trib%type
                        , sn_perc_reduc            out conhec_transp_imp.perc_reduc%type
                        , sn_vl_cred               out conhec_transp_imp.vl_cred%type
                        , sn_dm_inf_imp            out conhec_transp_imp.dm_inf_imp%type
                        )
is

begin

   if nvl(en_conhectransp_id, 0) > 0
      and nvl(en_cod_tpimp,0) > 0
      then
      --
      begin
         --
         select cst.cod_st
              , cti.VL_BASE_CALC
              , cti.ALIQ_APLI
              , cti.VL_IMP_TRIB
              , cti.PERC_REDUC
              , cti.VL_CRED
              , cti.DM_INF_IMP
           into sv_cod_st
              , sn_vl_base_calc
              , sn_aliq_apli
              , sn_vl_imp_trib
              , sn_perc_reduc
              , sn_vl_cred
              , sn_dm_inf_imp
           from conhec_transp_imp    cti
              , tipo_imposto         ti
              , cod_st               cst
          where cti.conhectransp_id  = en_conhectransp_id
            and ti.id                = cti.tipoimp_id
            and cst.id(+)            = cti.codst_id;
         --
      exception
         when others then
            sv_cod_st         := null;
            sn_vl_base_calc   := null;
            sn_aliq_apli      := null;
            sn_vl_imp_trib    := null;
            sn_perc_reduc     := null;
            sn_vl_cred        := null;
            sn_dm_inf_imp     := null;
      end;
      --
   end if;

exception
   when others then
      raise_application_error(-20101, 'Erro na pkb_impostoct:' || sqlerrm);
end pkb_impostoct;

-------------------------------------------------------------------------------------------------------
-- Função retorna DM_TIPO_PESSOA da tabela pessoa através do ID pessoa

function fkg_pessoa_dmtipo_id ( en_pessoa_id  in Pessoa.id%TYPE )
         return Pessoa.dm_tipo_pessoa%TYPE
is

   vn_dm_tipo_pessoa Pessoa.dm_tipo_pessoa%TYPE := null;

begin

   if en_pessoa_id is not null then

      select p.dm_tipo_pessoa
        into vn_dm_tipo_pessoa
        from Pessoa  p
       where p.id = en_pessoa_id;

   end if;

   return vn_dm_tipo_pessoa;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_pessoa_dmtipo_id: ' || sqlerrm);
end fkg_pessoa_dmtipo_id;

-------------------------------------------------------------------------------------------------------
--| Função retorna o IEST conforme o ID da pessoa

function fkg_iest_pessoa_id ( en_pessoa_id in Pessoa.Id%type )
         return varchar2
is

   vv_iest varchar2(14) := null;
   vn_tipo_pessoa number(1) := null;

begin
   --
   if nvl(en_pessoa_id, 0) > 0 then
      --
      select dm_tipo_pessoa
        into vn_tipo_pessoa
        from pessoa
       where id = en_pessoa_id;

      if vn_tipo_pessoa = 0 then
         vv_iest := 'ISENTO';
      elsif vn_tipo_pessoa = 1 then
         select iest
           into vv_iest
           from juridica
          where pessoa_id = en_pessoa_id;
      elsif vn_tipo_pessoa = 3 then
         vv_iest := null;
      end if;
      --
   end if;
   --
   return vv_iest;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_iest_pessoa_id:' || sqlerrm);
end fkg_iest_pessoa_id;

-------------------------------------------------------------------------------------------------------
--| Função retorna o cod_participante pelo id_empresa
--| Função retorna o código da empresa através do id empresa em que está relacionado.

function fkg_codpart_empresaid ( en_empresa_id in Empresa.Id%type )
         return varchar2
is

   vv_cod_part varchar2(60) := null;


begin
   --
   if nvl(en_empresa_id, 0) > 0 then
      --
      select p.cod_part
        into vv_cod_part
        from empresa e
           , pessoa p
       where e.pessoa_id = p.id
         and e.id = en_empresa_id;
      --
   end if;
   --
   return vv_cod_part;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_codpart_empresaid:' || sqlerrm);
end fkg_codpart_empresaid;

-------------------------------------------------------------------------------------------------------
-- Função retorna o Cod da tabela Mod_Fiscal através do id

function fkg_cod_mod_id ( en_modfiscal_id  in Mod_Fiscal.id%TYPE )
         return Mod_Fiscal.cod_mod%TYPE
is

   vv_cod_mod  Mod_Fiscal.cod_mod%TYPE;

begin

   select cod_mod
     into vv_cod_mod
     from Mod_Fiscal
    where id = en_modfiscal_id;

   return vv_cod_mod;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_cod_mod_id:' || sqlerrm);
end fkg_cod_mod_id;

-------------------------------------------------------------------------------------------------------
--| Função retorna cod_nat pelo ID da NAT_oper

function fkg_cod_nat_id ( en_natoper_id  in Nat_Oper.id%TYPE )
         return Nat_Oper.cod_nat%TYPE
is

  vv_cod_nat  Nat_Oper.cod_nat%TYPE := null;

begin

   if nvl(en_natoper_id, 0) > 0 then

      select cod_nat
        into vv_cod_nat
        from Nat_Oper
       where id = en_natoper_id;

   end if;

   return vv_cod_nat;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cod_nat_id: ' || sqlerrm);
end fkg_cod_nat_id;

-------------------------------------------------------------------------------------------------------
-- Função retorna o cod_ncm através do ID NCM

function fkg_cod_ncm_id ( en_ncm_id  in Ncm.id%TYPE )
         return Ncm.cod_ncm%TYPE
is

   vv_cod_ncm  Ncm.cod_ncm%TYPE;

begin

   select cod_ncm
     into vv_cod_ncm
     from Ncm
    where id = en_ncm_id;

   return vv_cod_ncm;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_cod_ncm_id(' || vv_cod_ncm || '):' || sqlerrm);
end fkg_cod_ncm_id;

-------------------------------------------------------------------------------------------------------
-- Função retorna o tpservico_id através relacionado a tabela item através do código do item

function fkg_Item_tpservico_conf_empr ( en_empresa_id  in  empresa.id%type
                                      , ev_cod_item    in  Item.cod_item%TYPE )
         return Item.tpservico_id%TYPE
is

   vn_tpservico_id Item.tpservico_id%TYPE := null;

   vn_empresa_id_matriz empresa.id%type;

begin
   --
   begin
      --
      select tpservico_id
        into vn_tpservico_id
        from Item
       where empresa_id  = en_empresa_id
         and cod_item    = upper(trim(ev_cod_item));
      --
   exception
      when others then
         vn_tpservico_id := null;
   end;

   if nvl(vn_tpservico_id,0) <= 0 then
      --
      vn_empresa_id_matriz := fkg_empresa_id_matriz(en_empresa_id);
      --
      begin
         --
         select tpservico_id
           into vn_tpservico_id
           from Item
          where empresa_id  = vn_empresa_id_matriz
            and cod_item    = upper(trim(ev_cod_item));
         --
      exception
         when others then
            vn_tpservico_id := null;
      end;
      --
   end if;

   return vn_tpservico_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Item_tpservico_conf_empr:' || sqlerrm);
end fkg_Item_tpservico_conf_empr;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Cod do Serviço através do ID da tabela Tipo_Servico

function fkg_Tipo_Servico_cod ( en_tpservico_id  in Tipo_Servico.id%TYPE )
         return Tipo_Servico.cod_lst%TYPE
is

   vv_cod_lst Tipo_Servico.cod_lst%TYPE;

begin

   select cod_lst
     into vv_cod_lst
     from Tipo_Servico
    where id = en_tpservico_id;

   return vv_cod_lst;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Tipo_Servico_cod:' || sqlerrm);
end fkg_Tipo_Servico_cod;

-------------------------------------------------------------------------------------------------------
-- Função retorna a Desc do Serviço através do ID da tabela Tipo_Servico

function fkg_Tipo_Servico_desc ( en_tpservico_id  in Tipo_Servico.id%TYPE )
         return Tipo_Servico.descr%TYPE
is

   vv_descr Tipo_Servico.descr%TYPE;

begin

   select descr
     into vv_descr
     from Tipo_Servico
    where id = en_tpservico_id;

   return vv_descr;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Tipo_Servico_desc:' || sqlerrm);
end fkg_Tipo_Servico_desc;

-------------------------------------------------------------------------------------------------------
-- Função retorna a Data de Inclusão da tabela alter_pessoa através do Pessoa_id

function fkg_dt_alt_pessoa_id ( en_pessoa_id  in Pessoa.id%TYPE
                              , ed_data       in date )
         return alter_pessoa.dt_alt%TYPE
is

   vd_dt_alt alter_pessoa.dt_alt%TYPE := null;

begin

   if nvl(en_pessoa_id, 0) > 0 and ed_data is not null then
   --
      select nvl(max(a.dt_alt), ed_data)
        into vd_dt_alt
        from alter_pessoa a
       where a.pessoa_id = en_pessoa_id
         and a.dt_alt <= ed_data;
   --
   end if;

   return vd_dt_alt;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_dt_alt_pessoa_id:' || sqlerrm);
end fkg_dt_alt_pessoa_id;

-------------------------------------------------------------------------------------------------------
-- Função retorna a Data de Inclusão da tabela alter_item através do item_id

function fkg_dt_alt_item_id ( en_item_id  in Item.id%TYPE
                            , ed_data     in date )
         return alter_item.dt_ini%TYPE
is

   vd_dt_alt alter_item.dt_ini%TYPE := null;

begin

   if nvl(en_item_id, 0) > 0 and ed_data is not null then
      --
      select nvl(max(a.dt_ini), ed_data)
        into vd_dt_alt
        from alter_item a
       where a.item_id = en_item_id
        and a.dt_ini <= ed_data;
      --
   end if;

   return vd_dt_alt;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_dt_alt_item_id:' || sqlerrm);
end fkg_dt_alt_item_id;

-------------------------------------------------------------------------------------------------------
-- Função retorna o código da versão da In que será exportada. Através do ID  disponibilizado na abertura_in86

function fkg_cod_in86_id ( en_versaoin86_id  in versao_in86.id%TYPE)
         return versao_in86.cd%TYPE
is

   vv_cod_in86 versao_in86.cd%TYPE := null;

begin

   if nvl(en_versaoin86_id, 0) > 0 then
   --
      select cd
        into vv_cod_in86
        from versao_in86 a
       where a.id = en_versaoin86_id;
   --
   end if;

   return vv_cod_in86;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_cod_in86_id:' || sqlerrm);
end fkg_cod_in86_id;

-------------------------------------------------------------------------------------------------------
 --| Função retorna o CNPJ ou CPF conforme o ID da pessoa

function fkg_cnpjcpf_pessoa_id ( en_pessoa_id in Pessoa.Id%type )
         return varchar2
is

   vv_cnpj_cpf varchar2(14) := null;

begin
   --
   if nvl(en_pessoa_id, 0) > 0 then
      --
      begin
         --
         select ( lpad(j.NUM_CNPJ, 8, '0') || lpad(j.NUM_FILIAL, 4, '0') || lpad(j.DIG_CNPJ, 2, '0') ) cnpj_cpf
           into vv_cnpj_cpf
           from juridica j
          where j.pessoa_id = en_pessoa_id;
         --
      exception
         when others then
            vv_cnpj_cpf := null;
      end;
      --
      if trim(vv_cnpj_cpf) is null then
         --
         begin
            --
            select ( lpad(f.NUM_CPF, 9, '0') || lpad(f.DIG_CPF, 2, '0') ) cnpj_cpf
              into vv_cnpj_cpf
              from fisica f
             where f.pessoa_id = en_pessoa_id;
            --
         exception
            when others then
               vv_cnpj_cpf := null;
         end;
         --
      end if;
      --
   end if;
   --
   return vv_cnpj_cpf;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cnpjcpf_pessoa_id:' || sqlerrm);
end fkg_cnpjcpf_pessoa_id;

-------------------------------------------------------------------------------------------------------
 --| Função retorna o sigla_estado que está relacionado ao pessoa_id

function fkg_siglaestado_pessoaid ( en_pessoa_id in Pessoa.Id%type )
         return varchar2
is
   --
   vv_sigla_estado varchar2(2) := null;
   --
begin
   --
   if nvl(en_pessoa_id, 0) > 0 then
      --
      select c.sigla_estado
        into vv_sigla_estado
        from pessoa a
           , cidade b
           , estado c
       where a.id = en_pessoa_id
         and a.cidade_id = b.id
         and b.estado_id = c.id;
      --
   end if;
   --
   return vv_sigla_estado;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_siglaestado_pessoaid:' || sqlerrm);
end fkg_siglaestado_pessoaid;

-------------------------------------------------------------------------------------------------------
--| Função retorna o Inscrição Estadual conforme o ID da pessoa

function fkg_ie_pessoa_id ( en_pessoa_id in Pessoa.Id%type )
         return varchar2
is

   vv_ie varchar2(14) := null;
   vn_tipo_pessoa number(1) := null;

begin
   --
   if nvl(en_pessoa_id, 0) > 0 then
      --
      select dm_tipo_pessoa
        into vn_tipo_pessoa
        from pessoa
       where id = en_pessoa_id;

      if vn_tipo_pessoa = 0 then
         vv_ie := 'ISENTO';
      elsif vn_tipo_pessoa = 1 then
         select ie
           into vv_ie
           from juridica
          where pessoa_id = en_pessoa_id;
      elsif vn_tipo_pessoa = 2 then
         vv_ie := null;
      end if;
      --
   end if;
   --
   return vv_ie;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_ie_pessoa_id:' || sqlerrm);
end fkg_ie_pessoa_id;

-------------------------------------------------------------------------------------------------------

--| função retornar o valor do campo DM_PERM_EXP ID do País.
function fkg_perm_exp_pais_id  ( en_pais_id in pais.id%type )
         return pais.dm_perm_exp%type
is

   vn_dm_perm_exp pais.dm_perm_exp%type := 1;

begin
   --
   if nvl(en_pais_id, 0) > 0 then
      --
      select u.dm_perm_exp
        into vn_dm_perm_exp
        from pais u
       where u.id = en_pais_id;
      --
   end if;
   --
   return vn_dm_perm_exp;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_perm_exp_pais_id:' || sqlerrm);
end fkg_perm_exp_pais_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna 0 Se a empresa Não valida totais entre as duplicatas, cobraçãs e total da Nota Fiscal
--| ou 1 Se e empresa valida totais entre as duplicatas, cobraçãs e total da Nota Fiscal
function fkg_valid_cobr_nf_empresa ( en_empresa_id in empresa.id%type )
         return empresa.dm_valid_cobr_nf%type
is
   --
   vn_dm_valid_cobr_nf  empresa.dm_valid_cobr_nf%type := 0;
   --
begin
   --
   if nvl(en_empresa_id,0) > 0 then
      --
      select dm_valid_cobr_nf
        into vn_dm_valid_cobr_nf
        from empresa
       where id = en_empresa_id;
      --
   end if;
   --
   return nvl(vn_dm_valid_cobr_nf,0);
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_valid_cobr_nf_empresa:' || sqlerrm);
end fkg_valid_cobr_nf_empresa;

-------------------------------------------------------------------------------------------------------
--| Função retorna o id da empresa através do ID da Nota Fiscal
function fkg_busca_empresa_nf ( en_notafiscal_id in Nota_Fiscal.id%type )
         return Empresa.id%type
is
   --
   vn_empresa_id  empresa.id%type := 0;
   --
begin
   --
   if nvl(en_notafiscal_id,0) > 0 then
      --
      select empresa_id
        into vn_empresa_id
        from nota_fiscal
       where id = en_notafiscal_id;
      --
   end if;
   --
   return vn_empresa_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_busca_empresa_nf:' || sqlerrm);
end fkg_busca_empresa_nf;

-------------------------------------------------------------------------------------------------------

--| Função retorna o id_erp do usuário através do ID do usuário
function fkg_id_erp_usuario_id ( en_usuario_id in neo_usuario.id%type )
         return neo_usuario.id_erp%type
is

   vv_id_erp neo_usuario.id_erp%type := null;

begin
   --
   if nvl(en_usuario_id, 0) > 0 then
      --
      select u.id_erp
        into vv_id_erp
        from neo_usuario u
       where u.id = en_usuario_id;
      --
   end if;
   --
   return vv_id_erp;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_id_erp_usuario_id:' || sqlerrm);
end fkg_id_erp_usuario_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o cd do Cfop

function fkg_cfop_cd ( en_cfop_id  in Cfop.id%TYPE )
         return Cfop.cd%TYPE
is

   vn_cfop_cd Cfop.cd%TYPE := null;

begin

   select cd
     into vn_cfop_cd
     from Cfop
    where id = en_cfop_id;

   return vn_cfop_cd;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cfop_cd:' || sqlerrm);
end fkg_cfop_cd;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Plano de Conta
/*
function fkg_Plano_Conta_id ( ev_cod_cta    in Plano_Conta.cod_cta%TYPE
                            , en_empresa_id in Plano_Conta.empresa_id%TYPE)
         return Plano_Conta.id%TYPE
is

   vn_planoconta_id Tipo_Servico.id%TYPE;

   vn_empresa_id_matriz empresa.id%type;

begin
   --
   vn_empresa_id_matriz := fkg_empresa_id_matriz(en_empresa_id);
   --
   if trim(ev_cod_cta) is not null and
      nvl(en_empresa_id, 0) > 0 then
      --
      begin
         select id
           into vn_planoconta_id
           from Plano_Conta
          where trim(replace(cod_cta, '.', '')) = trim(replace(ev_cod_cta, '.', ''))
            and empresa_id = en_empresa_id;
      exception
         when no_data_found then
            vn_planoconta_id := null;
         when others then
            raise_application_error(-20101, 'Problemas ao recuperar identificador do plano de contas (cod='||ev_cod_cta||' empresa_id='||en_empresa_id||
                                            '). Erro = '||sqlerrm);
      end;
      --
      if vn_planoconta_id is null and -- recuperar da empresa matriz
         nvl(vn_empresa_id_matriz,0) > 0 then
         --
         begin
            select id
              into vn_planoconta_id
              from Plano_Conta
             where trim(replace(cod_cta, '.', '')) = trim(replace(ev_cod_cta, '.', ''))
               and empresa_id = vn_empresa_id_matriz;
         exception
            when no_data_found then
               vn_planoconta_id := null;
            when others then
               raise_application_error(-20101, 'Problemas ao recuperar identificador do plano de contas (cod='||ev_cod_cta||' matriz_empresa_id='||
                                               en_empresa_id||'). Erro = '||sqlerrm);
         end;
         --
       end if;
      --
    end if;
   --
   return vn_planoconta_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Plano_Conta_id:' || sqlerrm);
end fkg_Plano_Conta_id;
*/
function fkg_plano_conta_id ( ev_cod_cta    in plano_conta.cod_cta%type
                            , en_empresa_id in plano_conta.empresa_id%type)
         return plano_conta.id%type
is
   --
   vn_planoconta_id     plano_conta.id%type;
   vn_empresa_id_matriz empresa.id%type;
   --
begin
   --
   if trim(ev_cod_cta) is not null and
      nvl(en_empresa_id,0) > 0 then
      --
      begin
         select pc.id
           into vn_planoconta_id
           from plano_conta pc
          where pc.cod_cta    = ev_cod_cta
            and pc.empresa_id = en_empresa_id;
      exception
         when no_data_found then
            vn_planoconta_id := null;
         when others then
            raise_application_error(-20101, 'Problemas ao recuperar identificador do plano de contas (dados iguais aos parâmetros), (cod='||ev_cod_cta||
                                            ' empresa_id='||en_empresa_id||'). Erro = '||sqlerrm);
      end;
      --
      if vn_planoconta_id is null then -- verificar o código da conta eliminando a máscara
         --
         begin
            select pc.id
              into vn_planoconta_id
              from plano_conta pc
             where trim(replace(pc.cod_cta, '.', '')) = trim(replace(ev_cod_cta, '.', ''))
               and pc.empresa_id = en_empresa_id;
         exception
            when no_data_found then
               vn_planoconta_id := null;
            when others then
               raise_application_error(-20101, 'Problemas ao recuperar identificador do plano de contas (conta sem máscara), (cod='||ev_cod_cta||
                                               ' empresa_id='||en_empresa_id||'). Erro = '||sqlerrm);
         end;
         --
      end if;
      --
      if vn_planoconta_id is null then -- recuperar da empresa matriz
         --
         vn_empresa_id_matriz := fkg_empresa_id_matriz(en_empresa_id);
         --
         if nvl(en_empresa_id,0) = nvl(vn_empresa_id_matriz,0) then
            --
            null; -- mesma empresa
            --
         else
            --
            if nvl(vn_empresa_id_matriz,0) > 0 then
               --
               begin
                  select pc.id
                    into vn_planoconta_id
                    from plano_conta pc
                   where pc.cod_cta    = ev_cod_cta
                     and pc.empresa_id = vn_empresa_id_matriz;
               exception
                  when no_data_found then
                     vn_planoconta_id := null;
                  when others then
                     raise_application_error(-20101, 'Problemas ao recuperar identificador do plano de contas (dados iguais aos parâmetros), (cod='||
                                                     ev_cod_cta||' matriz_empresa_id='||en_empresa_id||'). Erro = '||sqlerrm);
               end;
               --
               if vn_planoconta_id is null then -- verificar o código da conta eliminando a máscara
                  --
                  begin
                     select pc.id
                       into vn_planoconta_id
                       from plano_conta pc
                      where trim(replace(pc.cod_cta, '.', '')) = trim(replace(ev_cod_cta, '.', ''))
                        and pc.empresa_id = vn_empresa_id_matriz;
                  exception
                     when no_data_found then
                        vn_planoconta_id := null;
                     when others then
                        raise_application_error(-20101, 'Problemas ao recuperar identificador do plano de contas (conta sem máscara), (cod='||ev_cod_cta||
                                                        ' matriz_empresa_id='||en_empresa_id||'). Erro = '||sqlerrm);
                  end;
                  --
               end if;
               --
            end if; -- nvl(vn_empresa_id_matriz,0) > 0
            --
         end if; -- nvl(en_empresa_id,0) = nvl(vn_empresa_id_matriz,0)
         --
      end if; -- vn_planoconta_id is null -- recuperar da empresa matriz
      --
    end if; -- trim(ev_cod_cta) is not null and nvl(en_empresa_id,0) > 0
   --
   return vn_planoconta_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_plano_conta_id:' || sqlerrm);
end fkg_plano_conta_id;

-------------------------------------------------------------------------------------------------------
-- Função retorna o ID da tabela Centro de Custo

function fkg_Centro_Custo_id ( ev_cod_ccus    in Centro_Custo.cod_ccus%TYPE
                             , en_empresa_id  in Centro_Custo.empresa_id%TYPE )
         return Centro_Custo.id%TYPE
is

   vn_centrocusto_id Centro_Custo.id%TYPE;

   vn_empresa_id_matriz empresa.id%type;

begin
   --
   if trim(ev_cod_ccus) is not null and
      nvl(en_empresa_id, 0) > 0 then
      --
      begin
         --
         select max(id)
           into vn_centrocusto_id
           from Centro_Custo
          where replace(COD_CCUS, '.', '') = replace(ev_cod_ccus, '.', '')
            and empresa_id = en_empresa_id;
          --
      exception
         when others then
            vn_centrocusto_id := 0;
      end;
      --
      if nvl(vn_centrocusto_id,0) <= 0 then
         -- Busca o centro de custo na matriz
         vn_empresa_id_matriz := fkg_empresa_id_matriz ( en_empresa_id => en_empresa_id );
         --
         if nvl(vn_empresa_id_matriz,0) <> en_empresa_id then
            --
            vn_centrocusto_id := fkg_Centro_Custo_id ( ev_cod_ccus    => ev_cod_ccus
                                                     , en_empresa_id  => vn_empresa_id_matriz
                                                     );
            --
         end if;
         --
      end if;
      --
    end if;
   --
   return vn_centrocusto_id;
   --
exception
   when no_data_found then
      return (null);
   when too_many_rows then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Centro_Custo_id:' || sqlerrm);
end fkg_Centro_Custo_id;

-------------------------------------------------------------------------------------------------------

--| Função Retorna o Código da Observação do Lançamento Fiscal

function fkg_cd_obs_lancto_fiscal ( en_obslanctofiscal_id in obs_lancto_fiscal.id%type )
         return obs_lancto_fiscal.cod_obs%type
is

   vv_cod_obs obs_lancto_fiscal.cod_obs%type := null;

begin
   --
   if nvl(en_obslanctofiscal_id, 0) > 0 then
      --
      select cod_obs
        into vv_cod_obs
        from obs_lancto_fiscal
       where id = en_obslanctofiscal_id;
      --
   end if;
   --
   return vv_cod_obs;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cd_obs_lancto_fiscal: ' || sqlerrm);
end fkg_cd_obs_lancto_fiscal;

-------------------------------------------------------------------------------------------------------
-- Função retorna o Sigla da tabela Unidade através do id.

function fkg_Unidade_sigla ( en_unidade_id  in Unidade.id%TYPE )
         return Unidade.sigla_unid%TYPE
is

   vv_sigla_unid  Unidade.sigla_unid%TYPE;

begin

   if nvl(en_unidade_id, 0) > 0 then
      --
      select sigla_unid
        into vv_sigla_unid
        from Unidade
       where id = en_unidade_id;
      --
   end if;

   return vv_sigla_unid;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Unidade_sigla:' || sqlerrm);
end fkg_Unidade_sigla;

-------------------------------------------------------------------------------------------------------
--| Função retorna o Código da tabela Item

function fkg_Item_cod ( en_item_id  in Item.id%TYPE )
         return Item.cod_item%TYPE
is

   vv_cod_item Item.cod_item%TYPE;

begin

   if nvl(en_item_id, 0) > 0 then
      --
      select cod_item
        into vv_cod_item
        from Item
       where id = en_item_id;
      --
   end if;

   return vv_cod_item;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Item_cod:' || sqlerrm);
end fkg_Item_cod;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela Infor_Comp_Dcto_Fiscal

function fkg_Infor_Comp_Dcto_Fiscal_cod( en_inforcompdctofiscal_id  in Infor_Comp_Dcto_Fiscal.id%TYPE )
         return Infor_Comp_Dcto_Fiscal.cod_infor%TYPE
is

   vv_cod_infor  Infor_Comp_Dcto_Fiscal.cod_infor%TYPE;

begin

   if nvl(en_inforcompdctofiscal_id, 0) > 0 then
      --
      select cod_infor
        into vv_cod_infor
        from Infor_Comp_Dcto_Fiscal
       where id = en_inforcompdctofiscal_id;
      --
   end if;

   return vv_cod_infor;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Infor_Comp_Dcto_Fiscal_cod:' || sqlerrm);
end fkg_Infor_Comp_Dcto_Fiscal_cod;

-------------------------------------------------------------------------------------------------------

--| Função verifica se a data é valida

function fkg_data_valida ( ev_dt       in  varchar2
                         , ev_formato  in  varchar2 )
         return boolean
is
   --
   vd_data date;
   --
begin
   --
   select to_date(ev_dt, ev_formato)
     into vd_data
     from dual;
   --
   return true;
   --
exception
    when others then
       return false;
   --
end fkg_data_valida;

-------------------------------------------------------------------------------------------------------

--| Procedimento cria usuário

procedure pkb_insere_usuario ( en_multorg_id  in  mult_org.id%type
                             , ev_login       in  neo_usuario.login%type
                             , ev_senha       in  neo_usuario.senha%type
                             , ev_nome        in  neo_usuario.nome%type
                             , ev_email       in  neo_usuario.email%type
                             )
is
   --
   vn_fase number := 0;
   --
   vn_usuario_id  neo_usuario.id%type     := null;
   vv_senha       neo_usuario.senha%type  := null;
   --
   CURSOR c_usu IS
      SELECT u.id
        FROM neo_usuario u
       WHERE u.login = nvl(ev_login, '');
   --
begin
   --
   vn_fase := 1;
   --
   if trim(ev_login) is not null then
      --
      vn_fase := 2;
      --
      open c_usu;
      fetch c_usu into vn_usuario_id;
      close c_usu;
      --
      vn_fase := 3;
      --
      if nvl(vn_usuario_id,0) > 0 then
         --
         vn_fase := 3.1;
         --
         return;  -- se achou o usuário então sai do procedimento
         --
      else
         --
         vn_fase := 3.2;
         --
         select neousuario_seq.nextval
           into vn_usuario_id
           from dual;
         --
      end if;
      --
      vn_fase := 4;
      -- se não informou a senha, atribui o login como senha
      if trim(ev_senha) is null then
         --
         vn_fase := 4.1;
         --
         vv_senha := lower(pk_csf.fkg_md5 ( ev_valor => trim(ev_login) ));
         --
      else
         --
         vn_fase := 4.2;
         --
         vv_senha := lower(pk_csf.fkg_md5 ( ev_valor => trim(ev_senha) ));
         --
      end if;
      --
      vn_fase := 5;
      --
      INSERT INTO neo_usuario
               ( id
               , nome
               , login
               , senha
               , email
               , bloqueado
               , id_erp
               , impressora_id
               , dm_tipo_acesso
               , dm_prim_acesso
               , multorg_id
               )
            VALUES
               ( vn_usuario_id
               , trim(nvl(ev_nome, ev_login)) -- se não informou o nome atribui o login
               , trim(ev_login)
               , vv_senha
               , trim(ev_email)
               , 0
               , NULL
               , NULL
               , 0 -- Interno
               , 1
               , en_multorg_id
               );
      --
      commit;
      --
   end if;
   --
exception
    when others then
       null;
end pkb_insere_usuario;

-------------------------------------------------------------------------------------------------------

-- Procedimento bloqueia o usuário

procedure pkb_bloqueia_usuario ( ev_login    in  neo_usuario.login%type )
is
   --
   vn_fase number := 0;
   --
begin
   --
   vn_fase := 0;
   --
   if trim(ev_login) is not null then
      --
      vn_fase := 1;
      --
      update neo_usuario set bloqueado = 1
       where login = trim(ev_login);
      --
      commit;
      --
   end if;
   --
exception
    when others then
       null;
end pkb_bloqueia_usuario;

-------------------------------------------------------------------------------------------------------

-- Copia perfil de um usuário de origem para um usuário de destino

procedure pkb_copia_perfil_usuario ( ev_login_origem   in  neo_usuario.login%type
                                   , ev_login_destino  in  neo_usuario.login%type
                                   )
is
   --
   vn_fase number := 0;
   --
   vn_usuario_id  neo_usuario.id%type     := null;
   --
   vn_qtde number;
   --
   cursor c_perfil is
   select up.*
     from neo_usuario        u
        , neo_usuario_papel  up
    where u.login            = trim(ev_login_origem)
      and up.usuario_id      = u.id;
   --
begin
   --
   vn_fase := 1;
   --
   vn_usuario_id := pk_csf.fkg_usuario_id ( ev_login => trim(ev_login_destino) );
   --
   vn_fase :=2;
   --
   if nvl(vn_usuario_id,0) > 0 then
      --
      for rec in c_perfil loop
         exit when c_perfil%notfound or (c_perfil%notfound) is null;
         --
         vn_fase := 3;
         --
         -- verifica se já existe
         vn_qtde := 0;
         --
         begin
            --
            select count(1)
              into vn_qtde
              from neo_usuario_papel
             where usuario_id = vn_usuario_id
               and papel_id   = rec.papel_id;
            --
         exception
            when others then
               vn_qtde := 0;
         end;
         --
         if nvl(vn_qtde,0) <= 0 then
            insert into neo_usuario_papel ( usuario_id, papel_id ) values ( vn_usuario_id, rec.papel_id );
         end if;
         --
      end loop;
      --
      commit;
      --
   end if;
   --
exception
    when others then
       null;
end pkb_copia_perfil_usuario;

-------------------------------------------------------------------------------------------------------

--| Procedimento Copia Empresas de um usuário de origem para um usuário de destino

procedure pkb_copia_empresa_usuario ( ev_login_origem   in  neo_usuario.login%type
                                    , ev_login_destino  in  neo_usuario.login%type
                                    )
is
   --
   vn_usuario_id_destino neo_usuario.id%type;
   vn_usuempr_id usuario_empresa.id%type;
   vn_usuemprunidorg_id usuempr_unidorg.id%type;
   --
   cursor c_emp is
   select ue.*
     from neo_usuario      u
        , usuario_empresa  ue
    where u.login          = ev_login_origem
      and ue.usuario_id    = u.id
    order by ue.id;
   --
   cursor c_uo ( en_empresa_id empresa.id%type ) is
   select ueuo.*
     from neo_usuario      u
        , usuario_empresa  ue
        , usuempr_unidorg  ueuo
    where u.login          = ev_login_origem
      and ue.usuario_id    = u.id
      and ue.empresa_id    = en_empresa_id
      and ueuo.usuempr_id  = ue.id
    order by ueuo.id;
   --
begin
   -- pega o ID do usuário de destino que já deve estar criado
   vn_usuario_id_destino := pk_csf.fkg_usuario_id ( ev_login => ev_login_destino );
   --
   if nvl(vn_usuario_id_destino,0) > 0 then
      --
      for rec in c_emp loop
        exit when c_emp%notfound or (c_emp%notfound) is null;
        --
        -- verifica se já existe a empresa para o usuário
        vn_usuempr_id := 0;
        --
        begin
           --
           select max(id)
             into vn_usuempr_id
             from usuario_empresa
            where USUARIO_ID = vn_usuario_id_destino
              and EMPRESA_ID = rec.EMPRESA_ID;
           --
        exception
           when others then
              vn_usuempr_id := 0;
        end;
        --
        if nvl(vn_usuempr_id,0) <= 0 then
           --
           select usuempr_seq.nextval
             into vn_usuempr_id
             from dual;
           --
           insert into usuario_empresa ( ID
                                       , USUARIO_ID
                                       , EMPRESA_ID
                                       , DM_ACESSO
                                       , DM_EMPR_DEFAULT
                                       )
                                values ( vn_usuempr_id
                                       , vn_usuario_id_destino
                                       , rec.EMPRESA_ID
                                       , rec.DM_ACESSO
                                       , rec.DM_EMPR_DEFAULT
                                       );
           --
        end if;
        --
        -- recupera as UO do usuário origem para o usuário destino
        for rec2 in c_uo(rec.EMPRESA_ID) loop
           exit when c_uo%notfound or (c_uo%notfound) is null;
           --
           -- verifica se já existe UO para o usuário
           vn_usuemprunidorg_id := 0;
           --
           begin
              --
              select max(id)
                into vn_usuemprunidorg_id
                from usuempr_unidorg
               where usuempr_id = vn_usuempr_id
                 and unidorg_id = rec2.unidorg_id;
              --
           exception
              when others then
                 vn_usuemprunidorg_id := 0;
           end;
           --
           if nvl(vn_usuemprunidorg_id,0) <= 0 then
              --
              select usuemprunidorg_seq.nextval
                into vn_usuemprunidorg_id
                from dual;
              --
              insert into usuempr_unidorg ( ID
                                          , USUEMPR_ID
                                          , UNIDORG_ID
                                          , DM_ACESSO
                                          , DM_UO_DEFAULT
                                          )
                                   values ( vn_usuemprunidorg_id -- ID
                                          , vn_usuempr_id -- USUEMPR_ID
                                          , rec2.UNIDORG_ID
                                          , rec2.DM_ACESSO
                                          , rec2.DM_UO_DEFAULT
                                          );
              --
           end if;
           --
        end loop;
        --
      end loop;
      --
   end if;
   --
   commit;
   --
exception
    when others then
       null;
end pkb_copia_empresa_usuario;

-------------------------------------------------------------------------------------------------------

--| Função retornar se existe o CPF/CNPJ para integração EDI

function fkg_integr_edi ( en_multorg_id in param_integr_edi.multorg_id%type
                        , ev_cpf_cnpj   in param_integr_edi.cpf_cnpj%type
                        , en_dm_tipo    in param_integr_edi.dm_tipo%type
                        )
         return boolean
is
   --
   vn_dummy number := 0;
   --
   cursor c_param ( evc_cpf_cnpj in param_integr_edi.cpf_cnpj%type ) is
   select distinct 1 from param_integr_edi p
    where p.cpf_cnpj = evc_cpf_cnpj
      and p.multorg_id = en_multorg_id
      and (p.dm_tipo = 0 or p.dm_tipo = en_dm_tipo );
   --
begin
   --
   if trim(ev_cpf_cnpj) is not null then
      --
      open c_param(trim(ev_cpf_cnpj));
      fetch c_param into vn_dummy;
      close c_param;
      --
      -- se não econtrou tenta pela raiz do CNPJ
      if vn_dummy = 0 then
         --
         open c_param(substr(trim(ev_cpf_cnpj), 1, 8));
         fetch c_param into vn_dummy;
         close c_param;
         --
      end if;
      --
   end if;
   --
   return (vn_dummy = 1);
   --
exception
    when others then
       return false;
   --
end fkg_integr_edi;

-------------------------------------------------------------------------------------------------------

FUNCTION fkg_limpa_acento ( ev_string IN varchar2 )
         RETURN VARCHAR2 IS
   --
   vv_valor2 varchar2(32767);
   vi        number;
   --
BEGIN
   --
   vi := 0;
   -- Remove os caracteres especiais.
   vv_valor2 := nvl(ltrim(rtrim(translate(ev_string, 'ÇçåÅâÂãÃáÁàÀäÄêÊéÉèÈëËîÎíÍìÌïÏôÔÕõóÓòÒöÖûÛúÚùÙüÜÿŸýÝñÑÐ\ˆ“&¤¶¦æÆø×ƒØ¿®±¾½¼«»ðßµþÞ¯÷œ¸·"!#%¨*={}[]|<>:?ªº°§¹²³™š£¢¬´`~^¿¢€¥‰†‡„‹›¦ ¡•§·º…–—"''’'
                                                   , 'CcaAaAaAaAaAaAeEeEeEeEiIiIiIiIoOOooOoOoOuUuUuUuUyYyYnND'))), ' ');
   --
   vv_valor2 := REPLACE( vv_valor2, chr(9), '');  -- HT-Horizontal Tab
   vv_valor2 := REPLACE( vv_valor2, chr(27), ''); -- ESC-Escape
   vv_valor2 := REPLACE( vv_valor2, chr(13), ''); -- CR-Carriage Return
   vv_valor2 := REPLACE( vv_valor2, chr(31), ''); -- US-Unit Separator
   vv_valor2 := REPLACE( vv_valor2, chr(36), ''); -- $-Dollar
   --
    -- Limpa caracteres Unicode
    vv_valor2 := ASCIISTR(vv_valor2);
    vv_valor2 := REPLACE( vv_valor2, '\0081', '');
    vv_valor2 := REPLACE( vv_valor2, '\00AD', '');
    vv_valor2 := REPLACE( vv_valor2, '\00BF', '');
    vv_valor2 := REPLACE( vv_valor2, '\00A9', '');
   --
   -- Elimina os espaços entre as palavras
   WHILE instr(vv_valor2, '  ') > 0
   LOOP
      vv_valor2 := REPLACE(vv_valor2, '  ', ' ');
   END LOOP;
   --
   vv_valor2 := REPLACE( vv_valor2, chr(10), ''); -- LF-Line Feed-Enter
   --
   -- retira o CHR(10)/Enter/LF-Line Feed, do início do texto
   while ascii(substr(vv_valor2,1,1)) = 10
   loop
      --
      vv_valor2 := substr(vv_valor2,2,length(vv_valor2));
      --
   end loop;
   --
   -- retira o CHR(10)/Enter/LF-Line Feed, do final do texto
   while ascii(substr(vv_valor2,length(vv_valor2),1)) = 10
   loop
      --
      vv_valor2 := substr(vv_valor2,1,length(vv_valor2) - 1);
      --
   end loop;
   --
   RETURN trim(vv_valor2); -- limpa os espaços do início e do fim da string
   --
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE <> -20001 THEN
         raise_application_error(-20001, 'Erro na fkg_limpa_acento : ' || SQLERRM);
      END IF;
      RAISE;
END fkg_limpa_acento;

-------------------------------------------------------------------------------------------------------

-- Função retorna se o NCM obrigada a informação de medicamento para Nota Fiscal

function fkg_ncm_id_obrig_med_itemnf ( en_ncm_id  in ncm.id%type )
         return ncm.dm_obrig_med_itemnf%type
is
   --
   vn_dm_obrig_med_itemnf  ncm.dm_obrig_med_itemnf%type := 0;
   --
begin
   --
   select dm_obrig_med_itemnf
     into vn_dm_obrig_med_itemnf
     from ncm
    where id = en_ncm_id;
   --
   return vn_dm_obrig_med_itemnf;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_ncm_id_obrig_med_itemnf:' || sqlerrm);
end fkg_ncm_id_obrig_med_itemnf;

-------------------------------------------------------------------------------------------------------

--| Função retorna o código da versão do sistema conforme id

function fkg_versao_sistema_id ( en_versaosistema_id in versao_sistema.id%type )
         return versao_sistema.versao%type
is
   --
   vv_versao versao_sistema.versao%type := null;
   --
begin
   --
   select versao
     into vv_versao
     from versao_sistema vv
    where id = en_versaosistema_id;
   --
   return vv_versao;
   --
exception
   when others then
      return null;
end fkg_versao_sistema_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna o código da última versão atual do sistema

function fkg_ultima_versao_sistema
         return versao_sistema.versao%type
is
   --
   vn_versaosistema_id versao_sistema.id%type := null;
   vv_versao versao_sistema.versao%type := null;
   --
begin
   --
   --antigo:
   /*select max(vv.id)
     into vn_versaosistema_id
     from versao_sistema vv;
   --
   vv_versao := pk_csf.fkg_versao_sistema_id ( en_versaosistema_id => vn_versaosistema_id );*/
   --novo:
   select versao into  vv_versao from (
          select versao
          from versao_sistema
          order by substr(versao, 1, instr(versao,'.')-1) desc,
                   substr(versao, 3, instr(versao,'.')-1)desc,
                   substr(versao, 5, instr(versao,'.')-1) desc,
                   to_number(nvl(substr(versao, 7, instr(versao,'.')+2),0)) desc  )
                   where rownum =1 ;
   --
   return vv_versao;
   --
exception
   when others then
      return null;
end fkg_ultima_versao_sistema;

-------------------------------------------------------------------------------------------------------

--| Função retorna o parâmetro de "Retorno da Informação de Hora de Autorização/Cancelamento da empresa"

function fkg_ret_hr_aut_empresa_id ( en_empresa_id in empresa.id%type )
         return empresa.dm_ret_hr_aut%type
is
   --
   vn_dm_ret_hr_aut empresa.dm_ret_hr_aut%type := 0;
   --
begin
   --
   select dm_ret_hr_aut
     into vn_dm_ret_hr_aut
     from empresa
    where id = en_empresa_id;
   --
   return vn_dm_ret_hr_aut;
   --
exception
   when no_data_found then
      return 0;
   when others then
      return 0;
end fkg_ret_hr_aut_empresa_id;
--
-- =================================================================================================== --
-- Função converte um BLOB em CLOB

FUNCTION fkg_blob_to_clob (blob_in IN BLOB)
RETURN CLOB
AS
	v_clob    CLOB;
	v_varchar VARCHAR2(32767);
	v_start	 PLS_INTEGER := 1;
	v_buffer  PLS_INTEGER := 32767;
BEGIN
	DBMS_LOB.CREATETEMPORARY(v_clob, TRUE);

	FOR i IN 1..CEIL(DBMS_LOB.GETLENGTH(blob_in) / v_buffer)
	LOOP

	   v_varchar := UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(blob_in, v_buffer, v_start));

           DBMS_LOB.WRITEAPPEND(v_clob, LENGTH(v_varchar), v_varchar);

		v_start := v_start + v_buffer;
	END LOOP;

   RETURN v_clob;

END fkg_blob_to_clob;

-------------------------------------------------------------------------------------------------------

-- Função retorna o dm_mod_frete da tabela nota_fiscal_transp através do notafiscal_id

function fkg_modfrete_nftransp ( en_notafiscal_id  in nota_fiscal.id%type )
         return nota_fiscal_transp.dm_mod_frete%type
is
   --
   vn_dm_mod_frete nota_fiscal_transp.dm_mod_frete%type;
   --
begin
   --
   if nvl(en_notafiscal_id, 0) > 0 then
      --
      select max(e.dm_mod_frete)
        into vn_dm_mod_frete
        from nota_fiscal_transp e
      where e.notafiscal_id = en_notafiscal_id;
      --
   end if;
   --
   return vn_dm_mod_frete;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_modfrete_nftransp:' || sqlerrm);
end fkg_modfrete_nftransp;

-------------------------------------------------------------------------------------------------------
--| Função retorna o codigo do imposto através do id

function fkg_Tipo_Imposto_cd ( en_tipoimp_id  in Tipo_Imposto.id%TYPE )
         return Tipo_Imposto.cd%TYPE
is

   vv_tipoimp_cd  Tipo_Imposto.cd%TYPE;

begin

   if nvl(en_tipoimp_id, 0) > 0 then
      --
      select trim(cd)
        into vv_tipoimp_cd
        from Tipo_Imposto
       where id = en_tipoimp_id;
   --
   end if;

   return vv_tipoimp_cd;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Tipo_Imposto_cd:' || sqlerrm);
end fkg_Tipo_Imposto_cd;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID do Conhecimento de Transporte conforme Empresa, Pessoa, Modelo, Indicador de emitente e operação, Número, Série e Sub série

function fkg_conhec_transp_id( en_empresa_id   in conhec_transp.empresa_id%type
                             , en_dm_ind_emit  in conhec_transp.dm_ind_emit%type
                             , en_dm_ind_oper  in conhec_transp.dm_ind_oper%type
                             , en_pessoa_id    in conhec_transp.pessoa_id%type
                             , en_modfiscal_id in conhec_transp.modfiscal_id%type
                             , en_nro_ct       in conhec_transp.nro_ct%type
                             , ev_serie        in conhec_transp.serie%type
                             , ev_subserie     in conhec_transp.subserie%type )
         return conhec_transp.id%type is
   --
   vn_conhectransp_id  conhec_transp.id%type;
   --
begin
   --
   if nvl(ev_subserie,0) = 0 then
      --
      select ct.id
        into vn_conhectransp_id
        from conhec_transp ct
       where ct.empresa_id   = en_empresa_id
         and ct.dm_ind_emit  = en_dm_ind_emit
         and ct.dm_ind_oper  = en_dm_ind_oper
         and ct.pessoa_id    = en_pessoa_id
         and ct.modfiscal_id = en_modfiscal_id
         and ct.nro_ct       = en_nro_ct
         and ct.serie        = ev_serie;
      --
   else
      --
      select ct.id
        into vn_conhectransp_id
        from conhec_transp ct
       where ct.empresa_id   = en_empresa_id
         and ct.dm_ind_emit  = en_dm_ind_emit
         and ct.dm_ind_oper  = en_dm_ind_oper
         and ct.pessoa_id    = en_pessoa_id
         and ct.modfiscal_id = en_modfiscal_id
         and ct.nro_ct       = en_nro_ct
         and ct.serie        = ev_serie
         and ct.subserie     = ev_subserie;
      --
   end if;
   --
   return vn_conhectransp_id;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Problemas em fkg_conhec_transp_id:'||sqlerrm);
end fkg_conhec_transp_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID do Item da Nota Fiscal conforme Identificador da NF e Número do Item

function fkg_item_nota_fiscal_id( en_notafiscal_id in item_nota_fiscal.notafiscal_id%type
                                , en_nro_item      in item_nota_fiscal.nro_item%type )
         return item_nota_fiscal.id%type is
   --
   vn_itemnotafiscal_id  item_nota_fiscal.id%type := 0;
   --
begin
   --
   select ie.id
     into vn_itemnotafiscal_id
     from item_nota_fiscal ie
    where ie.notafiscal_id = en_notafiscal_id
      and ie.nro_item      = en_nro_item;
   --
   return vn_itemnotafiscal_id;
   --
exception
   when no_data_found then
      return -1;
   when others then
      raise_application_error(-20101, 'Problemas em fkg_item_nota_fiscal_id. Erro = '||sqlerrm);
end fkg_item_nota_fiscal_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID do relacionamento entre o rateio de frete e o item da nota fiscal

function fkg_frete_itemnf_id( en_conhectransp_id   in conhec_transp.id%type
                            , en_notafiscal_id     in nota_fiscal.id%type
                            , en_itemnotafiscal_id in item_nota_fiscal.id%type )
         return frete_itemnf.id%type is
   --
   vn_freteitemnf_id frete_itemnf.id%type;
   --
begin
   --
   select fi.id
     into vn_freteitemnf_id
     from frete_itemnf fi
    where fi.conhectransp_id   = en_conhectransp_id
      and fi.notafiscal_id     = en_notafiscal_id
      and fi.itemnotafiscal_id = en_itemnotafiscal_id;
   --
   return vn_freteitemnf_id;
   --
exception
   when no_data_found then
      return -1;
   when others then
      raise_application_error(-20101, 'Problemas em fkg_frete_itemnf_id. Erro = '||sqlerrm);
end fkg_frete_itemnf_id;

-------------------------------------------------------------------------------------------------------

--| Procedimento de limpeza dos logs

procedure pkb_limpa_log
is
   --
   pragma  autonomous_transaction;
   --
   vn_fase number;
   --
   cursor c_dados is
   select ctl.id
     from csf_tipo_log ctl
    where ctl.cd in ( 'ERRO_VALIDA'
                    , 'ERRO_GERAL_SISTEMA'
                    , 'ERRO_XML_NFE'
                    , 'ERRO_ENV_LOTE_SEFAZ_NFE'
                    , 'ERRO_RET_ENV_LOTE_SEFAZ_NFE'
                    , 'INFO_RET_ENV_LOTE_SEFAZ_NFE'
                    , 'ERRO_RET_PROC_LOTE_SEFAZ_NFE'
                    , 'INFO_RET_PROC_LOTE_SEFAZ_NFE'
                    , 'ERRO_RET_PROC_LOTE_NFE'
                    , 'INFO_RET_PROC_LOTE_NFE'
                    , 'ERRO_ENVRET_CANCELA_NFE'
                    , 'INFO_ENVRET_CANCELA_NFE'
                    , 'ERRO_ENVRET_INUTILIZA_NFE'
                    , 'INFO_ENVRET_INUTILIZA_NFE'
                    , 'ERRO_ENV_EMAIL_DEST_NFE'
                    , 'ERRO_IMPRESSAO_DANFE'
                    , 'AVISO_IMPRESSAO_DANFE'
                    , 'INFO_LOG_GENERICO'
                    , 'INFO_ENV_LOTE_SEFAZ_NFE'
                    , 'AVISO_ENV_LOTE_SEFAZ_NFE'
                    , 'AVISO_LOG_GENERICO'
                    , 'AVISO_IMP_ARQ'
                    , 'ERRO_IMP_ARQ'
                    , 'INFO_IMP_ARQ'
                    , 'INFO_NFE_INTEGRADA'
                    , 'INFO_ENV_EMAIL_DEST_NFE'
                    , 'INFO_IMPRESSAO_DANFE'
                    , 'CONS_SIT_NFE_SEFAZ'
                    , 'INFO_CANC_NFE'
                    , 'INFO_INTEGR'
                    , 'CONHEC_TRANSP_INTEGRADO'
                    , 'INFORMACAO'
                    );
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      vn_fase := 1.1;
      --
      delete from log_generico lg
       where lg.csftipolog_id = rec.id
         and trunc(lg.dt_hr_log) <= trunc(sysdate - 15);
      --
      vn_fase := 1.2;
      --
      delete from LOG_GENERICO_CAD lg
       where lg.csftipolog_id = rec.id
         and trunc(lg.dt_hr_log) <= trunc(sysdate - 15);
      --
      vn_fase := 1.3;
      --
      delete from LOG_GENERICO_CCF lg
       where lg.csftipolog_id = rec.id
         and trunc(lg.dt_hr_log) <= trunc(sysdate - 15);
      --
      vn_fase := 1.4;
      --
      delete from LOG_GENERICO_CF lg
       where lg.csftipolog_id = rec.id
         and trunc(lg.dt_hr_log) <= trunc(sysdate - 15);
      --
      vn_fase := 1.5;
      --
      delete from LOG_GENERICO_CIAP lg
       where lg.csftipolog_id = rec.id
         and trunc(lg.dt_hr_log) <= trunc(sysdate - 15);
      --
      vn_fase := 1.6;
      --
      delete from LOG_GENERICO_CPE lg
       where lg.csftipolog_id = rec.id
         and trunc(lg.dt_hr_log) <= trunc(sysdate - 15);
      --
      vn_fase := 1.7;
      --
      delete from LOG_GENERICO_CT lg
       where lg.csftipolog_id = rec.id
         and trunc(lg.dt_hr_log) <= trunc(sysdate - 15);
      --
      vn_fase := 1.8;
      --
      delete from LOG_GENERICO_DC lg
       where lg.csftipolog_id = rec.id
         and trunc(lg.dt_hr_log) <= trunc(sysdate - 15);
      --
      vn_fase := 1.8;
      --
      delete from LOG_GENERICO_ECREDAC lg
       where lg.csftipolog_id = rec.id
         and trunc(lg.dt_hr_log) <= trunc(sysdate - 15);
      --
      vn_fase := 1.9;
      --
      delete from LOG_GENERICO_IFP lg
       where lg.csftipolog_id = rec.id
         and trunc(lg.dt_hr_log) <= trunc(sysdate - 15);
      --
      vn_fase := 1.10;
      --
      delete from LOG_GENERICO_INV lg
       where lg.csftipolog_id = rec.id
         and trunc(lg.dt_hr_log) <= trunc(sysdate - 15);
      --
      vn_fase := 1.11;
      --
      delete from LOG_GENERICO_IRD lg
       where lg.csftipolog_id = rec.id
         and trunc(lg.dt_hr_log) <= trunc(sysdate - 15);
      --
      vn_fase := 1.12;
      --
      delete from LOG_GENERICO_IVA lg
       where lg.csftipolog_id = rec.id
         and trunc(lg.dt_hr_log) <= trunc(sysdate - 15);
      --
      vn_fase := 1.13;
      --
      delete from LOG_GENERICO_NF lg
       where lg.csftipolog_id = rec.id
         and trunc(lg.dt_hr_log) <= trunc(sysdate - 15);
      --
      vn_fase := 1.15;
      --
      delete from LOG_GENERICO_PDU lg
       where lg.csftipolog_id = rec.id
         and trunc(lg.dt_hr_log) <= trunc(sysdate - 15);
      --
      vn_fase := 1.16;
      --
      delete from LOG_GENERICO_PIR lg
       where lg.csftipolog_id = rec.id
         and trunc(lg.dt_hr_log) <= trunc(sysdate - 15);
      --
      vn_fase := 1.17;
      --
      delete from LOG_GENERICO_SCC lg
       where lg.csftipolog_id = rec.id
         and trunc(lg.dt_hr_log) <= trunc(sysdate - 15);
      --
      vn_fase := 1.18;
      --
      delete from LOG_GENERICO_TOC lg
       where lg.csftipolog_id = rec.id
         and trunc(lg.dt_hr_log) <= trunc(sysdate - 15);
      --
      vn_fase := 1.19;
      --
      delete from LOG_GENERICO_USU lg
       where lg.csftipolog_id = rec.id
         and trunc(lg.dt_hr_log) <= trunc(sysdate - 15);
      --
   end loop;
   --
   vn_fase := 2;
   --
   delete from LOG_GENERICO_ORACLE lg
    where trunc(lg.dt_hr_log) <= trunc(sysdate - 15);
   --
   commit;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pkb_limpa_log fase (' || vn_fase || '):' || sqlerrm);
end pkb_limpa_log;

-------------------------------------------------------------------------------------------------------

--| Função retorno o nome do usuário

function fkg_usuario_nome ( en_usuario_id in neo_usuario.id%type )
         return neo_usuario.nome%TYPE
is

   vv_nome  neo_usuario.nome%TYPE;

begin

   if nvl(en_usuario_id, 0) > 0 then
      --
      select trim(nome)
        into vv_nome
        from neo_usuario
       where id = en_usuario_id;
      --
   end if;

   return vv_nome;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_usuario_nome:' || sqlerrm);
end fkg_usuario_nome;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da nota Fiscal de terceiro de armazenamento fiscal a partir do número da chave de acesso

function fkg_nf_id_terceiro_pela_chave ( en_nro_chave_nfe  in Nota_Fiscal.nro_chave_nfe%TYPE )
         return Nota_Fiscal.id%TYPE
is

   vn_notafiscal_id  Nota_Fiscal.id%TYPE := null;

begin

   if en_nro_chave_nfe is not null then
      --
      select max(nf.id)
        into vn_notafiscal_id
        from Nota_Fiscal  nf
       where nf.nro_chave_nfe = en_nro_chave_nfe
         and nf.dm_arm_nfe_terc = 1;
      --
   end if;

   return vn_notafiscal_id;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_nf_id_terceiro_pela_chave:' || sqlerrm);
end fkg_nf_id_terceiro_pela_chave;

-------------------------------------------------------------------------------------------------------

--| Função retorno o ID da tabela NEO_PAPEL conforme "sigla da descrição"

function fkg_papel_id_conf_nome ( ev_nome in neo_papel.nome%type )
         return neo_papel.id%type
is
   --
   vn_papel_id neo_papel.id%type := null;
   --
begin
   --
   select id
     into vn_papel_id
     from neo_papel
    where nome = ev_nome;
   --
   return vn_papel_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_papel_id_conf_nome:' || sqlerrm);
end fkg_papel_id_conf_nome;

-------------------------------------------------------------------------------------------------------

--| Função verifica se existe o papel informado para o usuário

function fkg_existe_usuario_papel ( en_usuario_id  in neo_usuario.id%type
                                  , en_papel_id    in neo_papel.id%type
                                  )
         return boolean
is
   --
   vn_papel_id        neo_papel.id%type := null;
   vn_dummy           number := 0;
   --
begin
   --
   select distinct 1
     into vn_dummy
     from neo_usuario_papel
    where usuario_id  = en_usuario_id
      and papel_id    = en_papel_id;
   --
   return ( nvl(vn_dummy,0) > 0 );
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_usuario_papel:' || sqlerrm);
end fkg_existe_usuario_papel;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID do acesso de usuário/empresa

function fkg_usuario_empresa_id ( en_usuario_id  in neo_usuario.id%type
                                , en_empresa_id  in empresa.id%type
                                )
         return usuario_empresa.id%type
is
   --
   vn_usuempr_id        usuario_empresa.id%type := null;
   --
begin
   --
   select max(id)
     into vn_usuempr_id
     from usuario_empresa
    where usuario_id  = en_usuario_id
      and empresa_id  = en_empresa_id;
   --
   return vn_usuempr_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_usuario_empresa_id:' || sqlerrm);
end fkg_usuario_empresa_id;

-------------------------------------------------------------------------------------------------------

-- Função retorno o ID do acesso do usuário a Unidade Organizacional

function fkg_usuempr_unidorg_id ( en_usuempr_id  in usuario_empresa.id%type
                                , en_unidorg_id  in unid_org.id%type
                                )
         return usuempr_unidorg.id%type
is
   --
   vn_usuemprunidorg_id usuempr_unidorg.id%type := null;
   --
begin
   --
   select max(id)
     into vn_usuemprunidorg_id
     from usuempr_unidorg
    where usuempr_id = en_usuempr_id
      and unidorg_id = en_unidorg_id;
   --
   return vn_usuemprunidorg_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_usuempr_unidorg_id:' || sqlerrm);
end fkg_usuempr_unidorg_id;

-------------------------------------------------------------------------------------------------------

-- Função retorno o código de nome da empresa conforme seu ID

function fkg_cod_nome_empresa_id ( en_empresa_id in empresa.id%type )
         return varchar2
is
   --
   vv_dados varchar2(255) := null;
   --
begin
   --
   select p.cod_part || '-' || p.nome
     into vv_dados
     from empresa e
        , pessoa p
    where e.id = en_empresa_id
      and p.id = e.pessoa_id;
   --
   return vv_dados;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cod_nome_empresa_id:' || sqlerrm);
end fkg_cod_nome_empresa_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Código de Consumo do Item de Serviço Contínuo "COD_CONS_ITEM_CONT"

function fkg_codconsitemcont_id ( en_modfiscal_id  in  mod_fiscal.id%type
                                , ev_cod_cons      in  cod_cons_item_cont.cod_cons%type
                                )
         return cod_cons_item_cont.id%type
is
   --
   vn_codconsitemcont_id      cod_cons_item_cont.id%type;
   --
begin
   --
   select id
     into vn_codconsitemcont_id
     from cod_cons_item_cont
    where modfiscal_id  = en_modfiscal_id
      and cod_cons      = trim(ev_cod_cons);
   --
   return vn_codconsitemcont_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_codconsitemcont_id:' || sqlerrm);
end fkg_codconsitemcont_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do Código da Classe de Consumo do Item de Serviço Contínuo

function fkg_class_cons_item_cont_id ( ev_cod_class in class_cons_item_cont.cod_class%type )
         return class_cons_item_cont.id%type
is
   --
   vn_classconsitemcont_id class_cons_item_cont.id%type;
   --
begin
   --
   select id
     into vn_classconsitemcont_id
     from class_cons_item_cont
    where cod_class = ev_cod_class;
   --
   return vn_classconsitemcont_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_class_cons_item_cont_id:' || sqlerrm);
end fkg_class_cons_item_cont_id;

-------------------------------------------------------------------------------------------------------

-- Função retona o ID da empresa pelo ID da nota fiscal

function fkg_empresa_notafiscal ( en_notafiscal_id in nota_fiscal.id%type )
         return empresa.id%type
is
   --
   vn_empresa_id empresa.id%type;
   --
begin
   --
   select empresa_id
     into vn_empresa_id
     from nota_fiscal
    where id = en_notafiscal_id;
   --
   return vn_empresa_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_notafiscal:' || sqlerrm);
end fkg_empresa_notafiscal;

-------------------------------------------------------------------------------------------------------

-- Função verifica se cálcula ICMS-ST para a Nota Fiscal conforme Empresa

function fkg_dm_nf_calc_icmsst_empresa ( en_empresa_id in empresa.id%type )
         return empresa.dm_nf_calc_icmsst%type
is
   --
   vn_dm_nf_calc_icmsst empresa.dm_nf_calc_icmsst%type;
   --
begin
   --
   select dm_nf_calc_icmsst
     into vn_dm_nf_calc_icmsst
     from empresa
    where id = en_empresa_id;
   --
   return vn_dm_nf_calc_icmsst;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_dm_nf_calc_icmsst_empresa:' || sqlerrm);
end fkg_dm_nf_calc_icmsst_empresa;

-------------------------------------------------------------------------------------------------------

-- Função verifica se a empresa ajusta o total da nota fiscal

function fkg_ajustatotalnf_empresa ( en_empresa_id in empresa.id%type )
         return empresa.dm_ajusta_total_nf%type
is
   --
   vn_dm_ajusta_total_nf  empresa.dm_ajusta_total_nf%type := 0;
   --
begin
   --
   select dm_ajusta_total_nf
     into vn_dm_ajusta_total_nf
     from empresa
    where id = en_empresa_id;
   --
   return vn_dm_ajusta_total_nf;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_ajustatotalnf_empresa:' || sqlerrm);
end fkg_ajustatotalnf_empresa;

-------------------------------------------------------------------------------------------------------

--| Função Retorna o Texto da Observação do Lançamento Fiscal

function fkg_txt_obs_lancto_fiscal ( en_obslanctofiscal_id in obs_lancto_fiscal.id%type )
         return obs_lancto_fiscal.txt%type
is

   vv_txt obs_lancto_fiscal.txt%type := null;

begin
   --
   if nvl(en_obslanctofiscal_id, 0) > 0 then
      --
      select txt
        into vv_txt
        from obs_lancto_fiscal
       where id = en_obslanctofiscal_id;
      --
   end if;
   --
   return vv_txt;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_txt_obs_lancto_fiscal: ' || sqlerrm);
end fkg_txt_obs_lancto_fiscal;

-------------------------------------------------------------------------------------------------------

--| Função Retorna a Inscrição Estadual do Substituto conforme Empresa e Estado

function fkg_iest_empresa ( en_empresa_id  in empresa.id%type
                          , en_estado_id   in estado.id%type
                          )
         return ie_subst.iest%type
is
   --
   vv_iest        ie_subst.iest%type := null;
   --
begin
   --
   select iest
     into vv_iest
     from ie_subst
    where empresa_id  = en_empresa_id
      and estado_id   = en_estado_id;
   --
   return vv_iest;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_iest_empresa: ' || sqlerrm);
end fkg_iest_empresa;

-------------------------------------------------------------------------------------------------------

--| Função retorna "true" se o id é válido e "false" se não é

function fkg_itemparamicmsst_id_valido ( en_id  in item_param_icmsst.id%TYPE )
         return boolean
is

   vn_dummy number := 0;

begin

   if nvl(en_id,0) > 0 then

      select 1
        into vn_dummy
        from item_param_icmsst
       where id = en_id;

   end if;

   if nvl(vn_dummy,0) > 0 then
      return true;
   else
      return false;
   end if;

exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_item_id_valido:' || sqlerrm);
end fkg_itemparamicmsst_id_valido;

-------------------------------------------------------------------------------------------------------

--| Função que verifica a existencia de resgistro na Item_param_icmsst

function fkg_item_param_icmsst_id ( en_item_id        in   item_param_icmsst.item_id%type
                                  , en_empresa_id     in   item_param_icmsst.empresa_id%type
                                  , en_estado_id      in   item_param_icmsst.estado_id%type
              	                  , en_cfop_id_orig   in   item_param_icmsst.cfop_id%type
              	                  , ed_dt_ini         in   item_param_icmsst.dt_ini%type
              	                  , ed_dt_fin         in   item_param_icmsst.dt_fin%type
                                  )
         return item_param_icmsst.id%type
is
   --
   vn_id item_param_icmsst.id%type;
   --
begin
   --
   select st.id
     into vn_id
     from item_param_icmsst  st
    where st.item_id         = en_item_id
      and st.empresa_id      = en_empresa_id
      and st.estado_id       = en_estado_id
      and st.cfop_id         = en_cfop_id_orig
      and trunc(st.dt_ini)   = trunc(ed_dt_ini)
      and trunc(st.dt_fin)   = trunc(ed_dt_fin);
   --
   return vn_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_item_param_icmsst_id:' || sqlerrm);
end fkg_item_param_icmsst_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna CD através do tipo de parâmetro

function fkg_cd_tipoparam ( en_tipoparam_id in tipo_param.id%type )
         return tipo_param.cd%type
is
   --
   vv_cd tipo_param.cd%type;
   --
begin
   --
   select tp.cd
     into vv_cd
     from tipo_param tp
    where tp.id = en_tipoparam_id;
   --
   return vv_cd;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_cd_tipoparam:' || sqlerrm);
end fkg_cd_tipoparam;

-------------------------------------------------------------------------------------------------------

--| Função retorna ID do tipo de parâmetro

function fkg_tipoparam_id ( ev_cd in tipo_param.cd%type )
         return tipo_param.id%type
is
   --
   vn_tipoparam_id tipo_param.id%type;
   --
begin
   --
   select id
     into vn_tipoparam_id
     from tipo_param
    where cd = trim(ev_cd);
   --
   return vn_tipoparam_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_tipoparam_id:' || sqlerrm);
end fkg_tipoparam_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna a informação do "ID" do Valor do Tipo de Parametro salvo na pessoa

function fkg_pessoa_valortipoparam_id ( en_tipoparam_id in tipo_param.id%type
                                      , en_pessoa_id    in pessoa.id%type
                                      )
         return valor_tipo_param.id%type
is
   --
   vn_valortipoparam_id valor_tipo_param.id%type := null;
   --
begin
   --
   select valortipoparam_id
     into vn_valortipoparam_id
     from pessoa_tipo_param
    where pessoa_id     = en_pessoa_id
      and tipoparam_id  = en_tipoparam_id;
   --
   return vn_valortipoparam_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_pessoa_valortipoparam_id:' || sqlerrm);
end fkg_pessoa_valortipoparam_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna o a informação do "CD" do Valor do Tipo de Parametro conforme o ID

function fkg_valortipoparam_id ( en_valortipoparam_id valor_tipo_param.id%type )
         return valor_tipo_param.cd%type
is
   --
   vv_valortipoparam_cd valor_tipo_param.cd%type := null;
   --
begin
   --
   select cd
     into vv_valortipoparam_cd
     from valor_tipo_param
    where id = en_valortipoparam_id;
   --
   return vv_valortipoparam_cd;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_valortipoparam_id:' || sqlerrm);
end fkg_valortipoparam_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna a informação do "código" do Valor do Tipo de Parametro conforme pessoa

function fkg_pessoa_valortipoparam_cd ( ev_tipoparam_cd in tipo_param.cd%type
                                      , en_pessoa_id    in pessoa.id%type
                                      )
         return valor_tipo_param.cd%type
is
   --
   vv_valortipoparam_cd valor_tipo_param.cd%type := null;
   vn_tipoparam_id tipo_param.id%type;
   vn_valortipoparam_id valor_tipo_param.id%type := null;
   --
begin
   -- pega o ID do tipo de parâmetro
   vn_tipoparam_id := fkg_tipoparam_id ( ev_cd => ev_tipoparam_cd );
   --
   -- pega o ID do valor do tipo de parâmetro salvo na pessoa
   vn_valortipoparam_id := fkg_pessoa_valortipoparam_id ( en_tipoparam_id => vn_tipoparam_id
                                                        , en_pessoa_id    => en_pessoa_id
                                                        );
   --
   -- Recupera o CD do Valor do parâmetro conforme o ID
   vv_valortipoparam_cd := fkg_valortipoparam_id ( en_valortipoparam_id => vn_valortipoparam_id );
   --
   return vv_valortipoparam_cd;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_pessoa_valortipoparam_cd:' || sqlerrm);
end fkg_pessoa_valortipoparam_cd;

-------------------------------------------------------------------------------------------------------

-- Retorna o CD do código de tributação do município, conforme o ID
function fkg_codtribmunicipio_cd ( en_codtribmunicipio_id in cod_trib_municipio.id%type )
         return cod_trib_municipio.cod_trib_municipio%type
is
   --
   vv_codtribmunicipio_cd  cod_trib_municipio.cod_trib_municipio%type;
   --
begin
   --
   select cod_trib_municipio
     into vv_codtribmunicipio_cd
     from cod_trib_municipio
    where id = en_codtribmunicipio_id;
   --
   return vv_codtribmunicipio_cd;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_codtribmunicipio_cd:' || sqlerrm);
end fkg_codtribmunicipio_cd;

-------------------------------------------------------------------------------------------------------

-- Retorna o ID do código de tributação do município, conforme o CD e Cidade
function fkg_codtribmunicipio_id ( ev_codtribmunicipio_cd  in cod_trib_municipio.cod_trib_municipio%type
                                 , en_cidade_id            in cod_trib_municipio.cidade_id%type
                                 )
         return cod_trib_municipio.id%type
is
   --
   vn_codtribmunicipio_id  cod_trib_municipio.id%type;
   --
begin
   --
   select min(id)
     into vn_codtribmunicipio_id
     from cod_trib_municipio
    where cod_trib_municipio = ev_codtribmunicipio_cd
      and cidade_id          = en_cidade_id;
   --
   return vn_codtribmunicipio_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_codtribmunicipio_id:' || sqlerrm);
end fkg_codtribmunicipio_id;

-------------------------------------------------------------------------------------------------------

--| Função retorma a descrição da cidade conforme o IBGE dela

function fkg_descr_cidade_conf_ibge ( ev_ibge_cidade  in cidade.ibge_cidade%type )
         return cidade.descr%type
is
   --
   vv_descr cidade.descr%type := null;
   --
begin
   --
   select descr
     into vv_descr
     from cidade
    where ibge_cidade = ev_ibge_cidade;
   --
   return vv_descr;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_descr_cidade_conf_ibge:' || sqlerrm);
end fkg_descr_cidade_conf_ibge;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do Tipo de Código de arquivo

function fkg_tipocodarq_id ( ev_cd in tipo_cod_arq.cd%type )
         return tipo_cod_arq.id%type
is
   --
   vn_tipocodarq_id tipo_cod_arq.id%type;
   --
begin
   --
   select id
     into vn_tipocodarq_id
     from tipo_cod_arq
    where cd = ev_cd;
   --
   return vn_tipocodarq_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_tipocodarq_id:' || sqlerrm);
end fkg_tipocodarq_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o código do "Tipo de Código de arquivo" por pais

function fkg_cd_pais_tipo_cod_arq ( en_pais_id        in pais.id%type
                                  , en_tipocodarq_id  in tipo_cod_arq.id%type
                                  )
         return pais_tipo_cod_arq.cd%type
is
   --
   vv_paistipocodarq_cd pais_tipo_cod_arq.cd%type;
   --
begin
   --
   select cd
     into vv_paistipocodarq_cd
     from pais_tipo_cod_arq
    where pais_id = en_pais_id
      and tipocodarq_id = en_tipocodarq_id;
   --
   return vv_paistipocodarq_cd;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_cd_pais_tipo_cod_arq:' || sqlerrm);
end fkg_cd_pais_tipo_cod_arq;

-------------------------------------------------------------------------------------------------------

-- Função retorna o código do "Tipo de Código de arquivo" por estado

function fkg_cd_estado_tipo_cod_arq ( en_estado_id in estado.id%type
                                    , en_tipocodarq_id in tipo_cod_arq.id%type
                                    )
         return estado_tipo_cod_arq.cd%type
is
   --
   vv_estadotipocodarq_cd estado_tipo_cod_arq.cd%type;
   --
begin
   --
   select cd
     into vv_estadotipocodarq_cd
     from estado_tipo_cod_arq
    where estado_id = en_estado_id
      and tipocodarq_id = en_tipocodarq_id;
   --
   return vv_estadotipocodarq_cd;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_cd_estado_tipo_cod_arq:' || sqlerrm);
end fkg_cd_estado_tipo_cod_arq;

-------------------------------------------------------------------------------------------------------

-- Função retorna o código do "Tipo de Código de arquivo" por cidade

function fkg_cd_cidade_tipo_cod_arq ( en_cidade_id in cidade.id%type
                                    , en_tipocodarq_id in tipo_cod_arq.id%type
                                    )
         return cidade_tipo_cod_arq.cd%type
is
   --
   vv_cidadetipocodarq_cd cidade_tipo_cod_arq.cd%type;
   --
begin
   --
   select cd
     into vv_cidadetipocodarq_cd
     from cidade_tipo_cod_arq
    where cidade_id = en_cidade_id
      and tipocodarq_id = en_tipocodarq_id;
   --
   return vv_cidadetipocodarq_cd;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_cd_cidade_tipo_cod_arq:' || sqlerrm);
end fkg_cd_cidade_tipo_cod_arq;

-------------------------------------------------------------------------------------------------------

 --| Função retorna o sigla_estado que está relacionado ao pessoa_id

function fkg_sigla_estado_empresa ( en_empresa_id in empresa.id%type )
         return estado.sigla_estado%type
is
   --
   vn_pessoa_id pessoa.id%type := null;
   vv_sigla_estado estado.sigla_estado%type := null;
   --
begin
   --
   begin
      --
      select pessoa_id
        into vn_pessoa_id
        from empresa
       where id = en_empresa_id;
      --
   exception
      when others then
         vn_pessoa_id := null;
   end;
   --
   if nvl(vn_pessoa_id,0) > 0 then
      --
      vv_sigla_estado := fkg_siglaestado_pessoaid ( en_pessoa_id => vn_pessoa_id );
      --
   end if;
   --
   return vv_sigla_estado;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_sigla_estado_empresa:' || sqlerrm);
end fkg_sigla_estado_empresa;
--
-- ==================================================================================================== --
-- Função verifica se cálcula ICMS-Normal para a Nota Fiscal conforme Empresa

function fkg_dm_nf_calc_icms_empresa ( en_empresa_id in empresa.id%type )
         return empresa.dm_nf_calc_icms%type
is
   --
   vn_dm_nf_calc_icms empresa.dm_nf_calc_icms%type;
   --
begin
   --
   select dm_nf_calc_icms
     into vn_dm_nf_calc_icms
     from empresa
    where id = en_empresa_id;
   --
   return vn_dm_nf_calc_icms;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_dm_nf_calc_icms_empresa:' || sqlerrm);
end fkg_dm_nf_calc_icms_empresa;

-------------------------------------------------------------------------------------------------------

--| Procedimento Copia o perfil de acesso de um usuário (papeis e empresas)

procedure pkb_copia_perfil_acesso_usu ( ev_login_origem   in  neo_usuario.login%type
                                      , ev_login_destino  in  neo_usuario.login%type
                                      )
is
   --
   --
begin
   --
   pkb_copia_perfil_usuario ( ev_login_origem   => ev_login_origem
                            , ev_login_destino  => ev_login_destino
                            );
   --
   pkb_copia_empresa_usuario ( ev_login_origem   => ev_login_origem
                             , ev_login_destino  => ev_login_destino
                             );
   --
exception
   when others then
      null;
end pkb_copia_perfil_acesso_usu;

-------------------------------------------------------------------------------------------------------

-- Função retorna o valor do parâmetro "Ajusta valores dos itens da NF com o Total" conforme empresa

function fkg_ajustvlr_inf_conf_empresa ( en_empresa_id in empresa.id%type )
         return empresa.dm_ajust_vlr_itemnf%type
is
   --
   vn_dm_ajust_vlr_itemnf empresa.dm_ajust_vlr_itemnf%type := null;
   --
begin
   --
   select dm_ajust_vlr_itemnf
     into vn_dm_ajust_vlr_itemnf
     from empresa
    where id = en_empresa_id;
   --
   return vn_dm_ajust_vlr_itemnf;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_ajustvlr_inf_conf_empresa:' || sqlerrm);
end fkg_ajustvlr_inf_conf_empresa;

-------------------------------------------------------------------------------------------------------

-- Função retorna o valor do parâmetro "Integra o Item (produto/serviço)" conforme empresa

function fkg_integritem_conf_empresa ( en_empresa_id in empresa.id%type )
         return empresa.dm_integr_item%type
is
   --
   vn_dm_integr_item empresa.dm_integr_item%type := null;
   --
begin
   --
   select dm_integr_item
     into vn_dm_integr_item
     from empresa
    where id = en_empresa_id;
   --
   return vn_dm_integr_item;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_integritem_conf_empresa:' || sqlerrm);
end fkg_integritem_conf_empresa;

-------------------------------------------------------------------------------------------------------

-- Função retorna parâmetro de validação de CFOP por destinatário - conforme o identificador da empresa.

function fkg_dm_valcfoppordest_empresa ( en_empresa_id in empresa.id%type )
         return empresa.dm_valida_cfop_por_dest%type
is
   --
   vn_dm_valida_cfop_por_dest empresa.dm_valida_cfop_por_dest%type := null;
   --
begin
   --
   select em.dm_valida_cfop_por_dest
     into vn_dm_valida_cfop_por_dest
     from empresa em
    where em.id = en_empresa_id;
   --
   return vn_dm_valida_cfop_por_dest;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_dm_valcfoppordest_empresa:' || sqlerrm);
end fkg_dm_valcfoppordest_empresa;

-------------------------------------------------------------------------------------------------------

-- Função para retornar indicador de operação da nota fiscal - nota_fiscal.dm_ind_oper -> 0-entrada, 1-saída.

function fkg_recup_dmindoper_nf_id ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal.dm_ind_oper%type
is
   --
   vn_dm_ind_oper nota_fiscal.dm_ind_oper%type := null;
   --
begin
   --
   select nf.dm_ind_oper
     into vn_dm_ind_oper
     from nota_fiscal nf
    where nf.id = en_notafiscal_id;
   --
   return vn_dm_ind_oper;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_recup_dmindoper_nf_id:' || sqlerrm);
end fkg_recup_dmindoper_nf_id;

-------------------------------------------------------------------------------------------------------

-- Retorna o E-mail do usuário do Sistema conforme multorg_id e ID_ERP

function fkg_usuario_email_conf_erp ( en_multorg_id in mult_org.id%type
                                    , ev_id_erp     in neo_usuario.id_erp%type
                                    ) return neo_usuario.email%type
is
   --
   vv_email neo_usuario.email%type   := null;
   vv_id_erp neo_usuario.id_erp%type := null;
   --
begin
   --
   vv_id_erp := trim( pk_csf.fkg_converte( ev_id_erp ) );
   --
   if vv_id_erp is not null then
      --
      begin
         select email
           into vv_email
           from neo_usuario
          where multorg_id  = en_multorg_id
            and id_erp      = vv_id_erp;
      exception
         when no_data_found then
            -- Foi incluida essa nova verificacao em funcao do campo id_erp na integracao receber o vlr do login 
            -- Nos casos de cadastro manual de usuario o campo id_erp pode ficar nulo, nao retornando o email
            begin
               select email
                 into vv_email
                 from neo_usuario
                where multorg_id  = en_multorg_id
                  and login       = vv_id_erp;
            exception
               when others then
                  return (null);
            end;
      end;
      --
   end if;
   --
   return vv_email;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_usuario_email_conf_erp:' || sqlerrm);
end fkg_usuario_email_conf_erp;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o identificador do modelo fiscal da nota fiscal - nota_fiscal.modfiscal_id - através do identificador da nota fiscal.

function fkg_recup_modfisc_id_nf ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal.modfiscal_id%type is
   --
   vn_modfiscal_id nota_fiscal.modfiscal_id%type := null;
   --
begin
   --
   select nf.modfiscal_id
     into vn_modfiscal_id
     from nota_fiscal nf
    where nf.id = en_notafiscal_id;
   --
   return vn_modfiscal_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_recup_modfisc_id_nf:' || sqlerrm);
end fkg_recup_modfisc_id_nf;

-------------------------------------------------------------------------------------------------------

-- Função recupera a Ordem de impressão dos itens na DANFE na empresa

function fkg_dm_ordimpritemdanfe_empr ( en_empresa_id empresa.id%type )
         return empresa.dm_ord_impr_item_danfe%type
is
   --
   vn_dm_ord_impr_item_danfe empresa.dm_ord_impr_item_danfe%type;
   --
begin
   --
   select dm_ord_impr_item_danfe
     into vn_dm_ord_impr_item_danfe
     from empresa
    where id = en_empresa_id;
   --
   return vn_dm_ord_impr_item_danfe;
   --
exception
   when no_data_found then
      return 1;
   when others then
      raise_application_error(-20101, 'Erro na fkg_dm_ordimpritemdanfe_empr:' || sqlerrm);
end fkg_dm_ordimpritemdanfe_empr;

-------------------------------------------------------------------------------------------------------

-- Função para retornar se a empresa permite validação de cfop de crédito de pis/cofins para notas fiscais de pessoa física (0-não, 1-sim).

function fkg_empr_val_cred_pf_pc ( en_empresa_id in empresa.id%type )
         return empresa.dm_val_gera_cred_pf_pc%type
is
   --
   vn_dm_val_gera_cred_pf_pc empresa.dm_val_gera_cred_pf_pc%type;
   --
begin
   --
   select dm_val_gera_cred_pf_pc
     into vn_dm_val_gera_cred_pf_pc
     from empresa
    where id = en_empresa_id;
   --
   return vn_dm_val_gera_cred_pf_pc;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_empr_val_cred_pf_pc:' || sqlerrm);
end fkg_empr_val_cred_pf_pc;

-------------------------------------------------------------------------------------------------------

-- Função para retornar se a empresa permite Ajustar base de cálculo de imposto

function fkg_empr_ajust_base_imp ( en_empresa_id in empresa.id%type )
         return empresa.dm_ajust_base_imp%type
is
   --
   vn_dm_ajust_base_imp  empresa.dm_ajust_base_imp%type;
   --
begin
   --
   select dm_ajust_base_imp
     into vn_dm_ajust_base_imp
     from empresa
    where id = en_empresa_id;
   --
   return vn_dm_ajust_base_imp;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_empr_ajust_base_imp:' || sqlerrm);
end fkg_empr_ajust_base_imp;

-------------------------------------------------------------------------------------------------------

--|Função retorna ibge_estado conforme o empresa_id

function fkg_ibge_estado_empresa_id ( ev_empresa_id  in empresa.id%type )
         return estado.ibge_estado%type
is
   --
   vn_ibge_estado  estado.ibge_estado%type := null;
   --
begin
   --
    select es.ibge_estado
        into vn_ibge_estado
        from Estado    es
           , Empresa   e
           , Pessoa    p
           , Cidade    c
       where e.id = ev_empresa_id
        and  e.pessoa_id  = p.id
        and  p.cidade_id  = c.id
        and  c.estado_id  = es.id;
   --
   return vn_ibge_estado;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_ibge_estado_empresa_id:' || sqlerrm);
end fkg_ibge_estado_empresa_id;

-------------------------------------------------------------------------------------------------------

-- Função para verificar campos Flex Field - FF.

function fkg_ff_verif_campos( ev_obj_name in obj_util_integr.obj_name%type
                            , ev_atributo in ff_obj_util_integr.atributo%type
                            , ev_valor    in varchar2 )
         return varchar2
is
   --
   vn_dm_tipo_campo  ff_obj_util_integr.dm_tipo_campo%type;
   vd_data           date;
   vn_valor          number;
   vn_nro_divide     number;
   vn_tamanho        ff_obj_util_integr.tamanho%type;
   vn_decimal        ff_obj_util_integr.qtde_decimal%type;
   vv_mensagem       varchar2(1000) := null;
   vv_valor          varchar2(600);
   --
begin
   --
   begin
      select ff.dm_tipo_campo
           , ff.tamanho
           , ff.qtde_decimal
        into vn_dm_tipo_campo
           , vn_tamanho
           , vn_decimal
        from obj_util_integr    ou
           , ff_obj_util_integr ff
       where ou.obj_name         = ev_obj_name
         and ff.objutilintegr_id = ou.id
         and ff.atributo         = ev_atributo;
   exception
      when no_data_found then
         vv_mensagem := substr('Tabela/View - '||upper(ev_obj_name)||'. Atributo ('||ev_atributo||') não cadastrado como campo Flex Field.',1,1000);
      when others then
         vv_mensagem := substr('Problemas ao encontrar atributo ('||ev_atributo||') no cadastro. Tabela/View - '||upper(ev_obj_name)||'. Erro = '||sqlerrm,1,1000);
   end;
   --
   if vv_mensagem is null then
      --
      vv_valor := replace((replace(ev_valor, ',', '')), '.', '');
      --
      if vn_dm_tipo_campo = 0 then -- tipo = data
         --
         begin
            vd_data := to_date(vv_valor,'dd/mm/rrrr');
         exception
            when others then
               vv_mensagem := substr('Tabela/View - '||upper(ev_obj_name)||'. Atributo ('||ev_atributo||') cadastrado como tipo de campo DATA e o '||
                              'formato deve ser DD/MM/RRRR. Verifique o valor informado ('||vv_valor||').',1,1000);
         end;
         --
      elsif vn_dm_tipo_campo = 1 then -- tipo = numérico
            --
            if length(vv_valor) > vn_tamanho then
               --
               vv_mensagem := substr('Tabela/View - '||upper(ev_obj_name)||'. Atributo ('||ev_atributo||') cadastrado como tipo de campo NUMÉRICO e o '||
                              'tamanho deve ser igual a '||vn_tamanho||'. Verifique o valor informado ('||vv_valor||').',1,1000);
               --
            else
               --
               if vn_decimal = 0 then
                  vn_nro_divide := 1;
               else -- vn_decimal > 0
                  -- decimal + 1: serve para deixar o valor 1 concatenado com zeros, de acordo com o tamanho que está cadastrado no decimal
                  vn_nro_divide := to_number(rpad('1',(vn_decimal + 1),'0'));
               end if;
               --
               begin
                  vn_valor := (to_number(vv_valor) / vn_nro_divide);
               exception
                  when others then
                     vv_mensagem := substr('Tabela/View - '||upper(ev_obj_name)||'. Atributo ('||ev_atributo||') cadastrado como tipo de campo NUMÉRICO e o '||
                                    'formato deve ser total = '||vn_tamanho||' e com quantidade de casas decimais = '||vn_decimal||
                                    '. Verifique o valor informado ('||vv_valor||').',1,1000);
               end;
               --
            end if;
            --
      elsif vn_dm_tipo_campo = 2 then -- tipo = caractere
            --
            if length(vv_valor) > vn_tamanho then
               vv_mensagem := substr('Tabela/View - '||upper(ev_obj_name)||'. Atributo ('||ev_atributo||') cadastrado como tipo de campo CARACTERE e o '||
                              'tamanho deve ser menor ou igual a '||vn_tamanho||'. Verifique o valor informado ('||vv_valor||').',1,1000);
            end if;
            --
      else
         vv_mensagem := substr('Atributo ('||ev_atributo||'), tabela/view '||upper(ev_obj_name)||' - com tipo de campo indefinido.',1,1000);
      end if;
      --
   end if;
   --
   return vv_mensagem;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro em fkg_ff_verif_campos:' || sqlerrm);
end fkg_ff_verif_campos;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o tipo do campo Flex Field - FF.

function fkg_ff_retorna_dmtipocampo( ev_obj_name in obj_util_integr.obj_name%type
                                   , ev_atributo in ff_obj_util_integr.atributo%type )
         return ff_obj_util_integr.dm_tipo_campo%type
is
   --
   vn_dm_tipo_campo ff_obj_util_integr.dm_tipo_campo%type;
   --
begin
   --
   begin
      select ff.dm_tipo_campo
        into vn_dm_tipo_campo
        from obj_util_integr    ou
           , ff_obj_util_integr ff
       where ou.obj_name         = ev_obj_name
         and ff.objutilintegr_id = ou.id
         and ff.atributo         = ev_atributo;
   exception
      when others then
         vn_dm_tipo_campo := null;
   end;
   --
   return vn_dm_tipo_campo;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro em fkg_ff_retorna_dmtipocampo:' || sqlerrm);
end fkg_ff_retorna_dmtipocampo;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o tamanho do campo Flex Field - FF, através do objeto e do atributo.

function fkg_ff_retorna_tamanho( ev_obj_name in obj_util_integr.obj_name%type
                               , ev_atributo in ff_obj_util_integr.atributo%type )
         return ff_obj_util_integr.tamanho%type
is
   --
   vn_tamanho ff_obj_util_integr.tamanho%type;
   --
begin
   --
   begin
      select ff.tamanho
        into vn_tamanho
        from obj_util_integr    ou
           , ff_obj_util_integr ff
       where ou.obj_name         = ev_obj_name
         and ff.objutilintegr_id = ou.id
         and ff.atributo         = ev_atributo;
   exception
      when others then
         vn_tamanho := null;
   end;
   --
   return vn_tamanho;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro em fkg_ff_retorna_tamanho:' || sqlerrm);
end fkg_ff_retorna_tamanho;

-------------------------------------------------------------------------------------------------------

-- Função para retornar a quantidade em decimal do campo Flex Field - FF, através do objeto e do atributo.

function fkg_ff_retorna_decimal( ev_obj_name in obj_util_integr.obj_name%type
                               , ev_atributo in ff_obj_util_integr.atributo%type )
         return ff_obj_util_integr.qtde_decimal%type
is
   --
   vn_decimal ff_obj_util_integr.qtde_decimal%type;
   --
begin
   --
   begin
      select ff.qtde_decimal
        into vn_decimal
        from obj_util_integr    ou
           , ff_obj_util_integr ff
       where ou.obj_name         = ev_obj_name
         and ff.objutilintegr_id = ou.id
         and ff.atributo         = ev_atributo;
   exception
      when others then
         vn_decimal := null;
   end;
   --
   return vn_decimal;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro em fkg_ff_retorna_decimal:' || sqlerrm);
end fkg_ff_retorna_decimal;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o valor dos campos Flex Field - FF - tipo DATA.

function fkg_ff_ret_vlr_data( ev_obj_name in obj_util_integr.obj_name%type
                            , ev_atributo in varchar2
                            , ev_valor    in varchar2 )
         return date
is
   --
   vd_data date;
   --
begin
   --
   begin
      vd_data := to_date(ev_valor,'dd/mm/rrrr');
   exception
      when others then
         raise_application_error(-20101, substr('Tabela/View - '||upper(ev_obj_name)||'. Atributo ('||ev_atributo||') cadastrado como tipo de campo DATA e o '||
                                         'formato deve ser DD/MM/RRRR. Valor informado incorretamente ('||ev_valor||').',1,1000));
   end;
   --
   return vd_data;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro em fkg_ff_ret_vlr_data:' || sqlerrm);
end fkg_ff_ret_vlr_data;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o valor dos campos Flex Field - FF - tipo NUMÉRICO.

function fkg_ff_ret_vlr_number( ev_obj_name in obj_util_integr.obj_name%type
                              , ev_atributo in varchar2
                              , ev_valor    in varchar2 )
         return number
is
   --
   vn_decimal    number;
   vn_nro_divide number;
   vn_number     number;
   --
begin
   --
   vn_decimal := pk_csf.fkg_ff_retorna_decimal( ev_obj_name => ev_obj_name
                                              , ev_atributo => ev_atributo );
   --
   if vn_decimal = 0 then
      vn_nro_divide := 1;
   else -- vn_decimal > 0
      -- decimal + 1: serve para deixar o valor 1 concatenado com zeros, de acordo com o tamanho que está cadastrado no decimal
      vn_nro_divide := to_number(rpad('1',(vn_decimal + 1),'0'));
   end if;
   --
   if ev_valor is not null then
      --
      begin
         vn_number := (to_number(replace((replace(ev_valor, ',', '')), '.', '')) / vn_nro_divide);
      exception
         when others then
            raise_application_error(-20101, substr('Tabela/View - '||upper(ev_obj_name)||'. Atributo ('||ev_atributo||') cadastrado como tipo de campo NUMÉRICO '||
                                         'com quantidade de casas decimais = '||vn_decimal||'. Valor informado incorretamente ('||ev_valor||').',1,1000));
      end;
      --
   end if;
   --
   return vn_number;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro em fkg_ff_ret_vlr_number:' || sqlerrm);
end fkg_ff_ret_vlr_number;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o valor dos campos Flex Field - FF - tipo CARACTERE.

function fkg_ff_ret_vlr_caracter( ev_obj_name in obj_util_integr.obj_name%type
                                , ev_atributo in varchar2
                                , ev_valor    in varchar2 )
         return varchar2
is
   --
   vv_caracter varchar2(600);
   --
begin
   --
   vv_caracter := ev_valor;
   --
   return vv_caracter;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro em fkg_ff_ret_vlr_caracter:' || sqlerrm);
end fkg_ff_ret_vlr_caracter;

-------------------------------------------------------------------------------------------------------

-- Função retorno o CPF ou CNPJ com mascara

function fkg_masc_cpf_cnpj ( ev_cpf_cnpj in varchar2 )
         return varchar2
is
   --
   vv_cpf_cnpj_masc varchar2(100) := null;
   --
begin
   --
   if length(ev_cpf_cnpj) = 11 then -- mascara do CPF
      --
      vv_cpf_cnpj_masc := substr(ev_cpf_cnpj, 1, 3) || '.' || substr(ev_cpf_cnpj, 4, 3) || '.' || substr(ev_cpf_cnpj, 7, 3) || '-' || substr(ev_cpf_cnpj, 10, 2);
      --
   elsif length(ev_cpf_cnpj) = 14 then -- mascara do CNPJ
      --
      vv_cpf_cnpj_masc := substr(ev_cpf_cnpj, 1, 2) || '.' || substr(ev_cpf_cnpj, 3, 3) || '.' || substr(ev_cpf_cnpj, 6, 3) || '/' || substr(ev_cpf_cnpj, 9, 4) || '-' || substr(ev_cpf_cnpj, 13, 2);
      --
   else
      vv_cpf_cnpj_masc := ev_cpf_cnpj;
   end if;
   --
   return vv_cpf_cnpj_masc;
   --
exception
   when others then
      return ev_cpf_cnpj;
end fkg_masc_cpf_cnpj;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do Tipo de Operacao do CFOP

function fkg_tipooperacao_id ( ev_id in tipo_operacao.id%type )
         return tipo_operacao.cd%type
is
   --
   vn_tipooperacao tipo_operacao.cd%type;
   --
begin
   --
   select cd
     into vn_tipooperacao
     from tipo_operacao
    where id = ev_id;
   --
   return vn_tipooperacao;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_tipooperacao_id:' || sqlerrm);
end fkg_tipooperacao_id;

-------------------------------------------------------------------------------------------------------

-- Função retornda o CD do Tipo de Operação conforme CD do CFOP
function fkg_cd_tipooper_conf_cfop ( ev_cfop_cd in cfop.cd%type )
         return tipo_operacao.cd%type
is
   --
   vn_tipooperacao_id tipo_operacao.id%type := null;
   --
   vn_tipooperacao_cd tipo_operacao.cd%type := null;
   --
begin
   --
   select tipooperacao_id
     into vn_tipooperacao_id
     from cfop
    where cd = ev_cfop_cd;
   --
   vn_tipooperacao_cd := pk_csf.fkg_tipooperacao_id ( ev_id => vn_tipooperacao_id );
   --
   return vn_tipooperacao_cd;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_cd_tipooper_conf_cfop:' || sqlerrm);
end fkg_cd_tipooper_conf_cfop;

-------------------------------------------------------------------------------------------------------

-- Função verifica o tipo de formato de data do retorno da informação para o ERP

function fkg_empresa_dm_form_dt_erp ( en_empresa_id in Empresa.id%type )
         return empresa.dm_form_dt_erp%type
is

   vn_dm_form_dt_erp           empresa.dm_form_dt_erp%type;

begin
   --
   select e.dm_form_dt_erp
     into vn_dm_form_dt_erp
     from empresa e
    where e.id = en_empresa_id;
   --
   return vn_dm_form_dt_erp;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_dm_form_dt_erp:' || sqlerrm);
end fkg_empresa_dm_form_dt_erp;

-------------------------------------------------------------------------------------------------------

-- Função retorna código da conta do plano de contas através do ID do Plano de Conta

function fkg_cd_plano_conta ( en_planoconta_id in plano_conta.id%type )
         return plano_conta.cod_cta%type
is
   --
   vv_cod_cta plano_conta.cod_cta%type := null;
   --
begin
   --
   if nvl(en_planoconta_id,0) > 0 then
      --
      begin
         select pc.cod_cta
           into vv_cod_cta
           from plano_conta pc
          where pc.id = en_planoconta_id;
      exception
         when no_data_found then
            vv_cod_cta := null;
         when others then
            raise_application_error(-20101, 'Problemas ao recuperar código do plano de contas (id='||en_planoconta_id||'). Erro = '||sqlerrm);
      end;
      --
    end if;
   --
   return vv_cod_cta;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_cd_plano_conta: '||sqlerrm);
end fkg_cd_plano_conta;

-------------------------------------------------------------------------------------------------------

-- Função retorna código do centro de custo através do ID do Centro de Custo

function fkg_cd_centro_custo ( en_centrocusto_id in centro_custo.id%type )
         return centro_custo.cod_ccus%type
is
   --
   vv_cod_ccus centro_custo.cod_ccus%TYPE;
   --
begin
   --
   if nvl(en_centrocusto_id,0) > 0 then
      --
      begin
         select cc.cod_ccus
           into vv_cod_ccus
           from centro_custo cc
          where cc.id = en_centrocusto_id;
      exception
         when no_data_found then
            vv_cod_ccus := null;
         when others then
            raise_application_error(-20101, 'Problemas ao recuperar código do centro de custo (id='||en_centrocusto_id||'). Erro = '||sqlerrm);
      end;
      --
    end if;
   --
   return vv_cod_ccus;
   --
exception
   when no_data_found then
      return (null);
   when too_many_rows then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_cd_centro_custo:' || sqlerrm);
end fkg_cd_centro_custo;

-------------------------------------------------------------------------------------------------------

-- Função retorna o identificador do objeto de integração através do código
function fkg_recup_objintegr_id( ev_cd in obj_integr.cd%type )
         return obj_integr.id%type
is
   --
   vn_objintegr_id obj_integr.id%type;
   --
begin
   --
   if ev_cd is not null then
      --
      begin
         select oi.id
           into vn_objintegr_id
           from obj_integr oi
          where oi.cd = ev_cd;
      exception
         when no_data_found then
            vn_objintegr_id := null;
         when others then
            raise_application_error(-20101, 'Problemas ao recuperar identificador do objeto de integração (cd='||ev_cd||'). Erro = '||sqlerrm);
      end;
      --
    end if;
   --
   return vn_objintegr_id;
   --
exception
   when no_data_found then
      return (null);
   when too_many_rows then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_recup_objintegr_id:' || sqlerrm);
end fkg_recup_objintegr_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do tabela TIPO_OBJ_INTEGR, conforme OBJINTEGR_ID e Código

function fkg_tipoobjintegr_id ( en_objintegr_id      in tipo_obj_integr.objintegr_id%type
                              , ev_tipoobjintegr_cd  in tipo_obj_integr.cd%type
                              )
         return tipo_obj_integr.id%type
is
   --
   vn_tipoobjintegr_id tipo_obj_integr.id%type;
   --
begin
   --
   select id
     into vn_tipoobjintegr_id
     from tipo_obj_integr
    where objintegr_id = en_objintegr_id
      and cd           = ev_tipoobjintegr_cd;
   --
   return vn_tipoobjintegr_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_tipoobjintegr_id:' || sqlerrm);
end fkg_tipoobjintegr_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o CD do tabela TIPO_OBJ_INTEGR, conforme ID

function fkg_tipoobjintegr_cd ( en_tipoobjintegr_id  in tipo_obj_integr.id%type
                              )
         return tipo_obj_integr.cd%type
is
   --
   vv_tipoobjintegr_cd  tipo_obj_integr.cd%type;
   --
begin
   --
   select cd
     into vv_tipoobjintegr_cd
     from tipo_obj_integr
    where id = en_tipoobjintegr_id;
   --
   return vv_tipoobjintegr_cd;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_tipoobjintegr_cd:' || sqlerrm);
end fkg_tipoobjintegr_cd;

-------------------------------------------------------------------------------------------------------

-- Função retorna a última data de fechamento fiscal por empresa

function fkg_recup_dtult_fecha_empresa( en_empresa_id   in fecha_fiscal_empresa.empresa_id%type
                                      , en_objintegr_id in fecha_fiscal_empresa.objintegr_id%type )
         return fecha_fiscal_empresa.dt_ult_fecha%type
is
   --
   vd_dt_ult_fecha fecha_fiscal_empresa.dt_ult_fecha%type;
   --
begin
   --
   if nvl(en_empresa_id,0) > 0 and
      nvl(en_objintegr_id,0) > 0 then
      --
      begin
         select ff.dt_ult_fecha
           into vd_dt_ult_fecha
           from fecha_fiscal_empresa ff
          where ff.empresa_id   = en_empresa_id
            and ff.objintegr_id = en_objintegr_id;
      exception
         when no_data_found then
            vd_dt_ult_fecha := null;
         when others then
            raise_application_error(-20101, 'Problemas ao recuperar data de último fechamento fiscal (empresa_id='||en_empresa_id||
                                            ' objintegr_id = '||en_objintegr_id||'). Erro = '||sqlerrm);
      end;
      --
    end if;
   --
   return vd_dt_ult_fecha;
   --
exception
   when no_data_found then
      return (null);
   when too_many_rows then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_recup_dtult_fecha_empresa:' || sqlerrm);
end fkg_recup_dtult_fecha_empresa;

-------------------------------------------------------------------------------------------------------

-- Função retorna se o período informado está fechado - fechamento fiscal por empresa - 0-não ou 1-sim
function fkg_periodo_fechado_empresa( en_empresa_id   in fecha_fiscal_empresa.empresa_id%type
                                    , en_objintegr_id in fecha_fiscal_empresa.objintegr_id%type
                                    , ed_dt_ult_fecha in fecha_fiscal_empresa.dt_ult_fecha%type )
         return number
is
   --
   vn_per_fechado number := 0; -- 0-não, 1-sim
   --
begin
   --
   if nvl(en_empresa_id,0) > 0 and
      nvl(en_objintegr_id,0) > 0 and
      ed_dt_ult_fecha is not null then
      --
      begin
         select 1 -- 0-não, 1-sim
           into vn_per_fechado
           from fecha_fiscal_empresa ff
          where ff.empresa_id    = en_empresa_id
            and ff.objintegr_id  = en_objintegr_id
            and ff.dt_ult_fecha >= ed_dt_ult_fecha;
      exception
         when no_data_found then
            vn_per_fechado := 0; -- 0-não, 1-sim
         when others then
            raise_application_error(-20101, 'Problemas ao verificar se o período enviado está fechado - fechamento fiscal (empresa_id='||en_empresa_id||
                                            ' objintegr_id = '||en_objintegr_id||' data = '||to_char(ed_dt_ult_fecha,'dd/mm/yyyy')||'). Erro = '||sqlerrm);
      end;
      --
    end if;
   --
   return vn_per_fechado;
   --
exception
   when no_data_found then
      return (0); -- 0-não, 1-sim
   when too_many_rows then
      return (1); -- 0-não, 1-sim
   when others then
      raise_application_error(-20101, 'Erro na fkg_periodo_fechado_empresa:' || sqlerrm);
end fkg_periodo_fechado_empresa;

-------------------------------------------------------------------------------------------------------
--| Função verifica se existe o ID do Complemento do Item

function fkg_existe_item_compl ( en_inf_item_compl_id in item_compl.item_id%type )
         return boolean
is

    vn_dummy number := 0;

begin
    --
    select 1
      into vn_dummy
      from item_compl
     where item_id = en_inf_item_compl_id;
    --
    if nvl(vn_dummy,0) > 0 then
       return true;
    else
       return false;
    end if;
    --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_item_compl: ' || sqlerrm);
end fkg_existe_item_compl;
--
-- ========================================================================================================== --
--| Função para recuperar as pessoas de mesmo cpf ou cnpj
--
function fkg_ret_string_id_pessoa ( en_multorg_id  in mult_org.id%type
                                  , ev_cpf_cnpj    in varchar2
                                  ) return varchar2 is
   --
   vv_string varchar2(1000) := null;
   --
   cursor c_juridica is
      select ju.pessoa_id
        from pessoa   p
           , juridica ju
       where p.multorg_id = en_multorg_id
         and ju.pessoa_id = p.id
         and (lpad(ju.num_cnpj,8,'0')||lpad(ju.num_filial,4,'0')||lpad(ju.dig_cnpj,2,'0')) = ev_cpf_cnpj;
   --
   cursor c_fisica is
      select fi.pessoa_id
        from pessoa p
           , fisica fi
       where p.multorg_id = en_multorg_id
         and fi.pessoa_id = p.id
         and (lpad(fi.num_cpf,9,'0')||lpad(fi.dig_cpf,2,'0')) = ev_cpf_cnpj;
   --
begin
   --
   -- NÃO ALTERE A REGRA DESSAS ROTINAS SEM CONVERSAR COM EQUIPE
   --
   for r_reg in c_juridica
   loop
      --
      exit when c_juridica%notfound or (c_juridica%notfound) is null;
      --
      if vv_string is null then
         vv_string := r_reg.pessoa_id;
      else
         vv_string := vv_string||','||r_reg.pessoa_id;
      end if;
      --
   end loop;
   --
   for r_reg in c_fisica
   loop
      --
      exit when c_fisica%notfound or (c_fisica%notfound) is null;
      --
      if vv_string is null then
         vv_string := r_reg.pessoa_id;
      else
         vv_string := vv_string||','||r_reg.pessoa_id;
      end if;
      --
   end loop;
   --
   return vv_string;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_ret_string_id_pessoa: ' || sqlerrm);
end fkg_ret_string_id_pessoa;
--
-- ========================================================================================================== --
-- Função retorna o ID do Valor do Tipo de Parâmetro

function fkg_valor_tipo_param_id ( en_tipoparam_id          in tipo_param.id%type
                                 , ev_valor_tipo_param_cd   in valor_tipo_param.cd%type
                                 )
         return valor_tipo_param.id%type
is
   --
   vn_valortipoparam_id valor_tipo_param.id%type;
   --
begin
   --
   select id
     into vn_valortipoparam_id
     from valor_tipo_param
    where tipoparam_id  = en_tipoparam_id
      and cd            = trim(ev_valor_tipo_param_cd);
   --
   return vn_valortipoparam_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_valor_tipo_param_id: ' || sqlerrm);
end fkg_valor_tipo_param_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do parâmetro de pessoa

function fkg_pessoa_tipo_param_id ( en_pessoa_id          in pessoa.id%type
                                  , en_tipoparam_id       in tipo_param.id%type
                                  , en_valortipoparam_id  in valor_tipo_param.id%type
                                  )
         return pessoa_tipo_param.id%Type
is
   --
   vn_pessoatipoparam_id pessoa_tipo_param.id%type;
   --
begin
   --
   select id
     into vn_pessoatipoparam_id
     from pessoa_tipo_param
    where pessoa_id          = en_pessoa_id
      and tipoparam_id       = en_tipoparam_id
      and valortipoparam_id  = en_valortipoparam_id;
   --
   return vn_pessoatipoparam_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_ret_string_id_pessoa: ' || sqlerrm);
end fkg_pessoa_tipo_param_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o valor do campo DM_TROCA_CFOP_NF por empresa

function fkg_empresa_troca_cfop_nf ( en_empresa_id in empresa.id%type )
         return empresa.dm_troca_cfop_nf%type
is
   --
   vn_dm_troca_cfop_nf empresa.dm_troca_cfop_nf%type;
   --
begin
   --
   select dm_troca_cfop_nf
     into vn_dm_troca_cfop_nf
     from empresa
    where id = en_empresa_id;
   --
   return vn_dm_troca_cfop_nf;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_troca_cfop_nf: ' || sqlerrm);
end fkg_empresa_troca_cfop_nf;

-------------------------------------------------------------------------------------------------------

--| Função retorna "true" se o item_id é válido e "false" se não é

function fkg_item_ncm_valido ( en_item_id  in item.id%type )
         return boolean
is
   --
   vn_dummy number := 0;
   --
begin
   --
   if nvl(en_item_id,0) > 0 then
      --
      select 1
        into vn_dummy
        from item ie
           , ncm  nc
       where ie.id = en_item_id
         and nc.id = ie.ncm_id;
      --
   end if;
   --
   if nvl(vn_dummy,0) > 0 then
      return true;
   else
      return false;
   end if;
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_item_ncm_valido:' || sqlerrm);
end fkg_item_ncm_valido;

-------------------------------------------------------------------------------------------------------

--| Função retorna o identificador do NCM através do identificador do Item do produto

function fkg_ncm_id_item ( en_item_id  in item.id%type )
         return ncm.id%type
is
   --
   vn_ncm_id  ncm.id%type := 0;
   --
begin
   --
   if nvl(en_item_id,0) > 0 then
      --
      begin
         select ie.ncm_id
           into vn_ncm_id
           from item ie
              , ncm  nc
          where ie.id = en_item_id
            and nc.id = ie.ncm_id;
      exception
         when others then
            vn_ncm_id := null;
      end;
      --
   end if;
   --
   return vn_ncm_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_ncm_id_item:' || sqlerrm);
end fkg_ncm_id_item;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela TIPO_RET_IMP

function fkg_tipo_ret_imp ( en_multorg_id  in tipo_ret_imp.multorg_id%TYPE
                          , en_cd_ret      in tipo_ret_imp.cd%TYPE
                          , en_tipoimp_id  in tipo_imposto.id%TYPE
                          )
         return tipo_ret_imp.id%TYPE
is

   vn_tiporetimp_id  tipo_ret_imp.id%TYPE;

begin

   select id
     into vn_tiporetimp_id
     from tipo_ret_imp
    where cd = en_cd_ret
      and tipoimp_id = en_tipoimp_id
      and multorg_id = en_multorg_id;

   return vn_tiporetimp_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_tipo_ret_imp:' || sqlerrm);
end fkg_tipo_ret_imp;
--
-- =============================================================================================== --
--| Função retorna o ID da tabela TIPO_RET_IMP_RECEITA

function fkg_tipo_ret_imp_rec ( en_cod_receita   in tipo_ret_imp_receita.cod_receita%TYPE
                              , en_tiporetimp_id in tipo_ret_imp_receita.tiporetimp_id%TYPE
                              ) return tipo_ret_imp_receita.id%TYPE
is
   --
   vn_tiporetimpreceita_id  tipo_ret_imp_receita.id%TYPE;
   --
begin
   --
   select a.id
     into vn_tiporetimpreceita_id
     from tipo_ret_imp_receita a
    where a.tiporetimp_id = en_tiporetimp_id
      and a.cod_receita   = en_cod_receita;
   --
   return vn_tiporetimpreceita_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_tipo_ret_imp_rec:' || sqlerrm);
end fkg_tipo_ret_imp_rec;
--
-- =============================================================================================== --
--| Função retorna o COD_RECEITA da tabela TIPO_RET_IMP_RECEITA

function fkg_tipo_ret_imp_rec_cd ( en_tiporetimpreceita_id in tipo_ret_imp_receita.id%TYPE
                                 , en_tiporetimp_id        in tipo_ret_imp_receita.tiporetimp_id%TYPE
                                 ) return tipo_ret_imp_receita.cod_receita%TYPE
is
   --
   vv_cod_receita  tipo_ret_imp_receita.cod_receita%TYPE;
   --
begin
   --
   select a.cod_receita
     into vv_cod_receita
     from tipo_ret_imp_receita a
    where a.tiporetimp_id =  en_tiporetimp_id
      and a.id            =  en_tiporetimpreceita_id;
   --
   return vv_cod_receita;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_tipo_ret_imp_rec_cd:' || sqlerrm);
end fkg_tipo_ret_imp_rec_cd;
--
-- =============================================================================================== --
--| Função retorna o código do tipo de retenção do imposto através do id

function fkg_tipo_ret_imp_cd ( en_tiporetimp_id  in tipo_ret_imp.id%TYPE )
         return tipo_ret_imp.cd%TYPE
is

   vv_tiporetimp_cd  tipo_ret_imp.cd%TYPE;

begin

   if nvl(en_tiporetimp_id, 0) > 0 then
      --
      select trim(cd)
        into vv_tiporetimp_cd
        from tipo_ret_imp
       where id = en_tiporetimp_id;
   --
   end if;

   return vv_tiporetimp_cd;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_tipo_ret_imp_cd:' || sqlerrm);
end fkg_tipo_ret_imp_cd;

-------------------------------------------------------------------------------------------------------

--| Função retorna verifica se a empresa Gera tributações de impostos
function fkg_empresa_gera_tot_trib ( en_empresa_id in empresa.id%type )
         return empresa.dm_gera_tot_trib%type
is
   --
   vn_dm_gera_tot_trib empresa.dm_gera_tot_trib%type;
   --
begin
   --
   select dm_gera_tot_trib
     into vn_dm_gera_tot_trib
     from empresa
    where id = en_empresa_id;
   --
   return vn_dm_gera_tot_trib;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_gera_tot_trib:' || sqlerrm);
end fkg_empresa_gera_tot_trib;

------------------------------------------------------------------------------------------

-- Função retorna o ID do Controle de Versão Contábil conforme UK (unique key)

function fkg_ctrlversaocontabil_id ( en_empresa_id   in empresa.id%type
                                   , ev_cd           in ctrl_versao_contabil.cd%type
                                   , en_dm_tipo      in ctrl_versao_contabil.dm_tipo%type
                                   )
         return ctrl_versao_contabil.id%type
is
   --
   vn_ctrlversaocontabil_id ctrl_versao_contabil.id%type;
   --
begin
   --
   select id
     into vn_ctrlversaocontabil_id
     from ctrl_versao_contabil
    where empresa_id = en_empresa_id
      and cd = ev_cd
      and dm_tipo = en_dm_tipo;
   --
   return vn_ctrlversaocontabil_id;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_ctrlversaocontabil_id: ' || sqlerrm);
end fkg_ctrlversaocontabil_id;

-------------------------------------------------------------------------------------------------------

-- Função verifica se o valor do ID existe no Controle de Versão Contábil

function fkg_existe_ctrlversaocontabil ( en_ctrlversaocontabil_id in ctrl_versao_contabil.id%type )
         return boolean
is
   --
   vb_existe boolean := false;
   vn_dummy  number := 0;
   --
begin
   --
   select 1
     into vn_dummy
     from ctrl_versao_contabil
    where id = en_ctrlversaocontabil_id;
   --
   if vn_dummy = 1 then
      vb_existe := true;
   else
      vb_existe := false;
   end if;
   --
   return vb_existe;
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_existe_ctrlversaocontabil: ' || sqlerrm);
end fkg_existe_ctrlversaocontabil;

-------------------------------------------------------------------------------------------------------

-- Função para retornar se a empresa permite Ajustar valores de impostos de importação com suframa

function fkg_empr_ajust_desc_zfm_item ( en_empresa_id in empresa.id%type )
         return empresa.dm_ajust_desc_zfm_item%type
is
   --
   vn_dm_ajust_desc_zfm_item  empresa.dm_ajust_desc_zfm_item%type;
   --
begin
   --
   select em.dm_ajust_desc_zfm_item
     into vn_dm_ajust_desc_zfm_item
     from empresa em
    where em.id = en_empresa_id;
   --
   return vn_dm_ajust_desc_zfm_item;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Problemas em fkg_empr_ajust_desc_zfm_item. Erro = '||sqlerrm);
end fkg_empr_ajust_desc_zfm_item;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o tipo de emitente da nota fiscal - nota_fiscal.dm_ind_emit = 0-emissão própria, 1-terceiros
function fkg_dmindemit_notafiscal ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal.dm_ind_emit%type
is
   --
   vn_dm_ind_emit  nota_fiscal.dm_ind_emit%type;
   --
begin
   --
   select nf.dm_ind_emit
     into vn_dm_ind_emit
     from nota_fiscal nf
    where nf.id = en_notafiscal_id;
   --
   return vn_dm_ind_emit;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Problemas em fkg_dmindemit_notafiscal. Erro = '||sqlerrm);
end fkg_dmindemit_notafiscal;

-------------------------------------------------------------------------------------------------------

-- Função para retornar a finalidade da nota fiscal - nota_fiscal.dm_fin_nfe = 1-NF-e normal, 2-NF-e complementar, 3-NF-e de ajuste
function fkg_dmfinnfe_notafiscal ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal.dm_fin_nfe%type
is
   --
   vn_dm_fin_nfe  nota_fiscal.dm_fin_nfe%type;
   --
begin
   --
   select nf.dm_fin_nfe
     into vn_dm_fin_nfe
     from nota_fiscal nf
    where nf.id = en_notafiscal_id;
   --
   return vn_dm_fin_nfe;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Problemas em fkg_dmfinnfe_notafiscal. Erro = '||sqlerrm);
end fkg_dmfinnfe_notafiscal;

-------------------------------------------------------------------------------------------------------

-- Função para retornar a sigla do estado do emitente da nota fiscal
function fkg_uf_notafiscalemit ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal_emit.uf%type
is
   --
   vv_uf  nota_fiscal_emit.uf%type;
   --
begin
   --
   select ne.uf
     into vv_uf
     from nota_fiscal_emit ne
    where ne.notafiscal_id = en_notafiscal_id;
   --
   return vv_uf;
   --
exception
   when no_data_found then
      return null;
   when too_many_rows then
      return null;
   when others then
      raise_application_error(-20101, 'Problemas em fkg_uf_notafiscalemit. Erro = '||sqlerrm);
end fkg_uf_notafiscalemit;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o CNPJ do emitente da nota fiscal
function fkg_cnpj_notafiscalemit ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal_emit.cnpj%type
is
   --
   vv_cnpj  nota_fiscal_emit.cnpj%type;
   --
begin
   --
   select ne.cnpj
     into vv_cnpj
     from nota_fiscal_emit ne
    where ne.notafiscal_id = en_notafiscal_id;
   --
   return vv_cnpj;
   --
exception
   when no_data_found then
      return null;
   when too_many_rows then
      return null;
   when others then
      raise_application_error(-20101, 'Problemas em fkg_cnpj_notafiscalemit. Erro = '||sqlerrm);
end fkg_cnpj_notafiscalemit;
-------------------------------------------------------------------------------------------------------

-- Função para retornar a sigla do estado do destinatário da nota fiscal
function fkg_uf_notafiscaldest ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal_dest.uf%type
is
   --
   vv_uf  nota_fiscal_dest.uf%type;
   --
begin
   --
   select nd.uf
     into vv_uf
     from nota_fiscal_dest nd
    where nd.notafiscal_id = en_notafiscal_id;
   --
   return vv_uf;
   --
exception
   when no_data_found then
      return null;
   when too_many_rows then
      return null;
   when others then
      raise_application_error(-20101, 'Problemas em fkg_uf_notafiscaldest. Erro = '||sqlerrm);
end fkg_uf_notafiscaldest;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o identificador de pessoa da nota fiscal
function fkg_pessoa_notafiscal_id ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal.pessoa_id%type
is
   --
   vn_pessoa_id  pessoa.id%type;
   --
begin
   --
   select nf.pessoa_id
     into vn_pessoa_id
     from nota_fiscal nf
    where nf.id = en_notafiscal_id;
   --
   return vn_pessoa_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Problemas em fkg_pessoa_notafiscal_id. Erro = '||sqlerrm);
end fkg_pessoa_notafiscal_id;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto ICMS - Parâmetro para Notas Fiscais com Emissão Própria

function fkg_empresa_dmvalimp_emis ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valid_imp%type is
   --
   vn_dm_valid_imp empresa.dm_valid_imp%type;
   --
begin
   --
   select e.dm_valid_imp
     into vn_dm_valid_imp
     from empresa e
    where e.id = en_empresa_id;
   --
   return vn_dm_valid_imp;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_dmvalimp_emis:' || sqlerrm);
end fkg_empresa_dmvalimp_emis;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto ICMS60 - Parâmetro para Notas Fiscais com Emissão Própria

function fkg_empresa_dmvalicms60_emis ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valid_icms60%type is
   --
   vn_dm_valid_icms60 empresa.dm_valid_icms60%type;
   --
begin
   --
   select e.dm_valid_icms60
     into vn_dm_valid_icms60
     from empresa e
    where e.id = en_empresa_id;
   --
   return vn_dm_valid_icms60;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_dmvalicms60_emis:' || sqlerrm);
end fkg_empresa_dmvalicms60_emis;


-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida Bases de ICMS - Parâmetro para Notas Fiscais com Emissão Própria

function fkg_empresa_dmvalbaseicms_emis ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valid_base_icms%type is
   --
   vn_dm_valid_base_icms empresa.dm_valid_base_icms%type;
   --
begin
   --
   select e.dm_valid_base_icms
     into vn_dm_valid_base_icms
     from empresa e
    where e.id = en_empresa_id;
   --
   return vn_dm_valid_base_icms;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_dmvalbaseicms_emis:' || sqlerrm);
end fkg_empresa_dmvalbaseicms_emis;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto IPI - Parâmetro para Notas Fiscais com Emissão Própria

function fkg_empresa_dmvalipi_emis ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_ipi%type is
   --
   vn_dm_valida_ipi empresa.dm_valida_ipi%type;
   --
begin
   --
   select e.dm_valida_ipi
     into vn_dm_valida_ipi
     from empresa e
    where e.id = en_empresa_id;
   --
   return vn_dm_valida_ipi;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_dmvalipi_emis:' || sqlerrm);
end fkg_empresa_dmvalipi_emis;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto PIS - Parâmetro para Notas Fiscais com Emissão Própria

function fkg_empresa_dmvalpis_emis ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_pis%type is
   --
   vn_dm_valida_pis empresa.dm_valida_pis%type;
   --
begin
   --
   select e.dm_valida_pis
     into vn_dm_valida_pis
     from empresa e
    where e.id = en_empresa_id;
   --
   return vn_dm_valida_pis;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_dmvalpis_emis:' || sqlerrm);
end fkg_empresa_dmvalpis_emis;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto Cofins - Parâmetro para Notas Fiscais com Emissão Própria

function fkg_empresa_dmvalcofins_emis ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_cofins%type is
   --
   vn_dm_valida_cofins empresa.dm_valida_cofins%type;
   --
begin
   --
   select e.dm_valida_cofins
     into vn_dm_valida_cofins
     from empresa e
    where e.id = en_empresa_id;
   --
   return vn_dm_valida_cofins;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_dmvalcofins_emis:' || sqlerrm);
end fkg_empresa_dmvalcofins_emis;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto ICMS - Parâmetro para Notas Fiscais com Emissão de Terceiros

function fkg_empresa_dmvalimp_terc ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valid_imp_terc%type is
   --
   vn_dm_valid_imp_terc empresa.dm_valid_imp_terc%type;
   --
begin
   --
   select e.dm_valid_imp_terc
     into vn_dm_valid_imp_terc
     from empresa e
    where e.id = en_empresa_id;
   --
   return vn_dm_valid_imp_terc;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_dmvalimp_terc:' || sqlerrm);
end fkg_empresa_dmvalimp_terc;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto ICMS60 - Parâmetro para Notas Fiscais com Emissão de Terceiros

function fkg_empresa_dmvalicms60_terc ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valid_icms60_terc%type is
   --
   vn_dm_valid_icms60_terc empresa.dm_valid_icms60_terc%type;
   --
begin
   --
   select e.dm_valid_icms60_terc
     into vn_dm_valid_icms60_terc
     from empresa e
    where e.id = en_empresa_id;
   --
   return vn_dm_valid_icms60_terc;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_dmvalicms60_terc:' || sqlerrm);
end fkg_empresa_dmvalicms60_terc;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida Bases de ICMS - Parâmetro para Notas Fiscais com Emissão de Terceiros

function fkg_empresa_dmvalbaseicms_terc ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valid_base_icms_terc%type is
   --
   vn_dm_valid_base_icms_terc empresa.dm_valid_base_icms_terc%type;
   --
begin
   --
   select e.dm_valid_base_icms_terc
     into vn_dm_valid_base_icms_terc
     from empresa e
    where e.id = en_empresa_id;
   --
   return vn_dm_valid_base_icms_terc;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_dmvalicms60_terc:' || sqlerrm);
end fkg_empresa_dmvalbaseicms_terc;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida Bases de ICMS - Parâmetro para Forma de demonstração das bases de ICMS
function fkg_empresa_dmformademb_icms ( en_empresa_id in Empresa.id%type )
         return empresa.dm_forma_dem_base_icms%type is
   --
   vn_dm_forma_dem_base_icms empresa.dm_forma_dem_base_icms%type;
   --
begin
   --
   select e.dm_forma_dem_base_icms
     into vn_dm_forma_dem_base_icms
     from empresa e
    where e.id = en_empresa_id;
   --
   return vn_dm_forma_dem_base_icms;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_dmformadembase_icms:' || sqlerrm);
end fkg_empresa_dmformademb_icms;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto IPI - Parâmetro para Notas Fiscais com Emissão de Terceiros

function fkg_empresa_dmvalipi_terc ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_ipi_terc%type is
   --
   vn_dm_valida_ipi_terc empresa.dm_valida_ipi_terc%type;
   --
begin
   --
   select e.dm_valida_ipi_terc
     into vn_dm_valida_ipi_terc
     from empresa e
    where e.id = en_empresa_id;
   --
   return vn_dm_valida_ipi_terc;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_dmvalipi_terc:' || sqlerrm);
end fkg_empresa_dmvalipi_terc;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto PIS - Parâmetro para Notas Fiscais com Emissão de Terceiros

function fkg_empresa_dmvalpis_terc ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_pis_terc%type is
   --
   vn_dm_valida_pis_terc empresa.dm_valida_pis_terc%type;
   --
begin
   --
   select e.dm_valida_pis_terc
     into vn_dm_valida_pis_terc
     from empresa e
    where e.id = en_empresa_id;
   --
   return vn_dm_valida_pis_terc;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_dmvalpis_terc:' || sqlerrm);
end fkg_empresa_dmvalpis_terc;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto Cofins - Parâmetro para Notas Fiscais com Emissão de Terceiros

function fkg_empresa_dmvalcofins_terc ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_cofins_terc%type is
   --
   vn_dm_valida_cofins_terc empresa.dm_valida_cofins_terc%type;
   --
begin
   --
   select e.dm_valida_cofins_terc
     into vn_dm_valida_cofins_terc
     from empresa e
    where e.id = en_empresa_id;
   --
   return vn_dm_valida_cofins_terc;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_dmvalcofins_terc:' || sqlerrm);
end fkg_empresa_dmvalcofins_terc;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela GRUPO_PAT

function fkg_grupopat_id ( en_multorg_id    in  mult_org.id%type
                         , ev_cod_grupopat  in  grupo_pat.cd%type )
         return grupo_pat.id%TYPE
is

   vn_grupopat_id grupo_pat.id%TYPE;

begin
   select id
     into vn_grupopat_id
     from grupo_pat
    where cd = ev_cod_grupopat
      and multorg_id = en_multorg_id;
   return vn_grupopat_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_grupopat_id:' || sqlerrm);
end fkg_grupopat_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela SUBGRUPO_PAT

function fkg_subgrupopat_id ( ev_cod_subgrupopat  in subgrupo_pat.cd%type
                            , en_grupopat_id      in grupo_pat.id%type )
         return subgrupo_pat.id%TYPE
is

   vn_subgrupopat_id subgrupo_pat.id%TYPE;

begin

   select id
     into vn_subgrupopat_id
     from subgrupo_pat
    where cd = ev_cod_subgrupopat
      and grupopat_id = en_grupopat_id;

   return vn_subgrupopat_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_subgrupopat_id:' || sqlerrm);
end fkg_subgrupopat_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna TRUE se existe o grupo ou FALSE caso contrário

function fkg_existe_grupo_pat ( en_grupopat_id in grupo_pat.id%type )
         return boolean
is

   vn_dummy number := 0;

begin
   --
   select 1
     into vn_dummy
     from grupo_pat
    where id = en_grupopat_id;
   --
   return (vn_dummy = 1);
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_grupo_pat: ' || sqlerrm);
end fkg_existe_grupo_pat;

-------------------------------------------------------------------------------------------------------

-- Função retorna TRUE se existe o subgrupo ou FALSE caso contrário

function fkg_existe_subgrupo_pat ( en_subgrupopat_id in subgrupo_pat.id%type )
         return boolean
is

   vn_dummy number := 0;

begin
   --
   select 1
     into vn_dummy
     from subgrupo_pat
    where id = en_subgrupopat_id;
   --
   return (vn_dummy = 1);
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_subgrupo_pat: ' || sqlerrm);
end fkg_existe_subgrupo_pat;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela REC_IMP_SUBGRUPO_PAT

function fkg_recimpsubgrupopat_id ( en_subgrupopat_id  in subgrupo_pat.id%type
                                  , en_tipoimp_id      in tipo_imposto.id%type )
         return rec_imp_subgrupo_pat.id%TYPE
is

   vn_recimpsubgrupopat_id rec_imp_subgrupo_pat.id%TYPE;

begin

   select id
     into vn_recimpsubgrupopat_id
     from rec_imp_subgrupo_pat
    where subgrupopat_id = en_subgrupopat_id
      and tipoimp_id = en_tipoimp_id;

   return vn_recimpsubgrupopat_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_recimpsubgrupopat_id:' || sqlerrm);
end fkg_recimpsubgrupopat_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna TRUE se existe o imposto do subgrupo ou FALSE caso contrário

function fkg_existe_imp_subgrupo_pat ( en_recimpsubgrupo_id in rec_imp_subgrupo_pat.id%type )
         return boolean
is

   vn_dummy number := 0;

begin
   --
   select 1
     into vn_dummy
     from rec_imp_subgrupo_pat
    where id = en_recimpsubgrupo_id;
   --
   return (vn_dummy = 1);
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_imp_subgrupo_pat: ' || sqlerrm);
end fkg_existe_imp_subgrupo_pat;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela NF_BEM_ATIVO_IMOB

function fkg_nfbemativoimob_id ( en_bemativoimob_id  in   bem_ativo_imob.id%type
                               , en_dm_ind_emit      in   nf_bem_ativo_imob.dm_ind_emit%type
                               , en_pessoa_id        in   nf_bem_ativo_imob.pessoa_id%type
                               , en_modfiscal_id     in   nf_bem_ativo_imob.modfiscal_id%type
                               , ev_serie            in   nf_bem_ativo_imob.serie%type
                               , ev_num_doc          in   nf_bem_ativo_imob.num_doc%type )
         return nf_bem_ativo_imob.id%TYPE
is
   --
   vn_nfbemativoimob_id  nf_bem_ativo_imob.id%TYPE;
   --
begin
   --
   if ev_serie is not null then
      --
      select id
        into vn_nfbemativoimob_id
        from nf_bem_ativo_imob
       where bemativoimob_id = en_bemativoimob_id
         and dm_ind_emit     = en_dm_ind_emit
         and pessoa_id       = en_pessoa_id
         and modfiscal_id    = en_modfiscal_id
         and serie           = ev_serie
         and num_doc         = ev_num_doc;
      --
   else
      --
      select id
        into vn_nfbemativoimob_id
        from nf_bem_ativo_imob
       where bemativoimob_id = en_bemativoimob_id
         and dm_ind_emit     = en_dm_ind_emit
         and pessoa_id       = en_pessoa_id
         and modfiscal_id    = en_modfiscal_id
         and serie           is null
         and num_doc         = ev_num_doc;
      --
   end if;
   --
   return vn_nfbemativoimob_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_nfbemativoimob_id:' || sqlerrm);
end fkg_nfbemativoimob_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna TRUE se existe o documento fiscal do bem ou FALSE caso contrário

function fkg_existe_nf_bem_ativo_imob ( en_nfbemativoimob_id in nf_bem_ativo_imob.id%type )
         return boolean
is

   vn_dummy number := 0;

begin
   --
   select 1
     into vn_dummy
     from nf_bem_ativo_imob
    where id = en_nfbemativoimob_id;
   --
   return (vn_dummy = 1);
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_nf_bem_ativo_imob: ' || sqlerrm);
end fkg_existe_nf_bem_ativo_imob;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela ITNF_BEM_ATIVO_IMOB

function fkg_itnfbemativoimob_id ( en_nfbemativoimob_id in nf_bem_ativo_imob.id%type
                                 , en_num_item          in itnf_bem_ativo_imob.num_item%type )
         return itnf_bem_ativo_imob.id%TYPE
is

   vn_itnfbemativoimob_id itnf_bem_ativo_imob.id%TYPE;

begin

   select id
     into vn_itnfbemativoimob_id
     from itnf_bem_ativo_imob
    where nfbemativoimob_id = en_nfbemativoimob_id
      and num_item          = en_num_item;

   return vn_itnfbemativoimob_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_itnfbemativoimob_id:' || sqlerrm);
end fkg_itnfbemativoimob_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna TRUE se existe o item do documento fiscal do bem ou FALSE caso contrário

function fkg_existe_itnf_bem_ativo_imob ( en_itnfbemativoimob_id in itnf_bem_ativo_imob.id%type )
         return boolean
is

   vn_dummy number := 0;

begin
   --
   select 1
     into vn_dummy
     from itnf_bem_ativo_imob
    where id = en_itnfbemativoimob_id;
   --
   return (vn_dummy = 1);
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_itnf_bem_ativo_imob: ' || sqlerrm);
end fkg_existe_itnf_bem_ativo_imob;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela REC_IMP_BEM_ATIVO_IMOB

function fkg_recimpbemativoimob_id ( en_bemativoimob_id in bem_ativo_imob.id%type
                                   , en_tipoimp_id      in tipo_imposto.id%type )
         return rec_imp_bem_ativo_imob.id%TYPE
is

   vn_recimpbemativoimob_id rec_imp_bem_ativo_imob.id%TYPE;

begin

   select id
     into vn_recimpbemativoimob_id
     from rec_imp_bem_ativo_imob
    where bemativoimob_id = en_bemativoimob_id
      and tipoimp_id      = en_tipoimp_id;

   return vn_recimpbemativoimob_id;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_recimpbemativoimob_id:' || sqlerrm);
end fkg_recimpbemativoimob_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna TRUE se existe o imposto do bem ou FALSE caso contrário

function fkg_existe_rec_imp_bem_ativo ( en_recimpbemativoimob_id in rec_imp_bem_ativo_imob.id%type )
         return boolean
is

   vn_dummy number := 0;

begin
   --
   select 1
     into vn_dummy
     from rec_imp_bem_ativo_imob
    where id = en_recimpbemativoimob_id;
   --
   return (vn_dummy = 1);
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_rec_imp_bem_ativo: ' || sqlerrm);
end fkg_existe_rec_imp_bem_ativo;

-------------------------------------------------------------------------------------------------------

-- Função para retorno o "Cálculo do Imposto do Patrimônio" da Empresa

function fkg_empresa_calc_imp_patr ( en_empresa_id in empresa.id%type )
         return empresa.dm_calc_imp_patr%type
is
   --
   vn_dm_calc_imp_patr empresa.dm_calc_imp_patr%type;
   --
begin
   --
   select e.dm_calc_imp_patr
     into vn_dm_calc_imp_patr
     from empresa e
    where e.id = en_empresa_id;
   --
   return vn_dm_calc_imp_patr;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_calc_imp_patr:' || sqlerrm);
end fkg_empresa_calc_imp_patr;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela Pessoa através do CNPJ ou CPF e da Sigla do Estado - UF

function fkg_pessoa_id_cpf_cnpj_uf ( en_multorg_id  in mult_org.id%type
                                   , en_cpf_cnpj    in varchar2
                                   , ev_uf          in varchar2
                                   )
         return pessoa.id%type
is
   --
   vn_pessoa_id  pessoa.id%type := null;
   --
begin
   --
   -- NÃO ALTERE A REGRA DESSAS ROTINAS SEM CONVERSAR COM EQUIPE
   --
   if rtrim(ltrim(en_cpf_cnpj)) is not null then
      --
      begin
         select max(pe.id)
	   into vn_pessoa_id
           from juridica ju
              , pessoa   pe
              , cidade   ci
              , estado   es
          where ju.num_cnpj     = to_number( substr(trim(en_cpf_cnpj),  1, 8) )
            and ju.num_filial   = to_number( substr(trim(en_cpf_cnpj),  9, 4) )
            and ju.dig_cnpj     = to_number( substr(trim(en_cpf_cnpj), 13, 2) )
            and pe.id           = ju.pessoa_id
            and pe.multorg_id   = en_multorg_id
            and ci.id           = pe.cidade_id
            and es.id           = ci.estado_id
            and es.sigla_estado = ev_uf;
      exception
         when others then
            vn_pessoa_id := null;
      end;
      --
      if nvl(vn_pessoa_id,0) <= 0 then
         --
         begin
            select max(pe.id)
              into vn_pessoa_id
              from fisica fi
                 , pessoa pe
                 , cidade ci
                 , estado es
             where fi.num_cpf      = to_number( substr(trim(en_cpf_cnpj), 1, 9) )
               and fi.dig_cpf      = to_number( substr(trim(en_cpf_cnpj), 10, 2) )
               and pe.id           = fi.pessoa_id
               and pe.multorg_id   = en_multorg_id
               and ci.id           = pe.cidade_id
               and es.id           = ci.estado_id
               and es.sigla_estado = ev_uf;
         exception
            when others then
               vn_pessoa_id := null;
         end;
         --
      end if;
      --
   end if;
   --
   return vn_pessoa_id;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na fkg_pessoa_id_cpf_cnpj_uf: '||sqlerrm);
end fkg_pessoa_id_cpf_cnpj_uf;

-------------------------------------------------------------------------------------------------------

-- Função para recuperar parãmetro que indica se a empresa compõe o tipo de código de crédito através do tipo de embalagem.
function fkg_dmutilprocemb_tpcred_empr( en_empresa_id in empresa.id%type )
         return empresa.dm_util_proc_emb_tipocred%type
is
   --
   vn_dm_util_proc_emb_tipocred empresa.dm_util_proc_emb_tipocred%type;
   --
begin
   --
   select em.dm_util_proc_emb_tipocred
     into vn_dm_util_proc_emb_tipocred
     from empresa em
    where em.id = en_empresa_id;
   --
   return vn_dm_util_proc_emb_tipocred;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_dmutilprocemb_tpcred_empr:' || sqlerrm);
end fkg_dmutilprocemb_tpcred_empr;

-------------------------------------------------------------------------------------------------------

--| Função retorna cod_class da tabela class_cons_item_cont conforme o id

function fkg_cod_class ( ev_classconsitemcont_id in class_cons_item_cont.id%type )
         return class_cons_item_cont.cod_class%type
is
   --
   vn_cod_class class_cons_item_cont.cod_class%type;
   --
begin
   --
   select cod_class
     into vn_cod_class
     from class_cons_item_cont
    where id = ev_classconsitemcont_id;
   --
   return vn_cod_class;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_cod_class:' || sqlerrm);
end fkg_cod_class;

-------------------------------------------------------------------------------------------------------

--| Função retorna o cod_cons da tabela cod_cons_item_cont

function fkg_codconsitemcont_cod( en_codconsitemcont_id  in cod_cons_item_cont.id%TYPE )
         return cod_cons_item_cont.cod_cons%type
is

   vv_cod_cons  cod_cons_item_cont.cod_cons%type;

begin
   --
   select cod_cons
     into vv_cod_cons
     from cod_cons_item_cont
    where id = en_codconsitemcont_id;
   --
   return vv_cod_cons;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_codconsitemcont_cod:' || sqlerrm);
end fkg_codconsitemcont_cod;

-------------------------------------------------------------------------------------------------------

--| Função que verifica se o Número de controle da FCI do Item é válido.
-- É válido o número da FCI que é de tamanho 36, contém apenas caracteres de "A" a "F", algarismos
-- e o caractere de hífen "-" nas posições 9, 14, 19 e 24.

function fkg_nro_fci_valido ( ev_nro_fci in item_nota_fiscal.nro_fci%type )
         return boolean
is
   --
   vb_valido        boolean := true;
   vn_posicao_hifen number := 9;
   --
begin
   --
   -- Verifica se o tamanho do número da FCI é igual a 36.
   if length(trim(ev_nro_fci)) = 36 then
      --
      for i in 1..4 loop
         --
         -- Verifica se nas posições 9, 14, 19 e 24 contém o hífen.
         if substr(ev_nro_fci,vn_posicao_hifen,1) <> '-' then
            --
            vb_valido := false;
            exit;
            --
         end if;
         --
         vn_posicao_hifen := vn_posicao_hifen + 5;
         --
      end loop;
      --
      if vb_valido then
         --
         for i in 1..36 loop
            --
            -- Verifica se contém apenas caracteres de "A" a "F" e algarismos, com exceção do hífen.
            if (substr(ev_nro_fci,i,1) not in ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'))
               and i not in (9,14,19,24) then
               --
               vb_valido := false;
               exit;
               --
            end if;
            --
         end loop;
         --
      end if;
      --
   else
      --
      vb_valido := false;
      --
   end if;
   --
   return vb_valido;
   --
exception
   when others then
   --
   raise_application_error(-20101, 'Erro na pk_csf.fkg_nro_fci_valido: ' || sqlerrm);
   --
end fkg_nro_fci_valido;

-------------------------------------------------------------------------------------------------------

--| Função retorna o cd da tabela tipo_evento_sefaz conforme o ID

function fkg_tipoeventosefaz_cd( en_tipoeventosefaz_id  in tipo_evento_sefaz.id%TYPE )
         return tipo_evento_sefaz.cd%type
is
   --
   vv_cd  tipo_evento_sefaz.cd%type;
   --
begin
      --
      select cd
        into vv_cd
        from tipo_evento_sefaz
       where id = en_tipoeventosefaz_id;
      --
      return vv_cd;
      --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_tipoeventosefaz_cd:' || sqlerrm);
end fkg_tipoeventosefaz_cd;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela tipo_evento_sefaz conforme o CD

function fkg_tipoeventosefaz_id( ev_cd  in tipo_evento_sefaz.cd%TYPE )
         return tipo_evento_sefaz.id%type
is
   --
   vn_tipoeventosefaz_id  tipo_evento_sefaz.id%type;
   --
begin
   --
   select id
     into vn_tipoeventosefaz_id
     from tipo_evento_sefaz
    where cd = ev_cd;
   --
   return vn_tipoeventosefaz_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_tipoeventosefaz_id:' || sqlerrm);
end fkg_tipoeventosefaz_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna o parâmatro da Empresa de "Retorna Consulta de CTe sem XML de Terceiro"

function fkg_ret_cons_cte_sem_xml ( en_empresa_id in Empresa.id%type )
         return empresa.dm_ret_cons_cte_sem_xml%type
is
   --
   vn_dm_ret_cons_cte_sem_xml empresa.dm_ret_cons_cte_sem_xml%type;
   --
begin
   --
   select e.dm_ret_cons_cte_sem_xml
     into vn_dm_ret_cons_cte_sem_xml
     from empresa e
    where e.id = en_empresa_id;
   --
   return vn_dm_ret_cons_cte_sem_xml;
   --
exception
   when others then
      return 0;
end fkg_ret_cons_cte_sem_xml;

-------------------------------------------------------------------------------------------------------

--| Função retorna o CNPJ da tabela pais_cnpj conforme o id do PAIS e da CIDADE

function fkg_paiscnpj_cnpj ( en_pais_id    in pais.id%TYPE
                           , en_cidade_id  in cidade.id%TYPE )
         return pais_cnpj.cnpj%type
is
   --
   vv_cnpj  pais_cnpj.cnpj%type;
   --
begin
   --
   select cnpj
     into vv_cnpj
     from pais_cnpj
    where pais_id = en_pais_id
      and cidade_id = en_cidade_id;
   --
   return vv_cnpj;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_paiscnpj_cnpj:' || sqlerrm);
end fkg_paiscnpj_cnpj;

-------------------------------------------------------------------------------------------------------

-- Função retorna a inscrição municipal da empresa

function fkg_inscr_mun_empresa ( en_empresa_id  in Empresa.id%TYPE )
         return Juridica.im%TYPE
is

   vv_im  Juridica.im%TYPE := null;

begin

   if nvl(en_empresa_id,0) > 0 then
      --
      select j.im
        into vv_im
        from Empresa   e
           , Juridica  j
       where e.id         = en_empresa_id
         and j.pessoa_id  = e.pessoa_id;
      --
   end if;

   return vv_im;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_inscr_mun_empresa:' || sqlerrm);
end fkg_inscr_mun_empresa;

-------------------------------------------------------------------------------------------------------

-- Função retorna o código do IBGE da cidade da empresa conforme o ID da empresa

function fkg_ibge_cidade_empresa ( en_empresa_id  in Empresa.id%TYPE )
         return cidade.ibge_cidade%TYPE
is

   vv_ibge_cidade  cidade.ibge_cidade%TYPE := null;

begin

   if nvl(en_empresa_id,0) > 0 then
      --
      select c.ibge_cidade
        into vv_ibge_cidade
        from cidade   c
           , pessoa   p
           , empresa  e
       where e.id         = en_empresa_id
         and e.pessoa_id  = p.id
         and p.cidade_id  = c.id;
      --
   end if;

   return vv_ibge_cidade;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_ibge_cidade_empresa:' || sqlerrm);
end fkg_ibge_cidade_empresa;

-------------------------------------------------------------------------------------------------------

-- Função retorna o valor de tolerância para os valores de documentos fiscais (nf, cf, ct) e caso não exista manter 0.03

function fkg_vlr_toler_empresa ( en_empresa_id in empresa.id%type
                               , ev_opcao      in varchar2 )
         return number
is
   --
   vn_valor        number := 0;
   vn_vl_toler_ecf param_tolerancia_empresa.vl_toler_ecf%type;
   vn_vl_toler_nf  param_tolerancia_empresa.vl_toler_nf%type;
   vn_vl_toler_ct  param_tolerancia_empresa.vl_toler_ct%type;
   --
begin
   --
   begin
      select pt.vl_toler_ecf
           , pt.vl_toler_nf
           , pt.vl_toler_ct
        into vn_vl_toler_ecf
           , vn_vl_toler_nf
           , vn_vl_toler_ct
        from param_tolerancia_empresa pt
       where pt.empresa_id = en_empresa_id;
   exception
      when no_data_found then
         vn_vl_toler_ecf := 0.03; -- valor default
         vn_vl_toler_nf  := 0.03; -- valor default
         vn_vl_toler_ct  := 0.03; -- valor default
      when others then
         raise_application_error(-20101, 'Problemas ao recuperar valores de tolerência (empresa_id = '||en_empresa_id||' - fkg_vlr_toler_empresa. Erro = '||sqlerrm);
   end;
   --
   if ev_opcao = 'NF' then
      vn_valor := vn_vl_toler_nf;
   elsif ev_opcao = 'CF' then
         vn_valor := vn_vl_toler_ecf;
   elsif ev_opcao = 'CT' then
         vn_valor := vn_vl_toler_ct;
   else
      vn_valor := 0.03; -- valor default
   end if;
   --
   return(vn_valor);
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na fkg_vlr_toler_empresa:' || sqlerrm);
end fkg_vlr_toler_empresa;

-------------------------------------------------------------------------------------------------------

-- Procedimento retorna os parâmetros de Difirencial de Alíquota para a EFD ICMS/IPI
procedure pkb_param_difal_efd_icms_ipi ( en_empresa_id                   in empresa.id%type
                                       , sn_dm_lcto_difal               out param_efd_icms_ipi.dm_lcto_difal%type
                                       , sn_codajsaldoapuricms_id_difal out param_efd_icms_ipi.codajsaldoapuricms_id_difal%type
                                       , sn_codocorajicms_id_difal      out param_efd_icms_ipi.codocorajicms_id_difal%type
                                       , sn_codajsaldoapuricms_id_difpa out param_efd_icms_ipi.codajsaldoapuricms_id_difpart%type
                                       )
is
   --
   --
begin
   --
   select dm_lcto_difal
        , codajsaldoapuricms_id_difal
        , codocorajicms_id_difal
        , codajsaldoapuricms_id_difpart
     into sn_dm_lcto_difal
        , sn_codajsaldoapuricms_id_difal
        , sn_codocorajicms_id_difal
        , sn_codajsaldoapuricms_id_difpa
     from param_efd_icms_ipi
    where empresa_id = en_empresa_id;
   --
exception
   when others then
      sn_dm_lcto_difal               := 0;
      sn_codajsaldoapuricms_id_difal := 0;
      sn_codocorajicms_id_difal      := 0;
      sn_codajsaldoapuricms_id_difpa := 0;
end pkb_param_difal_efd_icms_ipi;

-------------------------------------------------------------------------------------------------------

-- Procedimento retorna os parâmetros de Difirencial de Alíquota para a EFD ICMS/IPI
function fkg_param_ciap_efd_icms_ipi ( en_empresa_id                   in empresa.id%type
                                     )
         return param_efd_icms_ipi.codajsaldoapuricms_id_ciap%type
is
   --
   vn_codajsaldoapuricms_id_ciap param_efd_icms_ipi.codajsaldoapuricms_id_ciap%type;
   --
begin
   --
   select codajsaldoapuricms_id_ciap
     into vn_codajsaldoapuricms_id_ciap
     from param_efd_icms_ipi
    where empresa_id = en_empresa_id;
   --
   return vn_codajsaldoapuricms_id_ciap;
   --
exception
   when others then
      return 0;
end fkg_param_ciap_efd_icms_ipi;

-------------------------------------------------------------------------------------------------------

-- Procedimento retorna os parâmetros Código de Ajuste de IPI Não destacado para a EFD ICMS/IPI
function fkg_par_ipi_naodest_efdicmsipi ( en_empresa_id                   in empresa.id%type
                                        )
         return param_efd_icms_ipi.codajapuripi_id_ipi_nao_dest%type
is
   --
   vn_codajapuripi_id_ipi_naodest param_efd_icms_ipi.codajapuripi_id_ipi_nao_dest%type;
   --
begin
   --
   select codajapuripi_id_ipi_nao_dest
     into vn_codajapuripi_id_ipi_naodest
     from param_efd_icms_ipi
    where empresa_id = en_empresa_id;
   --
   return vn_codajapuripi_id_ipi_naodest;
   --
exception
   when others then
      return 0;
end fkg_par_ipi_naodest_efdicmsipi;

-------------------------------------------------------------------------------------------------------
-- Função retorna o Parâmetro de Indicador de Tributação do Totalizador Parcial de ECF da empresa

function fkg_indtribtotparcredz_empresa ( en_empresa_id                   in empresa.id%type
                                        )
         return empresa.dm_ind_trib_tot_parc_redz%type
is
   --
   vn_dm_ind_trib_tot_parc_redz empresa.dm_ind_trib_tot_parc_redz%type;
   --
begin
   --
   select dm_ind_trib_tot_parc_redz
     into vn_dm_ind_trib_tot_parc_redz
     from empresa
    where id = en_empresa_id;
   --
   return vn_dm_ind_trib_tot_parc_redz;
   --
exception
   when others then
      return 0;
end fkg_indtribtotparcredz_empresa;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o identificador do relacionamento de item/componente e insumo
function fkg_item_insumo_id( en_item_id     in item.id%type
                           , en_item_id_ins in item.id%type
                           )
         return item_insumo.id%type
is
   --
   vn_iteminsumo_id item_insumo.id%type;
   --
begin
   --
   begin
      select ii.id
        into vn_iteminsumo_id
        from item_insumo ii
       where ii.item_id     = en_item_id
         and ii.item_id_ins = en_item_id_ins;
   exception
      when no_data_found then
         vn_iteminsumo_id := 0;
      when others then
         raise_application_error(-20101, 'Problemas ao recuperar ID do relacionamento item/componente e insumo - pk_csf.fkg_item_insumo_id. Erro = '||sqlerrm);
   end;
   --
   return(vn_iteminsumo_id);
   --
exception
   when others then
      raise_application_error(-20101, 'Erro em pk_csf.fkg_item_insumo_id:'||sqlerrm);
end fkg_item_insumo_id;

-------------------------------------------------------------------------------------------------------

-- Função para retornar se o relacionamento de item/componente e insumo já existe
function fkg_existe_iteminsumo( en_iteminsumo_id in item_insumo.id%type
                              )
         return boolean
is
   --
   vn_iteminsumo_id item_insumo.id%type;
   --
begin
   --
   begin
      select ii.id
        into vn_iteminsumo_id
        from item_insumo ii
       where ii.id = en_iteminsumo_id;
   exception
      when no_data_found then
         vn_iteminsumo_id := 0;
      when others then
         raise_application_error(-20101, 'Problemas ao verificar se existe ID do relacionamento item/componente e insumo - pk_csf.fkg_existe_iteminsumo. Erro = '||sqlerrm);
   end;
   --
   if nvl(vn_iteminsumo_id,0) = 0 then
      return(false);
   else
      return(true);
   end if;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro em pk_csf.fkg_existe_iteminsumo:'||sqlerrm);
end fkg_existe_iteminsumo;

-------------------------------------------------------------------------------------------------------
-- Função retorna o ID da tabela NFINFOR_FISCAL conforme o NOTAFISCAL_ID e OBSLANCTOFISCAL_ID

function fkg_nfinfor_fiscal_id ( en_notafiscal_id      in nota_fiscal.id%type
                               , en_obslanctofiscal_id in obs_lancto_fiscal.id%type )
         return nfinfor_fiscal.id%type
is
   --
   vn_nfinforfiscal_id nfinfor_fiscal.id%type;
   --
begin
   --
   select id
     into vn_nfinforfiscal_id
     from nfinfor_fiscal
    where notafiscal_id      = en_notafiscal_id
      and obslanctofiscal_id = en_obslanctofiscal_id;
   --
   return vn_nfinforfiscal_id;
   --
exception
   when others then
      return 0;
end fkg_nfinfor_fiscal_id;

-------------------------------------------------------------------------------------------------------
-- Função retorna o COD_OBS da tabela OBS_LANCTO_FISCAL conforme o NFINFORFISCAL_ID

function fkg_cod_obs_nfinfor_fiscal ( en_nfinforfiscal_id in nfinfor_fiscal.id%type )
         return obs_lancto_fiscal.cod_obs%type
is
   --
   vv_cod_obs obs_lancto_fiscal.cod_obs%type;
   --
begin
   --
   select olf.cod_obs
     into vv_cod_obs
     from obs_lancto_fiscal olf
        , nfinfor_fiscal    nif
    where nif.id = en_nfinforfiscal_id
      and olf.id = nif.obslanctofiscal_id;
   --
   return vv_cod_obs;
   --
exception
   when others then
      return null;
end fkg_cod_obs_nfinfor_fiscal;

-------------------------------------------------------------------------------------------------------
-- Função retorna o NRO_ITEM da tabela ITEM conforme o ITEMNOTAFISCAL_ID

function fkg_nro_item ( en_itemnotafiscal_id  in item_nota_fiscal.id%type )
         return item_nota_fiscal.nro_item%type
is
   --
   vn_nro_item item_nota_fiscal.nro_item%type;
   --
begin
   --
   select nro_item
     into vn_nro_item
     from item_nota_fiscal
    where id = en_itemnotafiscal_id;
   --
   return vn_nro_item;
   --
exception
   when others then
      return 0;
end fkg_nro_item;

-------------------------------------------------------------------------------------------------------
-- Função retorna o código de ajuste das obrigações a recolher através do identificador

function fkg_cd_ajobrigrec ( en_ajobrigrec_id in aj_obrig_rec.id%type )
         return aj_obrig_rec.cd%type
is
   --
   vv_cd  aj_obrig_rec.cd%type;
   --
begin
   --
   select ao.cd
     into vv_cd
     from aj_obrig_rec ao
    where ao.id = en_ajobrigrec_id;
   --
   return vv_cd;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_cd_ajobrigrec: '||sqlerrm);
end fkg_cd_ajobrigrec;

-------------------------------------------------------------------------------------------------------

--| Retorna o parâmetro de empresa EMPR_PARAM_CONS_MDE.DM_REG_CO_MDE_AUT

function fkg_empresa_reg_co_mde_aut ( en_empresa_id                   in empresa.id%type
                                    )
         return empr_param_cons_mde.dm_reg_co_mde_aut%type
is
   --
   vn_dm_reg_co_mde_aut empr_param_cons_mde.dm_reg_co_mde_aut%type;
   --
begin
   --
   select dm_reg_co_mde_aut
     into vn_dm_reg_co_mde_aut
     from empr_param_cons_mde
    where empresa_id = en_empresa_id;
   --
   return vn_dm_reg_co_mde_aut;
   --
exception
   when others then
      return (0);
end fkg_empresa_reg_co_mde_aut;

-------------------------------------------------------------------------------------------------------

-- Função retorna o IBGE_CIDADE conforme Estado e Descrição da Cidade

function fkg_ibge_cidade_dados ( ev_sigla_estado in estado.sigla_estado%type
                               , ev_descr_cidade in cidade.descr%type
                               )
         return cidade.ibge_cidade%type
is
   --
   vv_ibge_cidade cidade.ibge_cidade%type;
   --
begin
   --
   select cid.ibge_cidade
     into vv_ibge_cidade
     from estado est
        , cidade cid
    where est.sigla_estado = ev_sigla_estado
      and cid.estado_id = est.id
      and upper(pk_csf.fkg_converte(cid.descr)) = upper(pk_csf.fkg_converte(ev_descr_cidade));
   --
   return vv_ibge_cidade;
   --
exception
   when others then
      return '0';
end fkg_ibge_cidade_dados;

-------------------------------------------------------------------------------------------------------

--| Retorna o parâmetro de empresa EMPR_PARAM_CONS_MDE.DM_REG_MDE_AUT

function fkg_empresa_reg_mde_aut ( en_empresa_id in empresa.id%type )
         return empr_param_cons_mde.dm_reg_mde_aut%type
is
   --
   vn_dm_reg_mde_aut empr_param_cons_mde.dm_reg_mde_aut%type;
   --
begin
   --
   select dm_reg_mde_aut
     into vn_dm_reg_mde_aut
     from empr_param_cons_mde
    where empresa_id = en_empresa_id;
   --
   return vn_dm_reg_mde_aut;
   --
exception
   when others then
      return (0);
end fkg_empresa_reg_mde_aut;

-------------------------------------------------------------------------------------------------------

-- Função retorna o código do bem do ativo imobilizado conforme o id

function fkg_cod_ind_bem_id ( en_bemativoimob_id in bem_ativo_imob.id%type )
         return bem_ativo_imob.cod_ind_bem%type
is
   vv_cod_ind_bem bem_ativo_imob.cod_ind_bem%type;

begin
   --
   select cod_ind_bem
     into vv_cod_ind_bem
     from bem_ativo_imob
    where id = en_bemativoimob_id;
   --
   return vv_cod_ind_bem;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cod_ind_bem_id: ' || sqlerrm);
end fkg_cod_ind_bem_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Código da tabela SUBGRUPO_PAT

function fkg_subgrupopat_cd ( en_subgrupopat_id  in subgrupo_pat.id%type )
         return subgrupo_pat.cd%type
is

   vv_subgrupopat_cd subgrupo_pat.cd%type := null;

begin

   select cd
     into vv_subgrupopat_cd
     from subgrupo_pat
    where id = en_subgrupopat_id;

   return vv_subgrupopat_cd;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_subgrupopat_cd:' || sqlerrm);
end fkg_subgrupopat_cd;

-------------------------------------------------------------------------------------------------------

-- Função retorna o CD da tabela GRUPO_PAT conforme o ID da tabela SUBGRUPO_PAT

function fkg_grupopat_cd_subgrupo_id ( en_subgrupopat_id  in subgrupo_pat.id%type )
         return grupo_pat.cd%type
is

   vv_grupopat_cd grupo_pat.cd%type := null;

begin

   select gp.cd
     into vv_grupopat_cd
     from subgrupo_pat sgp
        , grupo_pat gp
    where sgp.id = en_subgrupopat_id
      and sgp.grupopat_id = gp.id;

   return vv_grupopat_cd;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_grupopat_cd_subgrupo_id:' || sqlerrm);
end fkg_grupopat_cd_subgrupo_id;

-------------------------------------------------------------------------------------------------------
-- Função retorna TRUE se existe o Plano de Contas ou FALSE caso não exista

function fkg_existe_plano_conta ( en_planoconta_id in plano_conta.id%type )
         return boolean
is

   vn_dummy number := 0;

begin
   --
   select 1
     into vn_dummy
     from plano_conta
    where id = en_planoconta_id;
   --
   return (vn_dummy = 1);
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_plano_conta: ' || sqlerrm);
end fkg_existe_plano_conta;

-------------------------------------------------------------------------------------------------------
-- Função retorna TRUE se existe o Plano de Contas Referencial ou FALSE caso não exista

function fkg_existe_pc_referen ( en_pcreferen_id in pc_referen.id%type )
         return boolean
is

   vn_dummy number := 0;

begin
   --
   select 1
     into vn_dummy
     from pc_referen
    where id = en_pcreferen_id;
   --
   return (vn_dummy = 1);
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_pc_referen: ' || sqlerrm);
end fkg_existe_pc_referen;

-------------------------------------------------------------------------------------------------------
-- Função retorna TRUE se existe o Centro de Custo ou FALSE caso não exista

function fkg_existe_centro_custo ( en_centrocusto_id in centro_custo.id%type )
         return boolean
is

   vn_dummy number := 0;

begin
   --
   select 1
     into vn_dummy
     from centro_custo
    where id = en_centrocusto_id;
   --
   return (vn_dummy = 1);
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_centro_custo: ' || sqlerrm);
end fkg_existe_centro_custo;

-------------------------------------------------------------------------------------------------------
-- Função retorna TRUE se existe o Histórico Padrão ou FALSE caso não exista

function fkg_existe_hist_padrao ( en_histpadrao_id in hist_padrao.id%type )
         return boolean
is

   vn_dummy number := 0;

begin
   --
   select 1
     into vn_dummy
     from hist_padrao
    where id = en_histpadrao_id;
   --
   return (vn_dummy = 1);
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_hist_padrao: ' || sqlerrm);
end fkg_existe_hist_padrao;

-------------------------------------------------------------------------------------------------------

--| Retorna a quantidade de registros da tabela enviada no parâmetro

function fkg_quantidade ( ev_obj    varchar2 )
         return number
is
   --
   vn_quantidade   number := 0;
   --
begin
   --
   execute immediate 'select count(1) from ' || ev_obj into vn_quantidade;
   --
   return vn_quantidade;
   --
exception
   when others then
      return (0);
end fkg_quantidade;

-------------------------------------------------------------------------------------------------------

--| Monta o objeto conforme aspas, owner e dblink

function fkg_monta_obj ( ev_obj            in varchar2
                       , ev_aspas          in varchar2
                       , ev_owner_obj      in varchar2
                       , ev_nome_dblink    in varchar2
                       , en_dm_ind_emit    in number default null
                       )
         return varchar2
is
   --
   vv_obj   varchar2(4000) := null;
   --
begin
   --
   if nvl(en_dm_ind_emit,0) = 1 then
      vv_obj := trim(ev_aspas) || ev_obj || '1' || trim(ev_aspas);
   else
      vv_obj := trim(ev_aspas) || ev_obj || trim(ev_aspas);
   end if;
   --
   if ev_nome_dblink is not null then
      --
      vv_obj := vv_obj || '@' || ev_nome_dblink;
      --
   end if;
   --
   if trim(ev_owner_obj) is not null then
      vv_obj := trim(ev_owner_obj) || '.' || vv_obj;
   end if;
   --
   return vv_obj;
   --
end fkg_monta_obj;

-------------------------------------------------------------------------------------------------------

--| Retorna a descrição (nome) da cidade conforme o ID

function fkg_cidade_descr ( en_cidade_id   in cidade.id%type )
         return cidade.descr%type
is
   --
   vv_descr cidade.descr%type;
   --
begin
   --
   select c.descr
     into vv_descr
     from cidade c
    where c.id = en_cidade_id;
   --
   return vv_descr;
   --
exception
   when others then
      return null;
end fkg_cidade_descr;

-------------------------------------------------------------------------------------------------------

-- Retorna o ID do mult_org vinculado ao usuário

function fkg_multorg_id_usuario ( en_usuario_id in neo_usuario.id%type )
         return mult_org.id%type
is

    vn_multorg_id mult_org.id%type;

begin
   --
   select u.multorg_id
     into vn_multorg_id
     from neo_usuario u
    where u.id = en_usuario_id;
   --
   return vn_multorg_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_multorg_id_usuario:' || sqlerrm);
end fkg_multorg_id_usuario;

-------------------------------------------------------------------------------------------------------

-- Retorna o tipo de ambiente da nota fiscal

function fkg_dm_tp_amb_nf ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal.dm_tp_amb%type
is

    vn_dm_tp_amb nota_fiscal.dm_tp_amb%type;

begin
   --
   select nf.dm_tp_amb
     into vn_dm_tp_amb
     from nota_fiscal nf
    where nf.id = en_notafiscal_id;
   --
   return vn_dm_tp_amb;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_dm_tp_amb_nf:' || sqlerrm);
end fkg_dm_tp_amb_nf;

-------------------------------------------------------------------------------------------------------

-- Retorna o valor do Parâmetro Gerar XML WS Sinal Suframa

function fkg_cfop_gerar_sinal_suframa ( en_empresa_id in empresa.id%type
                                      , en_cfop_id    in cfop.id%type
                                      )
         return param_cfop_empresa.dm_gera_sinal_suframa%type
is

    vn_dm_gera_sinal_suframa  param_cfop_empresa.dm_gera_sinal_suframa%type;

begin
   --
   select dm_gera_sinal_suframa
     into vn_dm_gera_sinal_suframa
     from param_cfop_empresa
    where empresa_id = en_empresa_id
      and cfop_id    = en_cfop_id;
   --
   return vn_dm_gera_sinal_suframa;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_cfop_gerar_sinal_suframa:' || sqlerrm);
end fkg_cfop_gerar_sinal_suframa;

-------------------------------------------------------------------------------------------------------
--
-- Recebe como entrada um texto(ev_texto) separado por algum simbolo(ev_separador)
-- e devolve um array onde cada posição do array é uma palavra que estava entre o separador.
--

procedure pkb_dividir ( ev_texto       in     varchar2
                      , ev_separador   in     varchar2
                      , estv_texto     in out dbms_sql.varchar2_table )
is
   --
   vv_texto    varchar2(32767) := replace(ev_texto, ',', '.');
   i           pls_integer := 0;
   --
begin
   --
   -- Remove o separador do começo do texto, caso tenha.
   if substr(vv_texto,1,1) = ev_separador then
      vv_texto := substr(vv_texto,2,length(vv_texto)-1);
   end if;
   --
   -- Adiciona o separador no final do texto, caso não tenha.
   if substr(vv_texto,length(vv_texto),1) <> ev_separador then
      vv_texto := vv_texto || ev_separador;
   end if;
   --
   while vv_texto is not null
   loop
      --
      estv_texto(i) := substr(vv_texto,1,instr(vv_texto,'|')-1);
      vv_texto :=  substr(vv_texto,instr(vv_texto,'|')+1,length(vv_texto));
      --
      i := i+1;
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.pkb_dividir: ' || sqlerrm);
end pkb_dividir;

-------------------------------------------------------------------------------------------------------

-- Função retorna código da conta + descrição do plano de contas através do ID do Plano de Conta

function fkg_texto_plano_conta_id ( en_planoconta_id in plano_conta.id%type )
         return varchar2
is
   --
   vv_texto varchar2(600) := null;
   --
begin
   --
   if nvl(en_planoconta_id,0) > 0 then
      --
      begin
         select pc.cod_cta || '-' || pc.descr_cta
           into vv_texto
           from plano_conta pc
          where pc.id = en_planoconta_id;
      exception
         when no_data_found then
            vv_texto := null;
         when others then
            raise_application_error(-20101, 'Problemas ao recuperar código do plano de contas (id='||en_planoconta_id||'). Erro = '||sqlerrm);
      end;
      --
    end if;
   --
   return vv_texto;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_texto_plano_conta_id: '||sqlerrm);
end fkg_texto_plano_conta_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna código do centro de custo + descrição através do ID do Centro de Custo

function fkg_texto_centro_custo_id ( en_centrocusto_id in centro_custo.id%type )
         return varchar2
is
   --
   vv_texto varchar2(600) := null;
   --
begin
   --
   if nvl(en_centrocusto_id,0) > 0 then
      --
      begin
         select cc.cod_ccus || '-' || cc.descr_ccus
           into vv_texto
           from centro_custo cc
          where cc.id = en_centrocusto_id;
      exception
         when no_data_found then
            vv_texto := null;
         when others then
            raise_application_error(-20101, 'Problemas ao recuperar código do centro de custo (id='||en_centrocusto_id||'). Erro = '||sqlerrm);
      end;
      --
    end if;
   --
   return vv_texto;
   --
exception
   when no_data_found then
      return (null);
   when too_many_rows then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_texto_centro_custo_id:' || sqlerrm);
end fkg_texto_centro_custo_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID "CNAE" conforme o Código

function fkg_id_cnae_cd ( en_cnae_cd in cnae.cd%TYPE )
         return cnae.id%TYPE
is

   vn_cnae_id         cnae.id%TYPE;
   vv_cd_cnae_semptb  cnae.cd%TYPE;  -- cd do cnae sem ponto, traço e barra  

begin
   --
   vv_cd_cnae_semptb := trim(replace(replace(replace(en_cnae_cd,'.',''),'-',''),'/',''));
   --   
   select c.id
     into vn_cnae_id
     from cnae c
    where trim(replace(replace(replace(c.cd,'.',''),'-',''),'/','')) = vv_cd_cnae_semptb;
   --
   return vn_cnae_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error (-20100, 'Erro na fkg_id_cnae_cd: ' || sqlerrm);
end fkg_id_cnae_cd;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Código do "CNAE" conforme ID

function fkg_cd_cnae_id ( en_cnae_id in cnae.id%TYPE )
         return cnae.cd%TYPE
is

   vv_cnae_cd  cnae.cd%TYPE;

begin
   --
   select c.cd
     into vv_cnae_cd
     from cnae c
    where c.id = en_cnae_id;
   --
   return vv_cnae_cd;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error (-20100, 'Erro na fkg_cd_cnae_id: ' || sqlerrm);
end fkg_cd_cnae_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna o NOME da tabela NEO_PAPEL conforme ID

function fkg_papel_nome_conf_id ( en_papel_id in neo_papel.id%type )
         return neo_papel.nome%type
is
   --
   vn_papel_nome neo_papel.nome%type := null;
   --
begin
   --
   select nome
     into vn_papel_nome
     from neo_papel
    where id = en_papel_id;
   --
   return vn_papel_nome;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_papel_nome_conf_id:' || sqlerrm);
end fkg_papel_nome_conf_id;
--
-- ============================================================================================ --
-- Função retorna o campo EMPRESA_ID conforme o multorg_id e (CPF ou CNPJ)
-- Esta função é uma cópia da fkg_empresa_id_pelo_cpf_cnpj, porém essa nova não considera
-- se a empresa está ativa ou não.
--
function fkg_empresa_id_cpf_cnpj ( en_multorg_id  in mult_org.id%type
                                 , ev_cpf_cnpj    in varchar2
                                 ) return Empresa.id%TYPE is
   --
   vn_empresa_id Empresa.id%TYPE := null;
   --
begin
   --
   -- NÃO ALTERE A REGRA DESSAS ROTINAS SEM CONVERSAR COM EQUIPE
   --
   if rtrim(ltrim(ev_cpf_cnpj)) is not null then
      --
      begin
         --
         select e.id
           into vn_empresa_id
           from empresa   e
              , juridica  j
          where e.multorg_id = en_multorg_id
            and e.dm_situacao = 1
            and j.pessoa_id  = e.pessoa_id
            and j.num_cnpj   = to_number( substr(ev_cpf_cnpj,  1, 8) )
            and j.num_filial = to_number( substr(ev_cpf_cnpj,  9, 4) )
            and j.dig_cnpj   = to_number( substr(ev_cpf_cnpj, 13, 2) );
         --
      exception
         when too_many_rows then
            --
            begin
               --
               select e.id
                 into vn_empresa_id
                 from empresa e
                where e.pessoa_id in ( select max(p.id)
                                         from Pessoa    p
                                            , Juridica  j
                                        where p.multorg_id = en_multorg_id
                                          and j.pessoa_id  = p.id
                                          and j.num_cnpj   = to_number( substr(ev_cpf_cnpj,  1, 8) )
                                          and j.num_filial = to_number( substr(ev_cpf_cnpj,  9, 4) )
                                          and j.dig_cnpj   = to_number( substr(ev_cpf_cnpj, 13, 2) ) );
            exception
               when no_data_found then
                  --
                  begin
                     --
                     select e.id
                       into vn_empresa_id
                       from empresa e
                      where e.pessoa_id in ( select min(p.id)
                                               from Pessoa    p
                                                  , Juridica  j
                                              where p.multorg_id = en_multorg_id
                                                and j.pessoa_id  = p.id
                                                and j.num_cnpj   = to_number( substr(ev_cpf_cnpj,  1, 8) )
                                                and j.num_filial = to_number( substr(ev_cpf_cnpj,  9, 4) )
                                                and j.dig_cnpj   = to_number( substr(ev_cpf_cnpj, 13, 2) ) );
                     --
                  exception
                     when others then
                        vn_empresa_id := null;
                  end;
            end;
            --
      end;
      --
      if nvl(vn_empresa_id,0) <= 0 then
         --
         begin
            --
            select e.id
              into vn_empresa_id
              from empresa e
                 , Fisica  f
             where e.multorg_id = en_multorg_id
               and f.pessoa_id  = e.pessoa_id
               and f.num_cpf    = to_number( substr(ev_cpf_cnpj,  1, 9) )
               and f.dig_cpf    = to_number( substr(ev_cpf_cnpj, 10, 2) );
            --
         exception
            when too_many_rows then
               --
               begin
                  --
                  select e.id
                    into vn_empresa_id
                    from empresa e
                   where e.pessoa_id in ( select max(p.id)
                                            from Pessoa  p
                                               , Fisica  f
                                           where p.multorg_id = en_multorg_id
                                             and f.pessoa_id  = p.id
                                             and f.num_cpf    = to_number( substr(ev_cpf_cnpj,  1, 9) )
                                             and f.dig_cpf    = to_number( substr(ev_cpf_cnpj, 10, 2) ) );
               --
               exception
                  when no_data_found then
                     --
                     begin
                        --
                        select e.id
                          into vn_empresa_id
                          from empresa e
                         where e.pessoa_id in ( select min(p.id)
                                                  from Pessoa  p
                                                     , Fisica  f
                                                 where p.multorg_id = en_multorg_id
                                                   and f.pessoa_id  = p.id
                                                   and f.num_cpf    = to_number( substr(ev_cpf_cnpj,  1, 9) )
                                                   and f.dig_cpf    = to_number( substr(ev_cpf_cnpj, 10, 2) ) );
                     --
                     exception
                        when others then
                           vn_empresa_id := null;
                     end;
                     --
               end;
         end;
         --
      end if;
      --
   end if;
   --
   return vn_empresa_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_empresa_id_cpf_cnpj: ' || sqlerrm);
end fkg_empresa_id_cpf_cnpj;
--
-- ============================================================================================ --
--| Função retorna o NRO_PROC da tabela RET_EVENTO_EPEC conforme ID da nota

function fkg_ret_evento_epec_proc_id ( en_notafiscal_id in nota_fiscal.id%type )
         return ret_evento_epec.nro_proc%type
is
   --
   vv_nro_proc ret_evento_epec.nro_proc%type;
   --
begin
   --
   select nro_proc
     into vv_nro_proc
     from ret_evento_epec
    where notafiscal_id = en_notafiscal_id
      and nro_proc is not null;
   --
   return vv_nro_proc;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_ret_evento_epec_proc_id:' || sqlerrm);
end fkg_ret_evento_epec_proc_id;

-------------------------------------------------------------------------------------------------------

--| Função retorna o COD_STAT da tabela RET_EVENTO_EPEC conforme ID da nota

function fkg_ret_evento_epec_stat_id ( en_notafiscal_id in nota_fiscal.id%type )
         return ret_evento_epec.cod_stat%type
is
   --
   vv_cod_stat ret_evento_epec.cod_stat%type;
   --
begin
   --
   select cod_stat
     into vv_cod_stat
     from ret_evento_epec
    where notafiscal_id = en_notafiscal_id
      and nro_proc is not null;
   --
   return vv_cod_stat;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_ret_evento_epec_stat_id:' || sqlerrm);
end fkg_ret_evento_epec_stat_id;

-------------------------------------------------------------------------------------------------------

--| Retorna o limite de quantade de dias para emissão da NFe conforme a empresa

function fkg_estado_lim_emiss_nfe ( en_empresa_id in empresa.id%type )
         return estado.lim_emiss_nfe%type
is
   --
   vn_lim_emiss_nfe    estado.lim_emiss_nfe%type;
   --
begin
   --
   select est.lim_emiss_nfe
     into vn_lim_emiss_nfe
     from empresa e
        , pessoa p
        , cidade c
        , estado est
    where e.id = en_empresa_id
      and e.pessoa_id = p.id
      and p.cidade_id = c.id
      and c.estado_id = est.id;
   --
   return vn_lim_emiss_nfe;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_estado_lim_emiss_nfe:' || sqlerrm);
end fkg_estado_lim_emiss_nfe;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da nota Fiscal a partir do número da chave de acesso e empresa_id

function fkg_notafiscal_id_chave_empr ( en_nro_chave_nfe  in Nota_Fiscal.nro_chave_nfe%TYPE
                                      , en_empresa_id     in empresa.id%type
                                      )
         return Nota_Fiscal.id%TYPE
is

   vn_notafiscal_id  Nota_Fiscal.id%TYPE := null;

begin

   if en_nro_chave_nfe is not null then
      --
      select max(nf.id)
        into vn_notafiscal_id
        from Nota_Fiscal  nf
       where nf.nro_chave_nfe = en_nro_chave_nfe
         and nf.empresa_id = en_empresa_id;
      --
   end if;

   return vn_notafiscal_id;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_notafiscal_id_chave_empr:' || sqlerrm);
end fkg_notafiscal_id_chave_empr;

-------------------------------------------------------------------------------------------------------

-- Função retorna situação do documento da Nota Fiscal através do identificador da nota fiscal
function fkg_sitdoc_id_nf ( en_notafiscal_id in nota_fiscal.id%type )
         return sit_docto.id%type
is
   --
   vn_sitdocto_id sit_docto.id%type := null;
   --
begin
   --
   if nvl(en_notafiscal_id,0) > 0 then
      --
      begin
         select nf.sitdocto_id
           into vn_sitdocto_id
           from nota_fiscal nf
          where nf.id = en_notafiscal_id;
      exception
         when no_data_found then
            vn_sitdocto_id := null;
      end;
      --
   end if;
   --
   return(nvl(vn_sitdocto_id,0));
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_sitdoc_id_nf:' || sqlerrm);
end fkg_sitdoc_id_nf;

-------------------------------------------------------------------------------------------------------

-- Função retorna a data de contingência da Nota Fiscal através do identificador
function fkg_dt_cont_nf ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal.dt_cont%type
is
   --
   vd_dtcont nota_fiscal.dt_cont%type := null;
   --
begin
   --
   select nf.dt_cont
     into vd_dtcont
     from nota_fiscal nf
    where nf.id = en_notafiscal_id;
   --
   return vd_dtcont;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_dt_cont_nf:' || sqlerrm);
end fkg_dt_cont_nf;

-------------------------------------------------------------------------------------------------------

-- Função retorna DM_VAL_NCM_ITEM através do ID da empresa.
function fkg_dmvalncm_empid(en_empresa_id in empresa.id%type)
         return empresa.dm_val_ncm_item%type
is
   --
   vn_dm_val_ncm_item   empresa.dm_val_ncm_item%type;
   --
begin
   --
   select e.dm_val_ncm_item
     into vn_dm_val_ncm_item
     from empresa e
    where e.id = en_empresa_id;
   --
   return vn_dm_val_ncm_item;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_dmvalncm_empid:' || sqlerrm);
end fkg_dmvalncm_empid;

-------------------------------------------------------------------------------------------------------

-- Função que retorna DM_DT_ESCR_DFEPOE através do ID da empresa.
function fkg_dmdtescrdfepoe_empresa(en_empresa_id in empresa.id%type)
         return empresa.dm_dt_escr_dfepoe%type
is
   --
   vn_dm_dt_escr_dfepoe empresa.dm_dt_escr_dfepoe%type;
   --
begin
   --
   select em.dm_dt_escr_dfepoe
     into vn_dm_dt_escr_dfepoe
     from empresa em
    where em.id = en_empresa_id;
   --
   return vn_dm_dt_escr_dfepoe;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_dmdtescrdfepoe_empresa:' || sqlerrm);
end fkg_dmdtescrdfepoe_empresa;

-------------------------------------------------------------------------------------------------------

-- Função que retorna cidade_id da empresa da nota informada.

function fkg_cidade_id_nf_id ( en_notafiscal_id in nota_fiscal.id%type)
         return cidade.id%type
is
   --
   vn_cidade_id cidade.id%type;
   --
begin
   --
   select p.cidade_id
     into vn_cidade_id
     from nota_fiscal nf
        , empresa e
        , pessoa p
    where nf.id = en_notafiscal_id
      and nf.empresa_id = e.id
      and e.pessoa_id = p.id;
   --
   return vn_cidade_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_cidade_id_nf_id:' || sqlerrm);
end fkg_cidade_id_nf_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o id do país conforme o "Pais do tipo do código de arquivo" e "Tipo de Código de arquivo"

function fkg_pais_id_tipo_cod_arq ( ev_paistipocodarq_cd in pais_tipo_cod_arq.cd%type
                                  , ev_tipocodarq_cd     in tipo_cod_arq.cd%type
                                  , en_pais_id           in pais.id%type
                                  )
         return pais.id%type
is
   --
   vv_pais_id pais.id%type;
   --
begin
   --
   select ptca.pais_id
     into vv_pais_id
     from pais_tipo_cod_arq ptca
        , tipo_cod_arq tca
    where ptca.cd = ev_paistipocodarq_cd
      and ptca.pais_id = en_pais_id
      and ptca.tipocodarq_id = tca.id
      and tca.cd = ev_tipocodarq_cd;
   --
   return vv_pais_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_pais_id_tipo_cod_arq:' || sqlerrm);
end fkg_pais_id_tipo_cod_arq;

-------------------------------------------------------------------------------------------------------

-- Função retorna o id do país conforme o codigo do "Pais do tipo do código de arquivo" e do "Tipo de Código de arquivo"

function fkg_pais_id_tipo_arq_cd ( ev_paistipocodarq_cd in pais_tipo_cod_arq.cd%type
                                 , ev_tipocodarq_cd     in tipo_cod_arq.cd%type
                                 )
         return pais.id%type
is
   --
   vv_pais_id pais.id%type;
   --
begin
   --
   select ptca.pais_id
     into vv_pais_id
     from pais_tipo_cod_arq ptca
        , tipo_cod_arq tca
    where ptca.cd = ev_paistipocodarq_cd
      and ptca.tipocodarq_id = tca.id
      and tca.cd = ev_tipocodarq_cd;
   --
   return vv_pais_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_pais_id_tipo_arq_cd:' || sqlerrm);
end fkg_pais_id_tipo_arq_cd;

-------------------------------------------------------------------------------------------------------

-- Função retorna a inscrição municipal da pessoa

function fkg_inscr_mun_pessoa ( en_pessoa_id  in pessoa.id%TYPE )
         return juridica.im%TYPE
is
   --
   vv_im  juridica.im%type := null;
   --
begin

   if nvl(en_pessoa_id,0) > 0 then
      --
      select j.im
        into vv_im
        from juridica j
       where j.pessoa_id  = en_pessoa_id;
      --
   end if;
   --
   return vv_im;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_inscr_mun_pessoa:' || sqlerrm);
end fkg_inscr_mun_pessoa;

-------------------------------------------------------------------------------------------------------
-- Função para descrever valores por extenso
function fkg_descValor_extenso(valor number)
/*redmine : 10808 -- fabricio jacob -- 31/08/2015*/
  return varchar2 is
  extenso     varchar2(240);
  b1          number(1);
  b2          number(1);
  b3          number(1);
  b4          number(1);
  b5          number(1);
  b6          number(1);
  b7          number(1);
  b8          number(1);
  b9          number(1);
  b10         number(1);
  b11         number(1);
  b12         number(1);
  b13         number(1);
  b14         number(1);
  l1          varchar2(12);
  l2          varchar2(3);
  l3          varchar2(9);
  l4          varchar2(3);
  l5          varchar2(6);
  l6          varchar2(8);
  l7          varchar2(12);
  l8          varchar2(3);
  l9          varchar2(9);
  l10         varchar2(3);
  l11         varchar2(6);
  l12         varchar2(8);
  l13         varchar2(12);
  l14         varchar2(3);
  l15         varchar2(9);
  l16         varchar2(3);
  l17         varchar2(6);
  l18         varchar2(8);
  l19         varchar2(12);
  l20         varchar2(3);
  l21         varchar2(9);
  l22         varchar2(3);
  l23         varchar2(6);
  l24         varchar2(16);
  l25         varchar2(3);
  l26         varchar2(9);
  l27         varchar2(3);
  l28         varchar2(6);
  l29         varchar2(17);
  virgula_bi  char(3);
  virgula_mi  char(3);
  virgula_mil char(3);
  virgula_cr  char(3);
  valor1      char(14); -- TABELA DE CENTENAS --
  centenas    char(108) := '       Cento    Duzentos   Trezentos' ||
                           'Quatrocentos  Quinhentos  Seiscentos' ||
                           '  Setecentos  Oitocentos  Novecentos'; -- TABELA DE DEZENAS --
  dezenas     char(79) := '      Dez    Vinte   Trinta Quarenta' ||
                          'Cinquenta Sessenta  Setenta  Oitenta' ||
                          'Noventa'; -- TABELA DE UNIDADES --
  unidades    char(54) := '    Um  Dois  TresQuatro Cinco  Seis' ||
                          '  Sete  Oito  Nove'; -- TABELA DE UNIDADES DA DEZENA 10 --
  unid10      char(81) := '     Onze     Doze    Treze Quatorze' ||
                          '   QuinzeDezesseisDezessete  Dezoito' ||
                          ' Dezenove';
begin
  valor1 := lpad(to_char(valor * 100), 14, '0');
  b1     := substr(valor1, 1, 1);
  b2     := substr(valor1, 2, 1);
  b3     := substr(valor1, 3, 1);
  b4     := substr(valor1, 4, 1);
  b5     := substr(valor1, 5, 1);
  b6     := substr(valor1, 6, 1);
  b7     := substr(valor1, 7, 1);
  b8     := substr(valor1, 8, 1);
  b9     := substr(valor1, 9, 1);
  b10    := substr(valor1, 10, 1);
  b11    := substr(valor1, 11, 1);
  b12    := substr(valor1, 12, 1);
  b13    := substr(valor1, 13, 1);
  b14    := substr(valor1, 14, 1);
  if valor != 0 then
    if b1 != 0 then
      if b1 = 1 then
        if b2 = 0 and b3 = 0 then
          l5 := 'Cem';
        else
          l1 := substr(centenas, b1 * 12 - 11, 12);
        end if;
      else
        l1 := substr(centenas, b1 * 12 - 11, 12);
      end if;
    end if;
    if b2 != 0 then
      if b2 = 1 then
        if b3 = 0 then
          l5 := 'Dez';
        else
          l3 := substr(unid10, b3 * 9 - 8, 9);
        end if;
      else
        l3 := substr(dezenas, b2 * 9 - 8, 9);
      end if;
    end if;
    if b3 != 0 then
      if b2 != 1 then
        l5 := substr(unidades, b3 * 6 - 5, 6);
      end if;
    end if;
    if b1 != 0 or b2 != 0 or b3 != 0 then
      if (b1 = 0 and b2 = 0) and b3 = 1 then
        l5 := 'Hum';
        l6 := ' Bilhão';
      else
        l6 := ' Bilhões';
      end if;
      if valor > 999999999 then
        virgula_bi := ' e ';
        if (b4 + b5 + b6 + b7 + b8 + b9 + b10 + b11 + b12) = 0 then
          virgula_bi := ' de';
        end if;
      end if;
      l1 := ltrim(l1);
      l3 := ltrim(l3);
      l5 := ltrim(l5);
      if b2 > 1 and b3 > 0 then
        l4 := ' e ';
      end if;
      if b1 != 0 and (b2 != 0 or b3 != 0) then
        l2 := ' e ';
      end if;
    end if; -- ROTINA DOS MILHOES --
    if b4 != 0 then
      if b4 = 1 then
        if b5 = 0 and b6 = 0 then
          l7 := 'Cem';
        else
          l7 := substr(centenas, b4 * 12 - 11, 12);
        end if;
      else
        l7 := substr(centenas, b4 * 12 - 11, 12);
      end if;
    end if;
    if b5 != 0 then
      if b5 = 1 then
        if b6 = 0 then
          l11 := 'Dez';
        else
          l9 := substr(unid10, b6 * 9 - 8, 9);
        end if;
      else
        l9 := substr(dezenas, b5 * 9 - 8, 9);
      end if;
    end if;
    if b6 != 0 then
      if b5 != 1 then
        l11 := substr(unidades, b6 * 6 - 5, 6);
      end if;
    end if;
    if b4 != 0 or b5 != 0 or b6 != 0 then
      if (b4 = 0 and b5 = 0) and b6 = 1 then
        l11 := ' Hum';
        l12 := ' Milhão';
      else
        l12 := ' Milhões';
      end if;
      if valor > 999999 then
        virgula_mi := ' e ';
        if (b7 + b8 + b9 + b10 + b11 + b12) = 0 then
          virgula_mi := ' de';
        end if;
      end if;
      l7  := ltrim(l7);
      l9  := ltrim(l9);
      l11 := ltrim(l11);
      if b5 > 1 and b6 > 0 then
        l10 := ' e ';
      end if;
      if b4 != 0 and (b5 != 0 or b6 != 0) then
        l8 := ' e ';
      end if;
    end if; -- ROTINA DOS MILHARES --
    if b7 != 0 then
      if b7 = 1 then
        if b8 = 0 and b9 = 0 then
          l17 := 'Cem';
        else
          l13 := substr(centenas, b7 * 12 - 11, 12);
        end if;
      else
        l13 := substr(centenas, b7 * 12 - 11, 12);
      end if;
    end if;
    if b8 != 0 then
      if b8 = 1 then
        if b9 = 0 then
          l17 := 'Dez';
        else
          l15 := substr(unid10, b9 * 9 - 8, 9);
        end if;
      else
        l15 := substr(dezenas, b8 * 9 - 8, 9);
      end if;
    end if;
    if b9 != 0 then
      if b8 != 1 then
        l17 := substr(unidades, b9 * 6 - 5, 6);
      end if;
    end if;
    if b7 != 0 or b8 != 0 or b9 != 0 then
      if (b7 = 0 and b8 = 0) and b9 = 1 then
        l17 := 'Hum';
        l18 := ' Mil';
      else
        l18 := ' Mil';
      end if;
      if valor > 999 and (b10 + b11 + b12) != 0 then
        virgula_mil := ' e ';
      end if;
      l13 := ltrim(l13);
      l15 := ltrim(l15);
      l17 := ltrim(l17);
      if b8 > 1 and b9 > 0 then
        l16 := ' e ';
      end if;
      if b7 != 0 and (b8 != 0 or b9 != 0) then
        l14 := ' e ';
      end if;
    end if; -- ROTINA DOS REAIS --
    if b10 != 0 then
      if b10 = 1 then
        if b11 = 0 and b12 = 0 then
          l19 := 'Cem';
        else
          l19 := substr(centenas, b10 * 12 - 11, 12);
        end if;
      else
        l19 := substr(centenas, b10 * 12 - 11, 12);
      end if;
    end if;
    if b11 != 0 then
      if b11 = 1 then
        if b12 = 0 then
          l23 := 'Dez';
        else
          l21 := substr(unid10, b12 * 9 - 8, 9);
        end if;
      else
        l21 := substr(dezenas, b11 * 9 - 8, 9);
      end if;
    end if;
    if b12 != 0 then
      if b11 != 1 then
        l23 := substr(unidades, b12 * 6 - 5, 6);
      end if;
    end if;
    if b10 != 0 or b11 != 0 or b12 != 0 then
      if valor > 0 and valor < 2 then
        l23 := 'Hum';
      end if;
      l19 := ltrim(l19);
      l21 := ltrim(l21);
      l23 := ltrim(l23);
      if b11 > 1 and b12 > 0 then
        l22 := ' e ';
      end if;
      if b10 != 0 and (b11 != 0 or b12 != 0) then
        l20 := ' e ';
      end if;
    end if;
    if valor > 0 and valor < 2 then
      if b12 != 0 then
        l24 := ' Real';
      end if;
    else
      if valor > 1 then
        l24 := ' Reais';
      end if;
    end if; -- TRATA CENTAVOS --
    if b13 != 0 OR b14 != 0 then
      if valor > 0 then
        if (b12 != 0) or
           (b1 + b2 + b3 + b4 + b5 + b6 + b7 + b8 + b9 + b10 + b11 + b12) != 0 then
          L25 := ' e ';
        end if;
      end if;
      if b13 != 0 then
        if b13 = 1 then
          if b14 = 0 then
            l28 := 'Dez';
          else
            l26 := substr(unid10, b14 * 9 - 8, 9);
          end if;
        else
          l26 := substr(dezenas, b13 * 9 - 8, 9);
        end if;
      end if;
      if b14 != 0 then
        if b13 != 1 then
          l28 := substr(unidades, b14 * 6 - 5, 6);
        end if;
      end if;
      if b13 != 0 or b14 != 0 then
        if valor = 1 then
          l28 := 'Hum';
        end if;
        l26 := ltrim(l26);
        l28 := ltrim(l28);
        if b13 > 1 and b14 > 0 then
          l27 := ' e ';
        end if;
      end if;
      if (b1 + b2 + b3 + b4 + b5 + b6 + b7 + b8 + b9 + b10 + b11 + b12) > 0 then
        if b13 = 0 and b14 = 1 then
          l29 := ' Centavo';
        else
          l29 := ' Centavos';
        end if;
      else
        if b13 = 0 and b14 = 1 then
          l29 := ' Centavo de Real';
        else
          l29 := ' Centavos de Real';
        end if;
      end if;
    end if; -- CONCATENAR O LITERAL --
    if l29 = ' Centavo de Real' or l29 = ' Centavos de Real' then
      virgula_mil := '';
    end if;
    extenso := l1 || l2 || l3 || l4 || l5 || l6 || virgula_bi || L7 || L8 || L9 || L10 || L11 || l12 ||
               virgula_mi || l13 || l14 || l15 || l16 || l17 || l18 ||
               virgula_mil || L19 || L20 || L21 || L22 || L23 || l24 ||
               virgula_cr || L25 || L26 || L27 || L28 || L29;
    extenso := ltrim(extenso);
    extenso := replace(extenso, '  ', ' ');
  else
    extenso := 'Zero';
  end if;
  return extenso;
end fkg_descValor_extenso;

-------------------------------------------------------------------------------------------------------

-- Função retorna TRUE se existe grupo de tributação do imposto ICMS ou FALSE caso não exista

function fkg_existe_imp_itemnficmsdest ( en_impitemnf_id in imp_itemnf_icms_dest.id%type )
         return boolean
is
   --
   vn_dummy number;
   --
begin
   --
   select distinct 1
     into vn_dummy
     from imp_itemnf_icms_dest ii
    where ii.impitemnf_id = en_impitemnf_id;
   --
   return (nvl(vn_dummy,0) > 0);
   --
exception
   when others then
      return false;
end fkg_existe_imp_itemnficmsdest;

-------------------------------------------------------------------------------------------------------

-- Função recupera o "Código" do Enquadramento Legal do IPI conforme ID
function fkg_cd_enq_legal_ipi ( en_enqlegalipi_id in enq_legal_ipi.id%type )
         return enq_legal_ipi.cd%type
is
   --
   vv_enqlegalipi_cd enq_legal_ipi.cd%type;
   --
begin
   --
   select cd
     into vv_enqlegalipi_cd
     from enq_legal_ipi
    where id = en_enqlegalipi_id;
   --
   return vv_enqlegalipi_cd;
   --
exception
   when others then
      return null;
end fkg_cd_enq_legal_ipi;

-------------------------------------------------------------------------------------------------------

-- Função recupera o "ID" do Enquadramento Legal do IPI conforme Código
function fkg_id_enq_legal_ipi ( ev_enqlegalipi_cd in enq_legal_ipi.cd%type )
         return enq_legal_ipi.id%type
is
   --
   vn_enqlegalipi_id enq_legal_ipi.id%type;
   --
begin
   --
   select id
     into vn_enqlegalipi_id
     from enq_legal_ipi
    where cd = ev_enqlegalipi_cd;
   --
   return vn_enqlegalipi_id;
   --
exception
   when others then
      return 0;
end fkg_id_enq_legal_ipi;

-------------------------------------------------------------------------------------------------------

procedure pkb_cria_nat_oper( ev_cod_nat         nat_oper.cod_nat%type
                           , ev_descr_nat       nat_oper.descr_nat%type default null
                           , en_multorg_id      mult_org.id%type)
is
   --
   --
begin
   --
   if trim( ev_cod_nat ) is not null
      and trim( ev_descr_nat ) is not null
      and nvl(en_multorg_id,0) > 0 then
      --
      insert into Nat_Oper ( id
                           , cod_nat
                           , descr_nat
                           , multorg_id
                           , dm_st_proc
                           )
                     values
                           ( natoper_seq.nextval
                           , trim(ev_cod_nat)
                           , trim(ev_descr_nat)
                           , en_multorg_id
                           , 1
                           );
      --
      commit;
      --
   elsif trim( ev_cod_nat ) is not null
     and nvl(en_multorg_id,0) > 0 then
      --
      insert into Nat_Oper ( id
                           , cod_nat
                           , descr_nat
                           , multorg_id
                           , dm_st_proc
                           )
                     values
                           ( natoper_seq.nextval
                           , trim(ev_cod_nat)
                           , 'Natureza de Operacao'
                           , en_multorg_id
                           , 1
                           );
      --
      commit;
      --
   end if;
   --
exception
   when others then
      --
      null;
      --
end;

-----------------------------------------------------------------------------------------------------
--Retorna o DM_OBRIG_INTEGR do mult org informado. 1 - obrigatorio, 0 - não obrigatorio;

function fkg_multorg_obrig_integr (en_multorg_id    mult_org.id%type)
         return mult_org.DM_OBRIG_INTEGR%type
is
   --
   vn_multorg_obrigintegr   mult_org.dm_obrig_integr%type;
   --
begin
   --
   select DM_OBRIG_INTEGR
     into vn_multorg_obrigintegr
     from mult_org
    where id = en_multorg_id;
   --
   return vn_multorg_obrigintegr;
   --
exception
   when others then
      --
      return 0;
      --
end fkg_multorg_obrig_integr;

-------------------------------------------------------------------------------------------------------
--Retorna o conteudo adicional referente a nota fiscal, atraves do id da mesma.

function fkg_info_adicionais (en_notafiscal_id in nota_fiscal.id%type)
         return varchar2
is
   --
   vv_retorno varchar2(4000):= null;
   --
   cursor c_dados is
      select conteudo
      from  nfinfor_adic
      where notafiscal_id = en_notafiscal_id;
   --
   begin
      --
      for r_dados in c_dados loop
         exit when c_dados%notfound or (c_dados%notfound) is null;
         --
         if (vv_retorno is null) then
            --
            vv_retorno := trim(r_dados.conteudo);
            --
         else
            --
            vv_retorno := trim(vv_retorno)||' '||trim(r_dados.conteudo);
            --
         end if;
         --
      end loop;
      --
      return vv_retorno;
      --
   exception
      when others then
         --
         return null;
         --
   --
end fkg_info_adicionais;

-------------------------------------------------------------------------------------------------------
--| Função identifica se a data de vencimento do certificado está OK

function fkg_empr_dt_venc_cert_ok ( en_empresa_id in empresa.id%type )
         return boolean
is
   --
   vn_dummy            number := 0; -- 0-não ok, 1-sim ok
   vn_dm_tp_cert       empresa.dm_tp_cert%type;
   vd_dt_venc_cert     empresa.dt_venc_cert%type;
   vd_dt_venc_cert_hsm empresa.dt_venc_cert_hsm%type;
   --
begin
   --
   if nvl(en_empresa_id,0) > 0 then
      --
      select em.dm_tp_cert
           , em.dt_venc_cert
           , em.dt_venc_cert_hsm
        into vn_dm_tp_cert
           , vd_dt_venc_cert
           , vd_dt_venc_cert_hsm
        from empresa em
       where em.id = en_empresa_id;
      --
      if vn_dm_tp_cert in (1,2) then -- 1-Tipo A1, 2-Tipo A3
         --
         if vd_dt_venc_cert is null or
            trunc(vd_dt_venc_cert) < trunc(sysdate) then
            --
            vn_dummy := 0;
            --
         else
            --
            vn_dummy := 1;
            --
         end if;
         --
      else -- vn_dm_tp_cert in (3) -- 3-HSM
         --
         if vd_dt_venc_cert_hsm is null or
            trunc(vd_dt_venc_cert_hsm) < trunc(sysdate) then
            --
            vn_dummy := 0;
            --
         else
            --
            vn_dummy := 1;
            --
         end if;
         --
      end if;
      --
   end if;
   --
   return (vn_dummy = 1);
   --
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_empr_dt_venc_cert_ok:' || sqlerrm);
end fkg_empr_dt_venc_cert_ok;

-------------------------------------------------------------------------------------------------------
--| Função retorna a data de vencimento do certificado

function fkg_empr_dt_venc_cert ( en_empresa_id in empresa.id%type )
         return date
is
   --
   vd_dt_venc date;
   --
begin
   --
   if nvl(en_empresa_id,0) > 0 then
      --
      select decode(em.dm_tp_cert, 3, trunc(em.dt_venc_cert_hsm), trunc(em.dt_venc_cert))
        into vd_dt_venc
        from empresa em
       where em.id = en_empresa_id;
      --
   end if;
   --
   return (vd_dt_venc);
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_empr_dt_venc_cert:' || sqlerrm);
end fkg_empr_dt_venc_cert;

-------------------------------------------------------------------------------------------------------

--| Função retorno do "código do Cest" conforme ID
function fkg_cd_cest_id ( en_cest_id in cest.id%type )
         return cest.cd%type
is
   --
   vv_cest_cd cest.cd%type;
   --
begin
   --
   select cd
     into vv_cest_cd
     from cest
    where id = en_cest_id;
   --
   return vv_cest_cd;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cd_cest_id:' || sqlerrm);
end fkg_cd_cest_id;

-------------------------------------------------------------------------------------------------------

--| Função retorno do "ID do Cest" conforme CD
function fkg_id_cest_cd ( ev_cest_cd in cest.cd%type )
         return cest.id%type
is
   --
   vn_cest_id cest.id%type;
   --
begin
   --
   select id
     into vn_cest_id
     from cest
    where cd = ev_cest_cd;
   --
   return vn_cest_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_id_cest_cd:' || sqlerrm);
end fkg_id_cest_cd;

-------------------------------------------------------------------------------------------------------
--| Função retorna do Valor do Parâmetro de Aguardar Liberação da NFe na Empresa

function fkg_empr_aguard_liber_nfe ( en_empresa_id in empresa.id%type )
         return empresa.dm_aguard_liber_nfe%type
is
   --
   vn_dm_aguard_liber_nfe empresa.dm_aguard_liber_nfe%type;
   --
begin
   --
   if nvl(en_empresa_id,0) > 0 then
      --
      select dm_aguard_liber_nfe
        into vn_dm_aguard_liber_nfe
        from empresa em
       where em.id = en_empresa_id;
      --
   end if;
   --
   return vn_dm_aguard_liber_nfe;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_empr_aguard_liber_nfe:' || sqlerrm);
end fkg_empr_aguard_liber_nfe;

-------------------------------------------------------------------------------------------------------

--| Função retorna a Descrição do Pais conforme Siscomex

function fkg_Descr_Pais_siscomex ( ev_cod_siscomex  in Pais.cod_siscomex%TYPE )
         return Pais.descr%TYPE
is

   vv_descr  Pais.descr%TYPE;

begin

   select descr
     into vv_descr
     from Pais
    where cod_siscomex = ev_cod_siscomex;

   return vv_descr;

exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_Descr_Pais_siscomex:' || sqlerrm);
end fkg_Descr_Pais_siscomex;

-------------------------------------------------------------------------------------------------------
--| Função que pega o valor da sequence
function fkg_vlr_sequence ( ev_sequence_name in seq_tab.sequence_name%type )
         return number
is
   --
   vn_vlr_sequence number := 0;
   --
begin
   --
   if trim(ev_sequence_name) is not null then
      --
      execute immediate 'SELECT ' || trim(ev_sequence_name) || '.NEXTVAL' ||
                     ' from dual '
         into vn_vlr_sequence;
      --
   end if;
   --
   return vn_vlr_sequence;
   --
exception
   when others then
      return -1;
end fkg_vlr_sequence;

-------------------------------------------------------------------------------------------------------
--| Função retorna o primeiro furo ID nos registros da tabela
function fkg_primeiro_furo_id ( ev_tabela    in varchar2
                              , ev_campo_id  in varchar2
                              )
         return number
is
   --
   vn_primeiro_furo_id  number := 0;
   vv_campo_id          varchar2(30);
   --
begin
   --
   if trim(ev_tabela) is not null then
      --
      if trim(ev_campo_id) is null then
         vv_campo_id := 'id';
      else
         vv_campo_id := trim(ev_campo_id);
      end if;
      --
      execute immediate 'SELECT MIN(A) ID ' || 'FROM (SELECT ROWNUM A, B ' ||
                        'FROM ( SELECT ' || vv_campo_id || ' B ' || ' FROM ' ||
                        trim(ev_tabela) || ' ORDER BY ' || vv_campo_id || ' ) ' ||
                        ' ) ' || ' WHERE A < B '
         into vn_primeiro_furo_id;
      --
   end if;
   --
   return vn_primeiro_furo_id;
   --
exception
   when others then
      return -1;
end fkg_primeiro_furo_id;

-------------------------------------------------------------------------------------------------------
--| Função retorna o proximo valor livre (Furo do ID) ou o valor da sequence
function fkg_vlr_livre_sequence ( ev_tabela         in varchar2
                                , ev_campo_id       in varchar2
                                , ev_sequence_name  in seq_tab.sequence_name%type
                                )
         return number
is
   --
   vn_vlr_livre_sequence number := 0;
   vv_campo_id          varchar2(30);
   --
begin
   --
   if trim(ev_tabela) is not null
      and trim(ev_sequence_name) is not null
      then
      --
      vn_vlr_livre_sequence := fkg_primeiro_furo_id ( ev_tabela    => trim(ev_tabela)
                                                    , ev_campo_id  => trim(ev_campo_id)
                                                    );
      --
      if nvl(vn_vlr_livre_sequence,0) <= 0 then
         --
         vn_vlr_livre_sequence := fkg_vlr_sequence ( ev_sequence_name => trim(ev_sequence_name) );
         --
      end if;
      --
   end if;
   --
   return vn_vlr_livre_sequence;
   --
exception
   when others then
      return -1;
end fkg_vlr_livre_sequence;

-------------------------------------------------------------------------------------------------------
--| Função retorna o código identificador da tabela ABERTURA_FCI
function fkg_aberturafci_id ( en_empresa_id in empresa.id%type
                            , ed_dt_ini in abertura_fci.dt_ini%type
                            ) return number
is
   --
   vn_aberturafci_id        abertura_fci.id%type;
   --
begin
   --
   vn_aberturafci_id := null;
   --
   if trim(ed_dt_ini) is not null
    and nvl(en_empresa_id,0) > 0 then
      --
      select id
        into vn_aberturafci_id
        from abertura_fci af
       where af.empresa_id = en_empresa_id
         and af.dt_ini  = ed_dt_ini;
      --
   end if;
   --
   return vn_aberturafci_id;
   --
exception
   when others then
      return -1;
end fkg_aberturafci_id;

-------------------------------------------------------------------------------------------------------
--| Função que retorna o código identificador da tabela ABERTURA_FCI_ARQ
function pk_aberturafciarq_id ( en_aberturafci_id in abertura_fci_arq.aberturafci_id%type
                              , en_nro_sequencia  in abertura_fci_arq.nro_sequencia%type
                              ) return abertura_fci_arq.id%type
is
   --
   vn_aberturafciarq_id       abertura_fci_arq.id%type;
   --
begin
   --
   vn_aberturafciarq_id := null;
   --
   if nvl(en_aberturafci_id,0) > 0
    and nvl(en_nro_sequencia,0) > 0 then
      --
      select id
        into vn_aberturafciarq_id
        from abertura_fci_arq
       where aberturafci_id = en_aberturafci_id
         and nro_sequencia  = en_nro_sequencia;
      --
   end if;
   --
   return vn_aberturafciarq_id;
   --
exception
   when others then
      return -1;
end pk_aberturafciarq_id;

----------------------------------------------------------------------------------------------------
--| Função que retorna o código identificador da tabela de Retorno_Fci
function fkg_infitemfci_id ( en_aberturafciarq_id in abertura_fci_arq.id%type
                           , en_item_id           in item.id%type
                           ) return inf_item_fci.id%type
is
   --
   vn_infitemfci_id       inf_item_fci.id%type := null;
   --
begin
   --
   vn_infitemfci_id := null;
   --
   if nvl(vn_infitemfci_id,0) > 0 then
      --
      select id
        into vn_infitemfci_id
        from inf_item_fci
       where aberturafciarq_id = en_aberturafciarq_id
         and item_id           = en_item_id;
      --
   end if;
   --
   return vn_infitemfci_id;
   --
exception
   when others then
      return -1;
end fkg_infitemfci_id;

----------------------------------------------------------------------------------------------------
--| Função que retorna o código identificador da tabela de Retorno_Fci
function fkg_retornofci_id ( en_item_id       in item.id%type
                           , en_infitemfci_id in inf_item_fci.id%type
                           ) return retorno_fci.id%type
is
   --
   vn_retornofci_id        retorno_fci.id%type;
   --
begin
   --
   vn_retornofci_id := null;
   --
   if nvl(en_item_id,0) > 0
    and nvl(en_infitemfci_id,0) > 0 then
      --
      select id
        into vn_retornofci_id
        from retorno_fci
       where item_id = en_item_id
         and infitemfci_id = en_infitemfci_id;
      --
   end if;
   --
   return vn_retornofci_id;
   --
exception
   when others then
      return -1;
end fkg_retornofci_id;

----------------------------------------------------------------------------------------------------

--| Função de Retornar o ID do Regime Tributário
function fkg_id_reg_trib_cd ( ev_regtrib_cd in reg_trib.cd%type )
         return reg_trib.id%type
is
   --
   vn_regtrib_id   reg_trib.id%type;
   --
begin
   --
   select id
     into vn_regtrib_id
     from reg_trib
    where cd = ev_regtrib_cd;
   --
   return vn_regtrib_id;
   --
exception
   when others then
      return 0;
end fkg_id_reg_trib_cd;

----------------------------------------------------------------------------------------------------

--| Função de Retornar o CD do Regime Tributário
function fkg_cd_reg_trib_id ( en_regtrib_id in reg_trib.id%type )
         return reg_trib.cd%type
is
   --
   vv_regtrib_cd   reg_trib.cd%type;
   --
begin
   --
   select cd
     into vv_regtrib_cd
     from reg_trib
    where id = en_regtrib_id;
   --
   return vv_regtrib_cd;
   --
exception
   when others then
      return null;
end fkg_cd_reg_trib_id;

----------------------------------------------------------------------------------------------------

--| Função retorna o CD da Forma de Tributação
function fkg_cd_forma_trib_id ( en_formatrib_id  in forma_trib.id%type )
         return forma_trib.cd%type
is
   --
   vv_formatrib_cd  forma_trib.cd%type;
   --
begin
   --
   select cd
     into vv_formatrib_cd
     from forma_trib
    where id = en_formatrib_id;
   --
   return vv_formatrib_cd;
   --
exception
   when others then
      return null;
end fkg_cd_forma_trib_id;

----------------------------------------------------------------------------------------------------

--| Função retorna o ID da Forma de Tributação
function fkg_forma_trib_cd ( en_regtrib_id    in reg_trib.id%type
                           , ev_formatrib_cd  in forma_trib.cd%type
                           )
         return forma_trib.id%type
is
   --
   vn_formatrib_id forma_trib.id%type;
   --
begin
   --
   select id
     into vn_formatrib_id
     from forma_trib
    where regtrib_id = en_regtrib_id
      and cd         = ev_formatrib_cd;
   --
   return vn_formatrib_id;
   --
exception
   when others then
      return 0;
end fkg_forma_trib_cd;

----------------------------------------------------------------------------------------------------

--| Função retorna o ID da Incidencia Tributaria
function fkg_id_inc_trib_cd ( ev_inctrib_cd in inc_trib.cd%type )
         return inc_trib.id%type
is
   --
   vn_inctrib_id  inc_trib.id%type;
   --
begin
   --
   select id
     into vn_inctrib_id
     from inc_trib
    where cd = ev_inctrib_cd;
   --
   return vn_inctrib_id;
   --
exception
   when others then
      return 0;
end fkg_id_inc_trib_cd;

----------------------------------------------------------------------------------------------------

--| Função retorna o CD da Incidencia Tributaria
function fkg_cd_inc_trib_id ( en_inctrib_id in inc_trib.id%type )
         return inc_trib.cd%type
is
   --
   vv_inctrib_cd  inc_trib.cd%type;
   --
begin
   --
   select cd
     into vv_inctrib_cd
     from inc_trib
    where id = en_inctrib_id;
   --
   return vv_inctrib_cd;
   --
exception
   when others then
      return 0;
end fkg_cd_inc_trib_id;

-------------------------------------------------------------------------------------------------------

-- Função retor do ID da Mult-Organização conforme código e hash

function fkg_multorg_id ( ev_multorg_cd    in  mult_org.cd%type
                        , ev_multorg_hash  in  mult_org.hash%type
                        )
         return mult_org.id%type
is
   --
   vn_multorg_id mult_org.id%type;
   --
begin
   --
   select id
     into vn_multorg_id
     from mult_org
    where cd    = ev_multorg_cd
      and hash  = ev_multorg_hash;
   --
   return vn_multorg_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_multorg_id:' || sqlerrm);
end fkg_multorg_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o CD da Mult-Organização conforme ID

function fkg_multorg_cd ( en_multorg_id in mult_org.id%type
                        )
         return mult_org.cd%type
is
   --
   vv_multorg_cd mult_org.cd%type;
   --
begin
   --
   select cd
     into vv_multorg_cd
     from mult_org
    where id = en_multorg_id;
   --
   return vv_multorg_cd;
   --
exception
   when others then
      return null;
end fkg_multorg_cd;

----------------------------------------------------------------------------------------------------
--| Função que retorna o código identificador da tabela de COD_NAT_PC
function fkg_codnatpc_id ( ev_cod_nat in cod_nat_pc.cod_nat%type
                         ) return cod_nat_pc.id%type
is
   --
   vn_codnatpc_id        cod_nat_pc.id%type;
   --
begin
   --
   vn_codnatpc_id := null;
   --
   if trim(ev_cod_nat) is not null then
      --
      select id
        into vn_codnatpc_id
        from cod_nat_pc
       where cod_nat = trim(ev_cod_nat);
      --
   end if;
   --
   return vn_codnatpc_id;
   --
exception
   when others then
      return -1;
end fkg_codnatpc_id;

----------------------------------------------------------------------------------------------------
--| Função que retorna o código da tabela de Cod_Nat_Pc
function fkg_codnatpcid_cod_nat ( en_codnatpc_id in cod_nat_pc.id%type
                                ) return cod_nat_pc.id%type
is
   --
   vv_cod_nat                   cod_nat_pc.cod_nat%type;
   --
begin
   --
   vv_cod_nat := null;
   --
   if nvl(en_codnatpc_id,0) > 0 then
      --
      select cod_nat
        into vv_cod_nat
        from cod_nat_pc
       where id = en_codnatpc_id;
      --
   end if;
   --
   return vv_cod_nat;
   --
exception
  when others then
     return -1;
end fkg_codnatpcid_cod_nat;
----------------------------------------------------------------------------------------------------
--| Função que retorna o código identificador da tabela de AGLUT_CONTABIL
function fkg_aglutcontabil_id ( en_empresa_id  in empresa.id%type
                              , ev_cod_agl     in aglut_contabil.cod_agl%type
                              ) return aglut_contabil.id%type
is
   --
   vn_aglutcontabil_id        aglut_contabil.id%type;
   --
begin
   --
   vn_aglutcontabil_id := null;
   --
   if nvl(en_empresa_id,0) > 0
    and trim(ev_cod_agl) is not null then
      --
      select id
        into vn_aglutcontabil_id
        from aglut_contabil
       where empresa_id = en_empresa_id
         and cod_agl = ev_cod_agl;
      --
   end if;
   --
   return vn_aglutcontabil_id;
   --
exception
   when others then
      return -1;
end fkg_aglutcontabil_id;

----------------------------------------------------------------------------------------------------
--| Função que retorna o código da tabela de AGLUT_CONTABIL
function fkg_cd_aglutcontabil ( en_aglutcontabil_id  in aglut_contabil.id%type
                              ) return aglut_contabil.cod_agl%type
is
   --
   vv_cod_agl                 aglut_contabil.cod_agl%type;
   --
begin
   --
   vv_cod_agl := null;
   --
   if nvl(en_aglutcontabil_id,0) > 0 then
      --
      select cod_agl
        into vv_cod_agl
        from aglut_contabil ac
       where id = en_aglutcontabil_id;
      --
   end if;
   --
   return vv_cod_agl;
   --
exception
   when others then
      return -1;
end fkg_cd_aglutcontabil;

----------------------------------------------------------------------------------------------------
--| Função que retorna o código identificador da tabela de PC_AGLUT_CONTABIL
function fkg_pcaglutcontabil_id ( en_planoconta_id    in plano_conta.id%type
                                , en_aglutcontabil_id in aglut_contabil.id%type
                                , en_centrocusto_id   in centro_custo.id%type
                                ) return pc_aglut_contabil.id%TYPE
is
   --
   vn_pcaglutcontabil_id        pc_aglut_contabil.id%TYPE;
   --
begin
   --
   vn_pcaglutcontabil_id := null;
   --
   if nvl(en_planoconta_id,0) > 0
    and nvl(en_aglutcontabil_id,0) > 0 then
      --
      select id
        into vn_pcaglutcontabil_id
        from pc_aglut_contabil
       where planoconta_id = en_planoconta_id
         and aglutcontabil_id = en_aglutcontabil_id
         and nvl(centrocusto_id,0) = nvl(en_centrocusto_id,0);
      --
   end if;
   --
   return vn_pcaglutcontabil_id;
   --
exception
   when others then
      return -1;
end fkg_pcaglutcontabil_id;

----------------------------------------------------------------------------------------------------

-- Procedimento para retornar o Regime Tributário da Empresa e Forma de Tributação
procedure pkb_empresa_forma_trib ( en_empresa_id     in empresa.id%type
                                 , ed_dt_ref         in date
                                 , sn_regtrib_id     out reg_trib.id%type
                                 , sn_formatrib_id   out forma_trib.id%type
                                 )
is
   --
   vn_empresaformatrib_id  empresa_forma_trib.id%type;
   --
begin
   --
   begin
      --
      select max(id)
        into vn_empresaformatrib_id
        from empresa_forma_trib
       where 1 = 1
         and empresa_id = en_empresa_id
         and ed_dt_ref between dt_ini and nvl(dt_fin, ed_dt_ref);
      --
   exception
      when others then
         vn_empresaformatrib_id := null;
   end;
   --
   if nvl(vn_empresaformatrib_id,0) > 0 then
      --
      begin
         --
         select regtrib_id, formatrib_id
           into sn_regtrib_id, sn_formatrib_id
           from empresa_forma_trib
          where id = vn_empresaformatrib_id;
         --
      exception
         when others then
            sn_regtrib_id    := null;
            sn_formatrib_id  := null;
      end;
      --
   else
      --
      sn_regtrib_id    := null;
      sn_formatrib_id  := null;
      --
   end if;
   --
exception
   when others then
      sn_regtrib_id    := null;
      sn_formatrib_id  := null;
end pkb_empresa_forma_trib;

----------------------------------------------------------------------------------------------------

-- Procedimento para retornar CNAE Primario da Empresa
function fkg_empresa_cnae_primario ( en_empresa_id     in empresa.id%type
                                   , ed_dt_ref         in date
                                   )
          return empresa_cnae.id%type
is
   --
   vn_empresacnae_id  empresa_cnae.id%type;
   vn_cnae_id         cnae.id%type;
   --
begin
   --
   begin
      --
      select max(id)
        into vn_empresacnae_id
        from empresa_cnae
       where 1 = 1
         and empresa_id = en_empresa_id
         and dm_tipo    = 1 -- Primario
         and ed_dt_ref between dt_ini and nvl(dt_fin, ed_dt_ref);
      --
   exception
      when others then
         vn_empresacnae_id := null;
   end;
   --
   if nvl(vn_empresacnae_id,0) > 0 then
      --
      begin
         --
         select cnae_id
           into vn_cnae_id
           from empresa_cnae
          where id = vn_empresacnae_id;
         --
      exception
         when others then
            vn_cnae_id    := null;
      end;
      --
   else
      --
      vn_cnae_id    := null;
      --
   end if;
   --
   return vn_cnae_id;
   --
exception
   when others then
      return null;
end fkg_empresa_cnae_primario;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Id de Auto-Relacionamento do "CNAE" conforme ID

function fkg_ar_cnae_id ( en_cnae_id in cnae.id%TYPE )
         return cnae.ar_cnae_id%type
is

   vn_ar_cnae_id  cnae.ar_cnae_id%TYPE;

begin
   --
   select c.ar_cnae_id
     into vn_ar_cnae_id
     from cnae c
    where c.id = en_cnae_id;
   --
   return vn_ar_cnae_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error (-20100, 'Erro na fkg_ar_cnae_id: ' || sqlerrm);
end fkg_ar_cnae_id;

----------------------------------------------------------------------------------------------------

-- Função para retornar o Incidencia Tributária da Empresa
function fkg_empresa_inc_trib ( en_empresa_id     in empresa.id%type
                              , ed_dt_ref         in date
                              )
         return inc_trib.id%type
is
   --
   vn_empresainctrib_id  empresa_inc_trib.id%type;
   vn_inctrib_id         inc_trib.id%type;
   --
begin
   --
   begin
      --
      select max(id)
        into vn_empresainctrib_id
        from empresa_inc_trib
       where 1 = 1
         and empresa_id = en_empresa_id
         and ed_dt_ref between dt_ini and nvl(dt_fin, ed_dt_ref);
      --
   exception
      when others then
         vn_empresainctrib_id := null;
   end;
   --
   if nvl(vn_empresainctrib_id,0) > 0 then
      --
      begin
         --
         select inctrib_id
           into vn_inctrib_id
           from empresa_inc_trib
          where id = vn_empresainctrib_id;
         --
      exception
         when others then
            vn_inctrib_id    := null;
      end;
      --
   else
      --
      vn_inctrib_id    := null;
      --
   end if;
   --
   return vn_inctrib_id;
   --
exception
   when others then
      return null;
end fkg_empresa_inc_trib;
--
----------------------------------------------------------------------------------------------------
--
-- Função para retornar o ID da informação sobre exportação com base na chave
function fkg_busca_infoexp_id ( ev_cpf_cnpj_emit   in   pessoa.cod_part%type
                              , en_dm_ind_doc      in   infor_exportacao.dm_ind_doc%type
                              , en_nro_de          in   infor_exportacao.nro_de%type
                              , ed_dt_de           in   infor_exportacao.dt_de%type
                              , en_nro_re          in   infor_exportacao.nro_re%type
                              , ev_chc_emb         in   infor_exportacao.chc_emb%type
                              , en_multorg_id      in   mult_org.id%type )
         return infor_exportacao.id%type is
   --
   vn_inforexportacao_id infor_exportacao.id%type;
   --
begin
   --
   begin
      --
      select ie.id
        into vn_inforexportacao_id
        from infor_exportacao ie
           , empresa          e
           , pessoa           p
       where ie.empresa_id = e.id
         and e.pessoa_id   = p.id
         and p.cod_part    = ev_cpf_cnpj_emit
         and e.multorg_id  = en_multorg_id
         and ie.dm_ind_doc = en_dm_ind_doc
         and ie.nro_de     = en_nro_de
         and ie.dt_de      = ed_dt_de
         and (en_nro_re  is not null and ie.nro_re  = en_nro_re)
         and (ev_chc_emb is not null and ie.chc_emb = ev_chc_emb)
         and rownum        = 1
       order by ie.id desc;
      --
   exception
      when others then
         vn_inforexportacao_id := null;
   end;
   --
   return vn_inforexportacao_id;
   --
exception
   when others then
      return null;
end fkg_busca_infoexp_id;

----------------------------------------------------------------------------------------------------

-- Função para retornar o ID do documento da informação sobre exportação com base no item e na nota do documento
function fkg_busca_docinfoexp_id ( en_item_id              in   item.id%type
                                 , en_notafiscal_id        in   nota_fiscal.id%type
                                 , en_inforexportacao_id   in   infor_exportacao.id%type )
         return infor_export_nota_fiscal.id%type
is
   --
   vn_inforexportnotafiscal_id         infor_export_nota_fiscal.id%type;
   --
begin
   --
   begin
      --
      select die.id
        into vn_inforexportnotafiscal_id
        from infor_export_nota_fiscal die
       where die.notafiscal_id = en_notafiscal_id
         and die.itemnf_id = en_item_id
         and die.inforexportacao_id = en_inforexportacao_id
         and rownum = 1
       order by die.id desc;
      --
   exception
      when others then
         vn_inforexportnotafiscal_id := null;
   end;
   --
   return vn_inforexportnotafiscal_id;
   --
exception
   when others then
      return null;
end fkg_busca_docinfoexp_id;

----------------------------------------------------------------------------------------------------

--| Função retorno o valor do Parâmetro Global
function fkg_vlr_param_global_csf ( ev_paramglobalcsf_cd in param_global_csf.cd%type )
         return param_global_csf.valor%type
is
   --
   vv_paramglobalcsf_cd param_global_csf.valor%type := null;
   --
begin
   --
   select valor
     into vv_paramglobalcsf_cd
     from param_global_csf
    where cd = ev_paramglobalcsf_cd;
   --
   return vv_paramglobalcsf_cd;
   --
exception
   when others then
      return null;
end fkg_vlr_param_global_csf;

----------------------------------------------------------------------------------------------------

-- Função retorna se a Empresa Utiliza Unidade de Medida da Sefaz por NCM
function fkg_util_unidsefaz_conf_ncm ( en_empresa_id in empresa.id%type )
         return empresa.dm_util_unidsefaz_conf_ncm%type
is
   --
   vn_dm_util_unidsefaz_conf_ncm empresa.dm_util_unidsefaz_conf_ncm%type;
   --
begin
   --
   select dm_util_unidsefaz_conf_ncm
     into vn_dm_util_unidsefaz_conf_ncm
     from empresa
    where id = en_empresa_id;
   --
   return vn_dm_util_unidsefaz_conf_ncm;
   --
exception
   when others then
      return 0;
end fkg_util_unidsefaz_conf_ncm;

----------------------------------------------------------------------------------------------------

-- Função para retornar a Sigla da Unidade de Medida do Sefaz Conforme NCM e Período
function fkg_unidsefaz_conf_ncm ( en_ncm_id     in ncm.id%type
                                , ed_dt_ref     in date
                                )
         return unidade_sefaz.sigla_unid%type
is
   --
   vv_sigla_unid unidade_sefaz.sigla_unid%type;
   --
begin
   --
   begin
      --
      select b.sigla_unid
        into vv_sigla_unid
        from ncm_unid_sefaz a
           , unidade_sefaz b
       where 1 = 1
         and a.ncm_id = en_ncm_id
         and ed_dt_ref between a.dt_ini and nvl(a.dt_fin, ed_dt_ref)
         and b.id = a.unidadesefaz_id;
      --
   exception
      when others then
         vv_sigla_unid := null;
   end;
   --
   return vv_sigla_unid;
   --
exception
   when others then
      return null;
end fkg_unidsefaz_conf_ncm;

----------------------------------------------------------------------------------------------------

-- Função retorna o ID do NCM Supostamente Seperior

function fkg_ncm_id_superior ( ev_cod_ncm  in ncm.cod_ncm%type )
         return ncm.id%type
is
   --
   vn_ncm_id       ncm.id%type;
   vv_cod_ncm_sup  ncm.cod_ncm%type;
   --
begin
   --
   if trim(ev_cod_ncm) is not null then
      --
      vv_cod_ncm_sup := trim( substr( ev_cod_ncm, 1, length(trim(ev_cod_ncm)) - 1 ) );
      --
      if length(trim(vv_cod_ncm_sup)) < 2 then
         vn_ncm_id := null;
      else
         --
         vn_ncm_id := pk_csf.fkg_Ncm_id ( ev_cod_ncm => vv_cod_ncm_sup );
         --
         if nvl(vn_ncm_id,0) <= 0 then
            --
            -- Aplica recursividade
            vn_ncm_id := fkg_ncm_id_superior ( ev_cod_ncm => vv_cod_ncm_sup );
            --
         end if;
         --
      end if;
      --
   end if;
   --
   return vn_ncm_id;
   --
exception
   when others then
      return null;
end fkg_ncm_id_superior;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto ISS - Parâmetro para Notas Fiscais com Emissão Propria

function fkg_empresa_vld_iss_epropria ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_iss_epropria%type
is
   --
   vn_dm_valida_iss_epropria empresa.dm_valida_iss_epropria%type;
   --
begin
   --
   select e.dm_valida_iss_epropria
     into vn_dm_valida_iss_epropria
     from empresa e
    where e.id = en_empresa_id;
   --
   return vn_dm_valida_iss_epropria;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_vld_iss_epropria:' || sqlerrm);
end fkg_empresa_vld_iss_epropria;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto ISS - Parâmetro para Notas Fiscais com Emissão de Terceiros

function fkg_empresa_vld_iss_terc ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_iss_terc%type
is
   --
   vn_dm_valida_iss_terc empresa.dm_valida_iss_terc%type;
   --
begin
   --
   select e.dm_valida_iss_terc
     into vn_dm_valida_iss_terc
     from empresa e
    where e.id = en_empresa_id;
   --
   return vn_dm_valida_iss_terc;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_vld_iss_terc:' || sqlerrm);
end fkg_empresa_vld_iss_terc;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o ibge da cidade do emitente da nota fiscal
function fkg_cidadeibge_notafiscalemit ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal_emit.cidade_ibge%type
is
   --
   vv_cidade_ibge  nota_fiscal_emit.cidade_ibge%type;
   --
begin
   --
   select ne.cidade_ibge
     into vv_cidade_ibge
     from nota_fiscal_emit ne
    where ne.notafiscal_id = en_notafiscal_id;
   --
   return vv_cidade_ibge;
   --
exception
   when no_data_found then
      return null;
   when too_many_rows then
      return null;
   when others then
      raise_application_error(-20101, 'Problemas em fkg_cidadeibge_notafiscalemit. Erro = '||sqlerrm);
end fkg_cidadeibge_notafiscalemit;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o ibge da cidade do destinatário da nota fiscal
function fkg_cidadeibge_notafiscaldest ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal_dest.cidade_ibge%type
is
   --
   vv_cidade_ibge  nota_fiscal_dest.cidade_ibge%type;
   --
begin
   --
   select nd.cidade_ibge
     into vv_cidade_ibge
     from nota_fiscal_dest nd
    where nd.notafiscal_id = en_notafiscal_id;
   --
   return vv_cidade_ibge;
   --
exception
   when no_data_found then
      return null;
   when too_many_rows then
      return null;
   when others then
      raise_application_error(-20101, 'Problemas em fkg_cidadeibge_notafiscaldest. Erro = '||sqlerrm);
end fkg_cidadeibge_notafiscaldest;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o ibge da cidade da pessoa do conhecimento de transporte
function fkg_cidadeibge_conhectransp ( en_conhectransp_id in conhec_transp.id%type )
         return cidade.ibge_cidade%type
is
   --
   vv_cidade_ibge  cidade.ibge_cidade%type;
   --
begin
   --
   select c.ibge_cidade
     into vv_cidade_ibge
     from conhec_transp ct
        , pessoa p
        , cidade c
    where ct.pessoa_id = p.id
      and p.cidade_id = c.id
      and ct.id = en_conhectransp_id;
   --
   return vv_cidade_ibge;
   --
exception
   when no_data_found then
      return null;
   when too_many_rows then
      return null;
   when others then
      raise_application_error(-20101, 'Problemas em fkg_cidadeibge_conhectransp. Erro = '||sqlerrm);
end fkg_cidadeibge_conhectransp;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o ibge da cidade do destinatário do conhecimento de transporte
function fkg_cidadeibge_ct_dest ( en_conhectransp_id in conhec_transp.id%type )
         return conhec_transp_dest.ibge_cidade%type
is
   --
   vv_ibge_cidade  conhec_transp_dest.ibge_cidade%type;
   --
begin
   --
   select ctd.ibge_cidade
     into vv_ibge_cidade
     from conhec_transp_dest ctd
    where ctd.conhectransp_id = en_conhectransp_id;
   --
   return vv_ibge_cidade;
   --
exception
   when no_data_found then
      return null;
   when too_many_rows then
      return null;
   when others then
      raise_application_error(-20101, 'Problemas em fkg_cidadeibge_ct_dest. Erro = '||sqlerrm);
end fkg_cidadeibge_ct_dest;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o ibge da cidade da pessoa da nota fiscal
function fkg_cidadeibge_notafiscalid ( en_notafiscal_id in nota_fiscal.id%type )
         return cidade.ibge_cidade%type
is
   --
   vv_cidade_ibge  cidade.ibge_cidade%type;
   --
begin
   --
   select c.ibge_cidade
     into vv_cidade_ibge
     from nota_fiscal nf
        , pessoa p
        , cidade c
    where nf.pessoa_id = p.id
      and p.cidade_id = c.id
      and nf.id = en_notafiscal_id;
   --
   return vv_cidade_ibge;
   --
exception
   when no_data_found then
      return null;
   when too_many_rows then
      return null;
   when others then
      raise_application_error(-20101, 'Problemas em fkg_cidadeibge_notafiscalid. Erro = '||sqlerrm);
end fkg_cidadeibge_notafiscalid;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o ibge do estado da pessoa da nota fiscal
function fkg_estadoibge_notafiscalid ( en_notafiscal_id in nota_fiscal.id%type )
         return estado.ibge_estado%type
is
   --
   vv_estado_ibge  estado.ibge_estado%type;
   --
begin
   --
   select e.ibge_estado
     into vv_estado_ibge
     from nota_fiscal nf
        , pessoa p
        , cidade c
        , estado e
    where nf.pessoa_id = p.id
      and p.cidade_id = c.id
      and c.estado_id = e.id
      and nf.id = en_notafiscal_id;
   --
   return vv_estado_ibge;
   --
exception
   when no_data_found then
      return null;
   when too_many_rows then
      return null;
   when others then
      raise_application_error(-20101, 'Problemas em fkg_estadoibge_notafiscalid. Erro = '||sqlerrm);
end fkg_estadoibge_notafiscalid;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o ibge do estado do destinatário do conhecimento de transporte
function fkg_estadoibge_ct_dest ( en_conhectransp_id in conhec_transp.id%type )
         return estado.ibge_estado%type
is
   --
   vv_ibge_estado  estado.ibge_estado%type;
   --
begin
   --
   select e.ibge_estado
     into vv_ibge_estado
     from conhec_transp_dest ctd
        , estado e
    where ctd.conhectransp_id = en_conhectransp_id
      and ctd.uf = e.sigla_estado;
   --
   return vv_ibge_estado;
   --
exception
   when no_data_found then
      return null;
   when too_many_rows then
      return null;
   when others then
      raise_application_error(-20101, 'Problemas em fkg_estadoibge_ct_dest. Erro = '||sqlerrm);
end fkg_estadoibge_ct_dest;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o ibge do estado da pessoa do conhecimento de transporte
function fkg_estadoibge_conhectransp ( en_conhectransp_id in conhec_transp.id%type )
         return estado.ibge_estado%type
is
   --
   vv_ibge_estado  cidade.ibge_cidade%type;
   --
begin
   --
   select e.ibge_estado
     into vv_ibge_estado
     from conhec_transp ct
        , pessoa p
        , cidade c
        , estado e
    where ct.pessoa_id = p.id
      and p.cidade_id = c.id
      and c.estado_id = e.id
      and ct.id = en_conhectransp_id;
   --
   return vv_ibge_estado;
   --
exception
   when no_data_found then
      return null;
   when too_many_rows then
      return null;
   when others then
      raise_application_error(-20101, 'Problemas em fkg_estadoibge_conhectransp. Erro = '||sqlerrm);
end fkg_estadoibge_conhectransp;

-------------------------------------------------------------------------------------------------------

--| Função retorna verifica se a empresa Gera Informações de Tributações apenas para Venda
function fkg_empresa_inf_trib_op_venda ( en_empresa_id in empresa.id%type )
         return empresa.dm_inf_trib_oper_venda%type
is
   --
   vn_dm_inf_trib_oper_venda empresa.dm_inf_trib_oper_venda%type;
   --
begin
   --
   select dm_inf_trib_oper_venda
     into vn_dm_inf_trib_oper_venda
     from empresa
    where id = en_empresa_id;
   --
   return vn_dm_inf_trib_oper_venda;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_inf_trib_op_venda:' || sqlerrm);
end fkg_empresa_inf_trib_op_venda;

-------------------------------------------------------------------------------------------------------

FUNCTION fkg_limpa_acento2 ( ev_string IN varchar2 )
         RETURN VARCHAR2 IS
   --
   vv_valor2 varchar2(32767);
   vi        number;
   --
BEGIN
   --
   vi := 0;
   -- Remove os caracteres especiais - o percentual vai permanecer (%).
   vv_valor2 := nvl(ltrim(rtrim(translate(ev_string, 'ÇçåÅâÂãÃáÁàÀäÄêÊéÉèÈëËîÎíÍìÌïÏôÔÕõóÓòÒöÖûÛúÚùÙüÜÿŸýÝñÑÐ\ˆ“¤¶¦æÆø×ƒ¿®±¾½¼«»ðßþÞ¯÷œ¸·¨*?ª§¹²³™š£¢¬´`~^¿¢€¥‰†‡„‹›¦ ¡•§·…–—''’'
                                                   , 'CcaAaAaAaAaAaAeEeEeEeEiIiIiIiIoOOooOoOoOuUuUuUuUyYyYnND'))), ' ');
   --
   vv_valor2 := REPLACE( vv_valor2, chr(9), '');  -- HT-Horizontal Tab
   vv_valor2 := REPLACE( vv_valor2, chr(27), ''); -- ESC-Escape
   vv_valor2 := REPLACE( vv_valor2, chr(13), ''); -- CR-Carriage Return
   vv_valor2 := REPLACE( vv_valor2, chr(31), ''); -- US-Unit Separator
   vv_valor2 := REPLACE( vv_valor2, chr(36), ''); -- $-Dollar
   --
    -- Limpa caracteres Unicode
  --  vv_valor2 := ASCIISTR(vv_valor2);
    vv_valor2 := REPLACE( vv_valor2, '\0081', '');
    vv_valor2 := REPLACE( vv_valor2, '\00AD', '');
    vv_valor2 := REPLACE( vv_valor2, '\00BF', '');
    vv_valor2 := REPLACE( vv_valor2, '\00A9', '');
   --
   -- retira o CHR(10)/Enter/LF-Line Feed, do início do texto
   while ascii(substr(vv_valor2,1,1)) = 10
   loop
      --
      vv_valor2 := substr(vv_valor2,2,length(vv_valor2));
      --
   end loop;
   --
   -- retira o CHR(10)/Enter/LF-Line Feed, do final do texto
   while ascii(substr(vv_valor2,length(vv_valor2),1)) = 10
   loop
      --
      vv_valor2 := substr(vv_valor2,1,length(vv_valor2) - 1);
      --
   end loop;
   --
   RETURN trim(vv_valor2); -- limpa os espaços do início e do fim da string
   --
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE <> -20001 THEN
         raise_application_error(-20001, 'Erro na fkg_limpa_acento2: ' || SQLERRM);
      END IF;
      RAISE;
END fkg_limpa_acento2;

-------------------------------------------------------------------------------------------------------

-- Função retorna o valor do campo Tipo da impressão dos Totais da Tributação

function fkg_tp_impr_tot_trib_empresa ( en_empresa_id in empresa.id%type )
         return empresa.dm_tp_impr_tot_trib%type
is
   --
   vn_dm_tp_impr_tot_trib empresa.dm_tp_impr_tot_trib%type;
   --
begin
   --
   select dm_tp_impr_tot_trib
     into vn_dm_tp_impr_tot_trib
     from empresa
    where id = en_empresa_id;
   --
   return vn_dm_tp_impr_tot_trib;
   --
exception
   when no_data_found then
      return 1;
   when others then
      raise_application_error(-20101, 'Erro na fkg_tp_impr_tot_trib_empresa:' || sqlerrm);
end fkg_tp_impr_tot_trib_empresa;

-------------------------------------------------------------------------------------------------------
-- Função para Recuperar o Código do DIPAM-GIA
function fkg_dipamgia_id ( en_estado_id   in estado.id%type
                         , ev_cd_dipamgia in dipam_gia.cd%type
                         ) return dipam_gia.id%type
is
   --
   vn_dipamgia_id dipam_gia.id%type;
   --
begin
   --
   vn_dipamgia_id := null;
   --
   select id
     into vn_dipamgia_id
     from dipam_gia
    where estado_id = en_estado_id
      and cd        = ev_cd_dipamgia;
   --
   return vn_dipamgia_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_dipamgia_id:' || sqlerrm);
end fkg_dipamgia_id;

-------------------------------------------------------------------------------------------------------
-- Função para Recuperar o Código da Tabela de Parametros do DIPAM-GIA
function fkg_paramdipamgia_id ( en_empresa_id  in empresa.id%type
                              , en_dipamgia_id in dipam_gia.id%type
                              , en_cfop_id     in cfop.id%type
                              , en_item_id     in item.id%type
                              , en_ncm_id      in ncm.id%type
                              ) return param_dipamgia.id%type
is
   --
   vn_paramdipamgia_id        param_dipamgia.id%type;
   --
begin
   --
   vn_paramdipamgia_id := null;
   --
   select id
     into vn_paramdipamgia_id
     from param_dipamgia
   where empresa_id   = en_empresa_id
     and ((dipamgia_id is null and en_dipamgia_id is null) or (dipamgia_id = en_dipamgia_id))
     and cfop_id      = en_cfop_id
     and ((item_id is null and en_item_id is null) or (item_id = en_item_id))
     and ((ncm_id is null and en_ncm_id is null) or (ncm_id = en_ncm_id));
   --
   return vn_paramdipamgia_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_paramdipamgia_id:' || sqlerrm);
end fkg_paramdipamgia_id;

----------------------------------------------------------------------------------------------------

--| Processo que recupera o identificador do fechamento fiscal(id)
function fkg_retorna_csftipolog_id(ev_cd in varchar2)
return number is
   --
   vn_fecha_fiscal_id number := null;
   --
begin
   --
   if ev_cd is not null then
      --
      select ct.id
        into vn_fecha_fiscal_id
        from csf_tipo_log ct
       where ct.cd = upper(ev_cd);
      --
   end if;
   --
   return vn_fecha_fiscal_id;
   --
exception
   when no_data_found then
      --
      return null;
      --
   when others then
      --
      raise_application_error(-20001, 'Erro na fkg_retorna_id_fecha_fiscal: '|| sqlerrm);
      --
end fkg_retorna_csftipolog_id;
--

--------------------------------------------------------------------------------------------------------
--| FUNÇÃO QUE RECUPERA TODOS OS CÓDIGOS CFOP DE ITEM, PERTENCENTES A UMA NOTA FISCAL
--------------------------------------------------------------------------------------------------------
function fkg_recupera_cfop (en_notafiscal_id in number)
return varchar2 is
   --
   cursor c_dados(en_notafiscal_id in number) is
      select distinct cf.cd
        from nota_fiscal      nf
           , item_nota_fiscal inf
           , cfop             cf
       where nf.id = inf.notafiscal_id
         and cf.id = inf.cfop_id
         and nf.id = en_notafiscal_id;
   --
   vn_fase number;
   --
   vv_lista varchar(1000);
   --
begin
   --
   vn_fase := 1;
   --
   vv_lista := null;
   --
   vn_fase := 2;
   --
   if en_notafiscal_id is not null then
      --
      vn_fase := 3;
      --
      for rec in c_dados(en_notafiscal_id => en_notafiscal_id) loop
         exit when c_dados%notfound or (c_dados%notfound) is null;
         --
         if vv_lista is null then
            --
            vv_lista := rec.cd;
            --
         else
            --
            vv_lista := vv_lista ||' '||rec.cd;
            --
         end if;
         --
      end loop;
      --
   end if;
   --
   return vv_lista;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro pk_csf.fkg_recupera_cfop. fase: ('||vn_fase||'), erro ao recuperar os códigos CFOP referente a nota.');
      --
end fkg_recupera_cfop;
--

--------------------------------------------------------------------------------------------------------
--| FUNÇÃO QUE RECUPERA CÓDIGO IDENTIFICADOR DO PROCESSO ADMINISTRATIVO - REINF
--------------------------------------------------------------------------------------------------------
function fkg_procadmefdreinf_id ( en_empresa_id in empresa.id%type
                                , ed_dt_ini     in date
                                , ed_dt_fin     in date
                                , en_dm_tp_proc in number
                                , ev_nro_proc   in varchar2
                                ) return proc_adm_efd_reinf.id%type
is
   --
   vn_procadmefdreinf_id        proc_adm_efd_reinf.id%type;
   --
begin
   --
   vn_procadmefdreinf_id := null;
   --
   if trim(ed_dt_fin) is not null then
      --
      select id
        into vn_procadmefdreinf_id
        from proc_adm_efd_reinf
       where empresa_id = en_empresa_id
         and dt_ini     = ed_dt_ini
         and dt_fin     = ed_dt_fin
         and dm_tp_proc = en_dm_tp_proc
         and nro_proc   = ev_nro_proc;
      --
   else
      --
      select id
        into vn_procadmefdreinf_id
        from proc_adm_efd_reinf
       where empresa_id = en_empresa_id
         and dt_ini     = ed_dt_ini
         and dm_tp_proc = en_dm_tp_proc
         and nro_proc   = ev_nro_proc;
      --
   end if;
   --
   return vn_procadmefdreinf_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20001, 'Erro pk_csf.fkg_procadmefdreinf_id. Erro: ' || sqlerrm);
end fkg_procadmefdreinf_id;

--------------------------------------------------------------------------------------------------------
--| Função que verifica se o código identificador ja existe na tabela
function fkg_verif_procadmefdreinf ( en_procadmefdreinf_id in proc_adm_efd_reinf.id%type
                                   ) return boolean
is
   --
   vn_verif                        number;
   --
begin
   --
   vn_verif := null;
   --
   begin
      select 1
        into vn_verif
        from proc_adm_efd_reinf
       where id = en_procadmefdreinf_id;
   exception
    when no_data_found then
      vn_verif := null;
   end;
   --
   if nvl(vn_verif,0) = 0 then
      return false;
   else
      return true;
   end if;
   --
exception
   when others then
      raise_application_error(-20001, 'Erro pk_csf.fkg_indsuspexig_id Erro: ' || sqlerrm);
end fkg_verif_procadmefdreinf;

--------------------------------------------------------------------------------------------------------
--| Recupera código identificador de Indicativo de Suspensão da Exigibilidade
function fkg_indsuspexig_id ( ev_ind_susp_exig in ind_susp_exig.cd%type
                            ) return ind_susp_exig.id%type
is
   --
   vn_indsuspexig_id        ind_susp_exig.id%type;
   --
begin
   --
   vn_indsuspexig_id := null;
   --
   select id
     into vn_indsuspexig_id
     from ind_susp_exig
    where cd = ev_ind_susp_exig;
   --
   return vn_indsuspexig_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20001, 'Erro pk_csf.fkg_indsuspexig_id Erro: ' || sqlerrm);
end fkg_indsuspexig_id;

----------------------------------------------------------------------------------------------------
--| Função valida se o participante está cadastrado como empresa

function fkg_valida_part_empresa ( en_multorg_id  in mult_org.id%type
                                 , ev_cod_part    in pessoa.cod_part%TYPE
                                 ) return boolean
is
   --
   vn_cont     number  := 0;
   vn_empresa  boolean := false;
   --
begin
   --
   if trim(ev_cod_part) is not null then
      --
      begin
         --
         select count(1)
           into vn_cont
           from pessoa   pe
              , empresa  em
          where pe.multorg_id = en_multorg_id
            and pe.cod_part   = trim(ev_cod_part)
            and pe.id         = em.pessoa_id;
         --
      exception
         when others then
            vn_cont := 0;
      end;
      --
   end if;
   --
   if vn_cont > 0 then
      vn_empresa := true;
   else
      vn_empresa := false;
   end if;
   --
   return vn_empresa;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_valida_part_empresa: ' || sqlerrm);
end fkg_valida_part_empresa;

-------------------------------------------------------------------------------------------------------

-- Função retorna o indicador de atualização de dependências do Item na Integração de Cadastros Gerais - Item
function fkg_empr_dm_atual_dep_item ( en_empresa_id  in empresa.id%type )
         return empresa.dm_atual_dep_item%type
is
   --
   vn_dm_atual_dep_item empresa.dm_atual_dep_item%type;
   --
begin
   --
   select em.dm_atual_dep_item
     into vn_dm_atual_dep_item
     from empresa em
    where em.id = en_empresa_id;
   --
   return vn_dm_atual_dep_item;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_empr_dm_atual_dep_item:' || sqlerrm);
end fkg_empr_dm_atual_dep_item;

-------------------------------------------------------------------------------------------------------
-- Recupera o ID da fonte pagadora do REINF
function fkg_recup_fonte_pagad_reinf_id ( ev_cd_font_pag_reinf  in rel_fonte_pagad_reinf.cod%type )
         return rel_fonte_pagad_reinf.id%type
is
   --
   vn_font_pag_reinf_id     rel_fonte_pagad_reinf.id%type;
   --
begin
   --
   select rf.id
     into vn_font_pag_reinf_id
     from rel_fonte_pagad_reinf   rf
    where rf.cod = ev_cd_font_pag_reinf;
   --
   return vn_font_pag_reinf_id;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_recup_fonte_pagad_reinf_id:' || sqlerrm);
end fkg_recup_fonte_pagad_reinf_id;

-------------------------------------------------------------------------------------------------------
-- Recupera o código da fonte pagadora do REINF
function fkg_recup_fonte_pagad_reinf ( en_relfontepagadreinf_id  in rel_fonte_pagad_reinf.id%type )
         return rel_fonte_pagad_reinf.cod%type
is
   --
   vv_cd_font_pag_reinf     rel_fonte_pagad_reinf.cod%type;
   --
begin
   --
   select rf.cod
     into vv_cd_font_pag_reinf
     from rel_fonte_pagad_reinf   rf
    where rf.id = en_relfontepagadreinf_id;
   --
   return vv_cd_font_pag_reinf;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_recup_fonte_pagad_reinf:' || sqlerrm);
end fkg_recup_fonte_pagad_reinf;

-------------------------------------------------------------------------------------------------------
-- Procedimento retorna o parâmetro que Permite a quebra da Informação Adicional no arquivo Sped Fiscal
function fkg_parefdicmsipi_dmqueinfadi ( en_empresa_id in empresa.id%type )
         return param_efd_icms_ipi.dm_quebra_infadic_spedf%type
is
   --
   vn_dm_quebra_infadic_spedf param_efd_icms_ipi.dm_quebra_infadic_spedf%type;
   --
begin
   --
   select pe.dm_quebra_infadic_spedf
     into vn_dm_quebra_infadic_spedf
     from param_efd_icms_ipi pe
    where pe.empresa_id = en_empresa_id;
   --
   return vn_dm_quebra_infadic_spedf;
   --
exception
   when others then
      return 0;
end fkg_parefdicmsipi_dmqueinfadi;
--
-- ============================================================================================================= --
-- Procedimento retorna o código NIF da pessoa
function fkg_cod_nif_pessoa ( en_pessoa_id in pessoa.id%type ) return pessoa.cod_nif%type is
   --
   vv_cod_nif pessoa.cod_nif%type;
   --
begin
   --
   select p.cod_nif
     into vv_cod_nif
     from pessoa p
    where p.id = en_pessoa_id;
   --
   return vv_cod_nif;
   --
exception
   when others then
      return 0;
end fkg_cod_nif_pessoa;
--
-- ============================================================================================================= --
-- Procedimento retorna o se o país obriga o cod_nif p a pessoa_id
function fkg_pais_obrig_nif ( en_pais_id in pais.id%type ) return pais.dm_obrig_nif%type is
   --
   -- Indicador da obrigatoriedade do código NIF para o residente no país: 0-Não / 1-Sim
   vn_dm_obrig_nif pais.dm_obrig_nif%type;
   --
begin
   --
   select p.dm_obrig_nif
     into vn_dm_obrig_nif
     from pais p
    where p.id = en_pais_id;
   --
   return vn_dm_obrig_nif;
   --
exception
   when others then
      return 0;
end fkg_pais_obrig_nif;
--
-- ============================================================================================================= --
-- Procedimento retorna a sigla do pais da pessoa_id
function fkg_sigla_pais ( en_pessoa_id in pessoa.id%type ) return pais.sigla_pais%type is
   --
   vv_sigla_pais pais.sigla_pais%type;
   --
begin
   --
   select pa.sigla_pais
     into vv_sigla_pais
     from pessoa pe
        , pais   pa
    where pa.id = pe.pais_id
      and pe.id = en_pessoa_id;
   --
   return vv_sigla_pais;
   --
exception
   when others then
      return 0;
end fkg_sigla_pais;
--
-- ============================================================================================================= --
-- Função retorna o valor do parametro dm_guarda_imp_orig
--
function fkg_empresa_guarda_imporig ( en_empresa_id in empresa.id%type ) return empresa.dm_guarda_imp_orig%type is
   --
   vn_dm_guarda_imp_orig  empresa.dm_guarda_imp_orig%type;
   --
begin
   --
   select dm_guarda_imp_orig
     into vn_dm_guarda_imp_orig
     from empresa e
    where e.id = en_empresa_id;
   --
   return vn_dm_guarda_imp_orig;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_guarda_imporig:' || sqlerrm);
end fkg_empresa_guarda_imporig;
--
-- ============================================================================================================= --
-- Função verifica se a nota fiscal já possui os impostos originais salvos na tabela imp_itemnf_orig
--
function fkg_existe_nf_imp ( en_notafiscal_id in nota_fiscal.id%type ) return number is
   --
   vn_qtd_dados number;
   --
begin
   --
   select distinct 1
     into vn_qtd_dados
     from imp_itemnf_orig
    where notafiscal_id = en_notafiscal_id;
   --
   return (nvl(vn_qtd_dados,0));
   --
exception
   when no_data_found then
      return (0);
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_existe_nf_imp:' || sqlerrm);
end fkg_existe_nf_imp;
--
-- ============================================================================================================= --
-- Função verifica se o imposto já foi inserido na tabela imp_itemnf
--
function fkg_existe_imp_itemnf ( en_itemnf_id  in imp_itemnf.itemnf_id%type
                               , en_tipoimp_id in imp_itemnf.tipoimp_id%type
                               , en_dm_tipo    in imp_itemnf.dm_tipo%type ) return number is
   --
   vn_qtd_dados number;
   --
begin
   --
   select distinct 1
     into vn_qtd_dados
     from imp_itemnf t
    where t.itemnf_id  = en_itemnf_id
      and t.tipoimp_id = en_tipoimp_id
      and t.dm_tipo    = en_dm_tipo;
   --
   return (nvl(vn_qtd_dados,0));
   --
exception
   when no_data_found then
      return (0);
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_existe_imp_itemnf:' || sqlerrm);
end fkg_existe_imp_itemnf;
--
-- ============================================================================================================= --
-- Função buscar parâmetro do sistema (PARAM_GERAL_SISTEMA)
function fkg_ret_vl_param_geral_sistema ( en_multorg_id      in mult_org.id%type                        -- MultiOrganização - Obrigatório
                                        , en_empresa_id      in empresa.id%type                         -- Empresa - Opcional
                                        , en_modulo_id       in modulo_sistema.id%type                  -- Modulos do Sistema - Obrigatório
                                        , en_grupo_id        in grupo_sistema.id%type                   -- Grupo de Parâmetros por Modulo - Obrigatório
                                        , ev_param_name      in param_geral_sistema.param_name%type     -- Nome do Parâmetro - Obrigatório
                                        , sv_vlr_param      out param_geral_sistema.vlr_param%type      -- Valor do Parâmetro (saída)
                                        , sv_erro           out varchar2                                -- Mensagem de erro (return false)
                                         ) return boolean is
begin
   -- Checar parâmetros obrigatórios --
   if en_multorg_id is null then
      --
      sv_erro := 'Erro na função pk_csf.fkg_ret_vl_param_geral_sistema'||chr(13)||
                 'O Parâmetro "en_multorg_id" é obrigatório e não foi informado';
      return false;
      --            
   end if;
   --
   if en_modulo_id is null then
      --
      sv_erro := 'Erro na função pk_csf.fkg_ret_vl_param_geral_sistema'||chr(13)||
                 'O Parâmetro "en_modulo_id" é obrigatório e não foi informado';
      return false;
      --            
   end if;
   --
   if en_grupo_id is null then
      --
      sv_erro := 'Erro na função pk_csf.fkg_ret_vl_param_geral_sistema'||chr(13)||
                 'O Parâmetro "en_grupo_id" é obrigatório e não foi informado';
      return false;
      --            
   end if;   
   --
   if ev_param_name is null then
      --
      sv_erro := 'Erro na função pk_csf.fkg_ret_vl_param_geral_sistema'||chr(13)||
                 'O Parâmetro "ev_param_name" é obrigatório e não foi informado';
      return false;
      --            
   end if;     
   --
   --
   -- Passo 1: Busca o parâmetro pela Empresa --
   begin
      select pgs.vlr_param
         into sv_vlr_param
        from PARAM_GERAL_SISTEMA pgs
      where pgs.multorg_id         = en_multorg_id
        and pgs.empresa_id         = en_empresa_id
        and pgs.modulo_id          = en_modulo_id
        and pgs.grupo_id           = en_grupo_id
        and pgs.param_name         = ev_param_name;
   exception
      when no_data_found then
         -- Passo 2: Caso não encontrou pela empresa Busca o parâmetro pelo Mult_org --
         begin
            --
            select pgs.vlr_param
               into sv_vlr_param
              from PARAM_GERAL_SISTEMA pgs
            where pgs.multorg_id         = en_multorg_id
              and pgs.empresa_id         is null
              and pgs.modulo_id          = en_modulo_id
              and pgs.grupo_id           = en_grupo_id
              and pgs.param_name         = ev_param_name;
            --  
         exception
            when no_data_found then
               --
               sv_erro := 'O Parâmetro de Sistema "'||ev_param_name||'" não está cadastrado para os dados abaixo:' ||chr(13)||
                          'Mult-Organização: '||en_multorg_id                                                    ||chr(13)||
                          'Empresa: '         ||en_empresa_id                                                    ||chr(13)||
                          'Modulo: '          ||en_modulo_id                                                     ||chr(13)||
                          'Grupo: '           ||en_grupo_id                                                      ||chr(13)||
                          'Verifique o cadastro de Parâmetros do Sistema';
               return false;
               --            
         end;

   end;
   --
   return true;
   --
exception
   when others then
      sv_erro :=  'Erro na pk_csf.fkg_ret_vl_param_geral_sistema:' || sqlerrm;
      return false;
end fkg_ret_vl_param_geral_sistema;  
--
-- ============================================================================================================= --
-- Função para retornar o id do modulo do sistema
function fkg_ret_id_modulo_sistema ( ev_cod_modulo  in modulo_sistema.cod_modulo%type
                                   ) return number is
   --
   vn_retorno number := 0;
   --   
begin
  --
  select id
    into vn_retorno
  from modulo_sistema
  where trim(cod_modulo) = trim(ev_cod_modulo);
  --
  return vn_retorno;
  --
exception
   when no_data_found then
      return (0);
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_ret_id_modulo_sistema:' || sqlerrm);
end fkg_ret_id_modulo_sistema;                                   
--
-- ============================================================================================================= --
-- Função para retornar o id do grupo do sistema
function fkg_ret_id_grupo_sistema ( en_modulo_id  in modulo_sistema.id%type
                                  , ev_cod_grupo  in grupo_sistema.cod_grupo%type
                                   ) return number is
   --
   vn_retorno number := 0;
   --   
begin
  --
  select id
    into vn_retorno
  from grupo_sistema
  where modulo_id              = en_modulo_id
    and upper(trim(cod_grupo)) = upper(trim(ev_cod_grupo));
  --
  return vn_retorno;
  --
exception
   when no_data_found then
      return (0);
   when others then
      raise_application_error(-20101, 'Erro na pk_csf.fkg_ret_id_grupo_sistema:' || sqlerrm);
end fkg_ret_id_grupo_sistema;                                   
--                                    
-- ============================================================================================================= --
--
-- Função para retornar o valor do parâmetro do sistema, utilizando os parâmetros nome do módulo, nome do grupo e nome do parametro
function fkg_parametro_geral_sistema ( en_multorg_id   mult_org.id%type,
                                       en_empresa_id   empresa.id%type,  
                                       ev_cod_modulo   modulo_sistema.cod_modulo%type,
                                       ev_cod_grupo    grupo_sistema.cod_grupo%type,
                                       ev_param_name   param_geral_sistema.param_name%type) return param_geral_sistema.vlr_param%type
is
   vv_retorno param_geral_sistema.vlr_param%type;
begin
   -- Busca por Mult_org e Empresa_id
   begin
      select pgs.vlr_param
         into vv_retorno 
         from MODULO_SISTEMA       ms,
              GRUPO_SISTEMA        gs,
              PARAM_GERAL_SISTEMA pgs
      where ms.cod_modulo  = ev_cod_modulo -- MODULO_SISTEMA_UK: COD_MODULO
        and gs.modulo_id   = ms.id         -- GRUPO_SISTEMA_UK: MODULO_ID, COD_GRUPO
        and gs.cod_grupo   = ev_cod_grupo  --
        and pgs.multorg_id = en_multorg_id -- PARAM_GERAL_SISTEMA_UK: MULTORG_ID, EMPRESA_ID, MODULO_ID, GRUPO_ID, PARAM_NAME
        and pgs.empresa_id = en_empresa_id
        and pgs.modulo_id  = ms.id
        and pgs.grupo_id   = gs.id
        and pgs.param_name = ev_param_name;
   exception
      when no_data_found then
         -- busca somente por mult_org
         begin
            select pgs.vlr_param
               into vv_retorno 
               from MODULO_SISTEMA       ms,
                    GRUPO_SISTEMA        gs,
                    PARAM_GERAL_SISTEMA pgs
            where ms.cod_modulo  = ev_cod_modulo -- MODULO_SISTEMA_UK: COD_MODULO
              and gs.modulo_id   = ms.id         -- GRUPO_SISTEMA_UK: MODULO_ID, COD_GRUPO
              and gs.cod_grupo   = ev_cod_grupo  --
              and pgs.multorg_id = en_multorg_id -- PARAM_GERAL_SISTEMA_UK: MULTORG_ID, EMPRESA_ID, MODULO_ID, GRUPO_ID, PARAM_NAME
              and pgs.empresa_id is null
              and pgs.modulo_id  = ms.id
              and pgs.grupo_id   = gs.id
              and pgs.param_name = ev_param_name;
         exception
            when others then
               vv_retorno := null;
         end;      
      when others then
         vv_retorno := null;
   end;   
   --
   return vv_retorno;
   --
end fkg_parametro_geral_sistema;                                       
--
-- ============================================================================================================= --
--
-- Procedimento verifica se a empresa valida o imposto PIS - Parâmetro para Notas Fiscais Servicos com Emissão Própria

function fkg_empresa_dmvalpis_emis_nfs ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_pis_emiss_nfs%type is
   --
   vn_dm_valida_pis_emiss_nfs   empresa.dm_valida_pis_emiss_nfs%type;
   --
begin
   --
   select e.dm_valida_pis_emiss_nfs
     into vn_dm_valida_pis_emiss_nfs
     from empresa e
    where e.id = en_empresa_id;
   --
   return vn_dm_valida_pis_emiss_nfs;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_dmvalpis_emis_nfs:' || sqlerrm);
end fkg_empresa_dmvalpis_emis_nfs;

-- Procedimento verifica se a empresa valida o imposto PIS - Parâmetro para Notas Fiscais Serviços com Emissão de Terceiros

function fkg_empresa_dmvalpis_terc_nfs ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_pis_terc_nfs%type is
   --
   vn_dm_valida_pis_terc_nfs   empresa.dm_valida_pis_terc_nfs%type;
   --
begin
   --
   select e.dm_valida_pis_terc_nfs
     into vn_dm_valida_pis_terc_nfs
     from empresa e
    where e.id = en_empresa_id;
   --
   return vn_dm_valida_pis_terc_nfs;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_empresa_dmvalpis_terc_nfs:' || sqlerrm);
end fkg_empresa_dmvalpis_terc_nfs;

-- Procedimento verifica se a empresa valida o imposto Cofins - Parâmetro para Notas Fiscais Serviços com Emissão Própria

function fkg_empr_dmvalcofins_emis_nfs ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_cofins_emiss_nfs%type is
   --
   vn_dm_valida_cofins_emiss_nfs     empresa.dm_valida_cofins_emiss_nfs%type;
   --
begin
   --
   select e.dm_valida_cofins_emiss_nfs
     into vn_dm_valida_cofins_emiss_nfs
     from empresa e
    where e.id = en_empresa_id;
   --
   return vn_dm_valida_cofins_emiss_nfs;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_empr_dmvalcofins_emis_nfs:' || sqlerrm);
end fkg_empr_dmvalcofins_emis_nfs;

-- Procedimento verifica se a empresa valida o imposto Cofins - Parâmetro para Notas Fiscais Serviços com Emissão de Terceiros

function fkg_empr_dmvalcofins_terc_nfs ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_cofins_terc_nfs%type is
   --
   vn_dm_valida_cofins_terc_nfs  empresa.dm_valida_cofins_terc_nfs%type;
   --
begin
   --
   select e.dm_valida_cofins_terc_nfs
     into vn_dm_valida_cofins_terc_nfs
     from empresa e
    where e.id = en_empresa_id;
   --
   return vn_dm_valida_cofins_terc_nfs;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_empr_dmvalcofins_terc_nfs:' || sqlerrm);
end fkg_empr_dmvalcofins_terc_nfs;
--
-----------------------------------------------------------------------------------------------------
--Função retorna se Nota Fiscal foi submetido ao evento R-2010 do REINF ou não. 
--E se a Nota Fiscal está no dm_st_proc igual à 7 (Exclusão) do evento R-2010 do Reinf.
-----------------------------------------------------------------------------------------------------
function fkg_existe_reinf_r2010_nf (en_notafiscal_id Nota_Fiscal.id%type) return boolean
is
---
vn_dummy_nf     integer;
vn_dummy_r2010  integer;
vn_dummy_return integer;
---
begin
  ---
  vn_dummy_nf    :=0;
  vn_dummy_r2010 :=0;
  vn_dummy_return:=0;
  ---
  begin
    ---
    select distinct 1 into vn_dummy_nf
    from EFD_REINF_R2010_NF NF
    where NF.notafiscal_id   = en_notafiscal_id;
    ---
  exception
     when no_data_found then
      vn_dummy_nf:=0;
  end; 
  ---
  if vn_dummy_nf > 0 then
    ----
    begin
      ---
      select distinct 1 into vn_dummy_r2010 
      from efd_reinf_r2010 r, EFD_REINF_R2010_NF nf
      where r.id              = nf.efdreinfr2010_id 
        and r.dm_st_proc       <> 7
        and nf.notafiscal_id  = en_notafiscal_id;
      ---
    exception
       when no_data_found then
        vn_dummy_r2010:=0; 
    end;
    ----
  end if;
  ---
  vn_dummy_return:= vn_dummy_nf*vn_dummy_r2010;
  ---
  if vn_dummy_return = 0 then
    return false;
  else
    return true;
  end if;
  ---
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_reinf_r2010_nf: ' || sqlerrm);
end;
--
-----------------------------------------------------------------------------------------------------
--Função retorna se Nota Fiscal foi submetido ao evento R-2020 do REINF ou não. 
--E se a Nota Fiscal está no dm_st_proc igual à 7 (Exclusão) do evento R-2020 do Reinf.
-----------------------------------------------------------------------------------------------------
function fkg_existe_reinf_r2020_nf (en_notafiscal_id Nota_Fiscal.id%type) return boolean
is
---
vn_dummy_nf     integer;
vn_dummy_r2020  integer;
vn_dummy_return integer;
---
begin
  ---
  vn_dummy_nf    :=0;
  vn_dummy_r2020 :=0;
  vn_dummy_return:=0;
  ---
  begin
    ---
    select distinct 1 into vn_dummy_nf
    from EFD_REINF_R2020_NF nf
    where nf.notafiscal_id  = en_notafiscal_id;
    ---
  exception
     when no_data_found then
      vn_dummy_nf:=0; 
  end; 
  ---
  if vn_dummy_nf > 0 then
    ----
    begin
      ---
      select distinct 1 into vn_dummy_r2020 
      from efd_reinf_r2020 r, EFD_REINF_R2020_NF nf
      where r.id               = nf.efdreinfr2020_id 
        and r.dm_st_proc       <> 7
        and nf.notafiscal_id  = en_notafiscal_id;
      ---
    exception
       when no_data_found then
        vn_dummy_r2020:=0; 
    end;
    ----
  end if;
  ---
  vn_dummy_return:= vn_dummy_nf*vn_dummy_r2020;
  ---
  if vn_dummy_return = 0 then
    return false;
  else
    return true;
  end if;
  ---
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_reinf_r2020_nf: ' || sqlerrm);
end;
--
-- ============================================================================================================================== --
--
-- Procedure retorna dados da empresa
procedure pkb_ret_dados_empresa ( en_empresa_id         in empresa.id%type
                                , sv_nome              out pessoa.nome%type          
                                , sn_dm_situacao       out empresa.dm_situacao%type
                                , sv_dados             out varchar2  
                                , sn_sit_empresa       out number
                                , sn_dm_habil          out cidade_nfse.dm_habil%type
                                , sn_existe_id         out empresa.id%type    
                                , sn_dm_tp_impr        out empresa.dm_tp_impr%type    
                                , sn_dm_tp_amb         out empresa.dm_tp_amb%type  
                                , sv_cnpj_cpf          out varchar2   
                                , sv_cod_part          out pessoa.cod_part%type 
                                , sv_im                out juridica.im%type 
                                , sn_pessoa_id         out pessoa.id%type 
                                , sv_ibge_cidade       out cidade.ibge_cidade%type
                                , sv_ibge_estado       out estado.ibge_estado%type ) is
--
-- Os dados das funções abaixo foram inseridas nessa única função.
-- As funções não foram excluídas apenas criada um só para retornar os mesmos dados de uma só vez
---- pk_csf.fkg_nome_empresa                    -- sv_nome        - tabela empresa e pessoa  - Função retorna o nome da empresa
---- pk_csf.fkg_empresa_id_situacao             -- sn_dm_situacao - tabela empresa           - Função retorna a sitação da empresa: 0-Inativa ou 1-Ativa
---- pk_csf.fkg_cod_nome_empresa_id             -- sv_dados       - tabela empresa e pessoa  - Função retorno o código de nome da empresa conforme seu ID
---- pk_csf.fkg_empresa_id_certificado_ok       -- sn_sit_empresa - tabela empresa           - Função retorna a sitação da empresa: 0-Inativa ou 1-Ativa
---- pk_csf_nfs.fkg_empresa_cidade_nfse_habil   -- sn_dm_habil    - empresa, pessoa, cidade, cidade_nfse - Função para retornar se a cidade da empresa esta habilitada para emissão de NFSe
---- pk_csf.fkg_empresa_id_valido               -- sn_existe_id   - tabela empresa           - Função retorna "true" se o ID da empresa for válido e "false" se não for
---- pk_csf.fkg_tp_impr_empresa                 -- sn_dm_tp_impr  - tabela empresa           - Função retorna o Tipo de impressão (Retrato/Paisagem) parametrizado na empresa
---- pk_csf.fkg_tp_amb_empresa                  -- sn_dm_tp_amb   - tabela empresa           - Função retorna o tipo de ambiente (Produção/Homologação) parametrizado para a empresa
---- pk_csf.fkg_cnpj_ou_cpf_empresa             -- sv_cnpj_cpf    - tabela empresa, fisica e juridica -  Função retorna o CNPJ ou CPF conforme a empresa
---- pk_csf.fkg_codpart_empresaid               -- sv_cod_part    - tabela empresa e pessoa  - Função retorna o cod_participante pelo id_empresa
                                                                                            -- Função retorna o código da empresa através do id empresa em que está relacionado.
---- pk_csf.fkg_inscr_mun_empresa               -- sv_im          - tabela empresa e fisica  - Função retorna a inscrição municipal da empresa
---- pk_csf.fkg_Pessoa_id_valido                -- sn_pessoa_id   - tabela pessoa            - Função retorna o ID da tabela Pessoa
   --
   vn_fase               number;
   vv_cnpj               varchar2(14)             := null;    
   vv_cpf                varchar2(14)             := null;   
   vn_dm_tp_cert         empresa.dm_tp_cert%type;
   vv_caminho_chave_jks  empresa.caminho_chave_jks%type;
   vv_senha_chave_jks    empresa.senha_chave_jks%type;
   vv_caminho_cert_pfx   empresa.caminho_cert_pfx%type;
   vv_senha_cert_pfx     empresa.senha_cert_pfx%type;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_empresa_id,0) > 0 then
      --
      vn_fase := 2;
      --
      select e.id
           , p.cod_part || '-' || p.nome
           , p.nome
           , dm_situacao
           , dm_tp_cert
           , caminho_chave_jks
           , senha_chave_jks
           , caminho_cert_pfx
           , senha_cert_pfx
           , n.dm_habil
           , e.dm_tp_impr
           , e.dm_tp_amb
           , ( lpad(j.NUM_CNPJ, 8, '0') || lpad(j.NUM_FILIAL, 4, '0') || lpad(j.DIG_CNPJ, 2, '0') ) cnpj
           , ( lpad(f.NUM_CPF, 9, '0') || lpad(f.DIG_CPF, 2, '0') ) cpf
           , p.cod_part
           , j.im
           , p.id
           , c.ibge_cidade 
           , s.ibge_estado
        into sn_existe_id
           , sv_dados
           , sv_nome
           , sn_dm_situacao
           , vn_dm_tp_cert
           , vv_caminho_chave_jks
           , vv_senha_chave_jks  
           , vv_caminho_cert_pfx 
           , vv_senha_cert_pfx  
           , sn_dm_habil
           , sn_dm_tp_impr  
           , sn_dm_tp_amb
           , vv_cnpj 
           , vv_cpf
           , sv_cod_part
           , sv_im
           , sn_pessoa_id
           , sv_ibge_cidade
           , sv_ibge_estado 
        from empresa      e
           , pessoa       p
           , cidade       c
           , estado       s
           , cidade_nfse  n
           , juridica     j
           , fisica       f           
       where e.id           = en_empresa_id
         and p.id           = e.pessoa_id
         and c.id           = p.cidade_id
         and s.id           = c.estado_id
         and n.cidade_id(+) = c.id
         and j.pessoa_id(+) = e.pessoa_id
         and f.pessoa_id(+) = e.pessoa_id;         
      --
      vn_fase := 3;
      --
      if vn_dm_tp_cert = 1 then -- A1
         --
         vn_fase := 4;
         --
         if trim(vv_caminho_chave_jks) is not null and 
            trim(vv_senha_chave_jks)   is not null and 
            trim(vv_caminho_cert_pfx)  is not null and 
            trim(vv_senha_cert_pfx)    is not null then
            --
            sn_sit_empresa := 1;
            --
         else
            --
            sn_sit_empresa := 0;
            --
         end if;
         --
      else
         --
         vn_fase := 5;
         --
         sn_sit_empresa := 1;
         --
      end if;
      --
   end if;
   --
   vn_fase := 6;
   --
   sv_cnpj_cpf :=  nvl(vv_cnpj, vv_cpf);
   --
exception
   when no_data_found then
      sn_existe_id   := 0;
      sv_dados       := null;
      sv_nome        := null; 
      sn_dm_situacao := 0;    
      sn_dm_habil    := null;
      sn_dm_tp_impr  := null;
      sn_dm_tp_amb   := null;
      sv_cod_part    := null; 
      sv_im          := null; 
      sn_pessoa_id   := null; 
      sn_sit_empresa := 0;     
      sv_ibge_cidade := null;
      sv_ibge_estado := null;     
      sv_cnpj_cpf    := null;           
   --
   when others then
      -- Tratar o erro para inserir na tabela de log ao chamar essa procedure
      raise_application_error(-20101, 'Erro na pk_csf.pkb_ret_dados_empresa: ' || sqlerrm);
      --
end pkb_ret_dados_empresa;
-- 
-- ============================================================================================================================== --
--
-------------------------------------------------------------------------------------------------------
--| Função retorna o ID do Plano de Conta a partir da tab NAT_REC_PC
-----------------------------------------------------------------------------------------------------
--
function fkg_natrecpc_plc_id ( en_natrecpc_id  in nat_rec_pc.id%TYPE )
         return nat_rec_pc.planoconta_id%TYPE
is
   ---
   vn_planoconta_id  nat_rec_pc.planoconta_id%TYPE;
   ---
begin
   ---
   select planoconta_id 
     into vn_planoconta_id
     from nat_rec_pc 
    where id  = en_natrecpc_id;
   ---
   return vn_planoconta_id;
   ---
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_natrecpc_plc_id:' || sqlerrm);
end fkg_natrecpc_plc_id;
--
-------------------------------------------------------------------------------------------------------
--| Função retorna o ID do Plano de Conta a partir da tab NCM_NAT_REC_PC
-----------------------------------------------------------------------------------------------------
--
function fkg_ncmnatrecpc_plc_id ( en_natrecpc_id  in nat_rec_pc.id%TYPE,
                                  en_ncm_id       in ncm.id%TYPE )
         return ncm_nat_rec_pc.planoconta_id%TYPE
is
   ---
   vn_planoconta_id  ncm_nat_rec_pc.planoconta_id%TYPE;
   ---
begin
   ---
   select planoconta_id
     into vn_planoconta_id
     from ncm_nat_rec_pc
    where natrecpc_id = en_natrecpc_id
      and ncm_id      = en_ncm_id
      and rownum      = 1 ;
   ---
   return vn_planoconta_id;
   ---
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_ncmnatrecpc_plc_id:' || sqlerrm);
end fkg_ncmnatrecpc_plc_id;
--
-------------------------------------------------------------------------------------------------------
--| Função retorna o ID do Tabela NAT_PEC_PC a partir da tab NCM_NAT_REC_PC
-----------------------------------------------------------------------------------------------------
--
function fkg_ncmnatrecpc_npp_id (en_planoconta_id in nat_rec_pc.planoconta_id%TYPE)
                 return PLANO_CONTA_NAT_REC_PC.NATRECPC_ID%type
is
  --
  vn_natrecpc_id PLANO_CONTA_NAT_REC_PC.NATRECPC_ID%type;
  --
begin
  --
  select max(natrecpc_id) 
    into vn_natrecpc_id
    from PLANO_CONTA_NAT_REC_PC 
  where planoconta_id = en_planoconta_id;
  --
  return vn_natrecpc_id;
  --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_ncmnatrecpc_npp_id:' || sqlerrm);
end fkg_ncmnatrecpc_npp_id;
--
-------------------------------------------------------------------------------------------------------
--| Função retorna o ID do Tabela NAT_PEC_PC a partir dos parametros planoconta_id e codst_id 
-----------------------------------------------------------------------------------------------------
--
function fkg_natrecpc_id (en_planoconta_id in nat_rec_pc.planoconta_id%TYPE,
                          en_codst_id      in nat_rec_pc.codst_id%TYPE) 
                          return nat_rec_pc.id%type
is
  --
  vn_natrecpc_id PLANO_CONTA_NAT_REC_PC.NATRECPC_ID%type;
  --
begin
  --
  select max(n.id) into vn_natrecpc_id
  from nat_rec_pc n, plano_conta_nat_rec_pc np
  where n.id            = np.natrecpc_id
    and n.planoconta_id = en_planoconta_id
    and n.codst_id      = en_codst_id;
  --
  return vn_natrecpc_id;
  --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_natrecpc_id:' || sqlerrm); 
end fkg_natrecpc_id;
--
-------------------------------------------------------------------------------------------------------
--| Função retorna o primeiro ID do plano de conta do Tabela plano_conta_nat_rec_pc 
-----------------------------------------------------------------------------------------------------
--
function fkg_plcnatpecpc_plc_id ( en_natrecpc_id  in nat_rec_pc.id%TYPE)
                             return plano_conta_nat_rec_pc.planoconta_id%type
is 
--
vn_natpecpc_plc_id  plano_conta_nat_rec_pc.planoconta_id%type;
--
begin
  --
  select min(np.planoconta_id)
  into vn_natpecpc_plc_id
  from plano_conta_nat_rec_pc np 
  where np.natrecpc_id = en_natrecpc_id
  order by np.id;
  --
  return vn_natpecpc_plc_id;
  --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_plcnatpecpc_plc_id:' || sqlerrm);  
end fkg_plcnatpecpc_plc_id;
--
-------------------------------------------------------------------------------------------------------
--| Função que retorna o ID da Tabela COD_ST_CIDADE
-----------------------------------------------------------------------------------------------------
--
function fkg_codstcidade_Id (ev_cod_st    in  cod_st_cidade.cod_st%TYPE,
                             en_cidade_id in  cod_st_cidade.cidade_id%TYPE)
                             return cod_st_cidade.id%type
is
--
vn_codstcid_id  COD_ST_CIDADE.id%type;
--
begin
  --
  select csc.id
    into vn_codstcid_id
    from COD_ST_CIDADE csc
  where csc.cod_st    = ev_cod_st
    and csc.cidade_id = en_cidade_id;
  --
  return vn_codstcid_id;
  --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_codstcidade_Id:' || sqlerrm);
end fkg_codstcidade_Id;
--
-------------------------------------------------------------------------------------------------------
--| Procedure para criação de sequence e inclusão na seq_tab
-------------------------------------------------------------------------------------------------------
procedure pkb_cria_sequence (ev_sequence_name varchar2,
                             ev_table_name    varchar2)
is
begin
   -- Cria a sequence
   BEGIN
      EXECUTE IMMEDIATE '
         CREATE SEQUENCE CSF_OWN.'||ev_sequence_name||'
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
   -- Inclui na seq_tab
   BEGIN
      INSERT INTO CSF_OWN.SEQ_TAB ( id
                                  , sequence_name
                                  , table_name
                                  )
                           values ( CSF_OWN.seqtab_seq.nextval
                                  , ev_sequence_name
                                  , ev_table_name
                                  );
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                                
   --
   commit;
   --
exception
  when others then
     rollback;
     raise;   
end pkb_cria_sequence;
--
-------------------------------------------------------------------------------------------------------
--| Procedure para criação de domínio
-------------------------------------------------------------------------------------------------------
procedure pkb_cria_dominio (ev_dominio    varchar2,
                            ev_valor      varchar2,
                            ev_descricao  varchar2)
is
begin
   --
   begin
      insert into dominio (dominio,
                           vl,
                           descr,
                           id)
                    values(upper(ev_dominio),
                           upper(ev_valor),
                           ev_descricao,
                           dominio_seq.nextval);
   exception
      when dup_val_on_index then
         --
         update dominio d set
             descr = ev_descricao
         where d.dominio = ev_dominio
           and d.vl      = ev_valor;
         --
   end;   
   --
   commit;
   --
exception
   when others then
      null;
end pkb_cria_dominio;    
-- 
end pk_csf;
/
