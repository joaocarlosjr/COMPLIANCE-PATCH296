-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #73922 - Estrutura de tabelas - Dominios
-------------------------------------------------------------------------------------------------------------------------------
begin
   --
   begin
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'COD_DIN_LUCR_EXPL.DM_TIPO'
                                  , 'R'
                                  , 'Rótulo'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Rótulo'           
          where dominio = 'COD_DIN_LUCR_EXPL.DM_TIPO'
            and vl = 'R';
   end;		
   --
   begin
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'COD_DIN_LUCR_EXPL.DM_TIPO'
                                  , 'E'
                                  , 'Editavel'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Editavel'           
          where dominio = 'COD_DIN_LUCR_EXPL.DM_TIPO'
            and vl = 'E';
   end;		
   --
   begin
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'COD_DIN_LUCR_EXPL.DM_TIPO'
                                  , 'F'
                                  , 'Fórmula'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Fórmula'           
          where dominio = 'COD_DIN_LUCR_EXPL.DM_TIPO'
            and vl = 'F';
   end;		
   --   
   begin
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'COD_DIN_LUCR_EXPL.DM_SITUACAO'
                                  , 0
                                  , 'Inativo'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Inativo'           
          where dominio = 'COD_DIN_LUCR_EXPL.DM_SITUACAO'
            and vl = 0;
   end;		
   --   
   begin
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'COD_DIN_LUCR_EXPL.DM_SITUACAO'
                                  , 1
                                  , 'Ativo'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Ativo'           
          where dominio = 'COD_DIN_LUCR_EXPL.DM_SITUACAO'
            and vl = 1;
   end;		
   -- 
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'COD_DIN_LUCR_EXPL.DM_ESTILO'
                                  , 0
                                  , 'Sem formatação'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Sem formatação'           
          where dominio = 'COD_DIN_LUCR_EXPL.DM_ESTILO'
            and vl = 0;
   end;		
   -- 
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'COD_DIN_LUCR_EXPL.DM_ESTILO'
                                  , 1
                                  , 'Negrito'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Negrito'           
          where dominio = 'COD_DIN_LUCR_EXPL.DM_ESTILO'
            and vl = 1;
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'COD_DIN_LUCR_EXPL.DM_ESTILO'
                                  , 2
                                  , 'Fundo Cinza'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Fundo Cinza'           
          where dominio = 'COD_DIN_LUCR_EXPL.DM_ESTILO'
            and vl = 2;
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'COD_DIN_LUCR_EXPL.DM_ESTILO'
                                  , 3
                                  , 'Negrito e fundo cinza'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Negrito e fundo cinza'           
          where dominio = 'COD_DIN_LUCR_EXPL.DM_ESTILO'
            and vl = 3;
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'COD_DIN_LUCR_EXPL.DM_INVERTE_SINAL'
                                  , 'S'
                                  , 'Sim'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Sim'           
          where dominio = 'COD_DIN_LUCR_EXPL.DM_INVERTE_SINAL'
            and vl = 'S';
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'COD_DIN_LUCR_EXPL.DM_INVERTE_SINAL'
                                  , 'N'
                                  , 'Não'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Não'           
          where dominio = 'COD_DIN_LUCR_EXPL.DM_INVERTE_SINAL'
            and vl = 'N';
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'PARAM_DP_CODDIN_CTA_LUCR_EXPL.DM_TB_ORIGEM'
                                  , 'S'
                                  , 'Saldo'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Saldo'           
          where dominio = 'PARAM_DP_CODDIN_CTA_LUCR_EXPL.DM_TB_ORIGEM'
            and vl = 'S';
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'PARAM_DP_CODDIN_CTA_LUCR_EXPL.DM_TB_ORIGEM'
                                  , 'L'
                                  , 'Lançamento'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Lançamento'           
          where dominio = 'PARAM_DP_CODDIN_CTA_LUCR_EXPL.DM_TB_ORIGEM'
            and vl = 'L';
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'PARAM_DP_CODDIN_CTA_LUCR_EXPL.DM_TIPO_VLR_CALC'
                                  , 'N'
                                  , 'Normal (conforme resultado)'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Normal (conforme resultado)'           
          where dominio = 'PARAM_DP_CODDIN_CTA_LUCR_EXPL.DM_TIPO_VLR_CALC'
            and vl = 'N';
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'PARAM_DP_CODDIN_CTA_LUCR_EXPL.DM_TIPO_VLR_CALC'
                                  , 'D'
                                  , 'Somente se devedor'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Somente se devedor'           
          where dominio = 'PARAM_DP_CODDIN_CTA_LUCR_EXPL.DM_TIPO_VLR_CALC'
            and vl = 'D';
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'PARAM_DP_CODDIN_CTA_LUCR_EXPL.DM_TIPO_VLR_CALC'
                                  , 'C'
                                  , 'Somente se credor'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Somente se credor'           
          where dominio = 'PARAM_DP_CODDIN_CTA_LUCR_EXPL.DM_TIPO_VLR_CALC'
            and vl = 'C';
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CRIT_PESQ_SLD_LUCR_EXPL.DM_COL_ORIGEM'
                                  , 'I'
                                  , 'Saldo Inicial'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Saldo Inciial'           
          where dominio = 'CRIT_PESQ_SLD_LUCR_EXPL.DM_COL_ORIGEM'
            and vl = 'I';
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CRIT_PESQ_SLD_LUCR_EXPL.DM_COL_ORIGEM'
                                  , 'F'
                                  , 'Saldo Final'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Saldo Final'           
          where dominio = 'CRIT_PESQ_SLD_LUCR_EXPL.DM_COL_ORIGEM'
            and vl = 'F';
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CRIT_PESQ_SLD_LUCR_EXPL.DM_COL_ORIGEM'
                                  , 'D'
                                  , 'Saldo a Débito'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Saldo a Débito'           
          where dominio = 'CRIT_PESQ_SLD_LUCR_EXPL.DM_COL_ORIGEM'
            and vl = 'D';
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CRIT_PESQ_SLD_LUCR_EXPL.DM_COL_ORIGEM'
                                  , 'C'
                                  , 'Saldo a Crédito'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Saldo a Crédito'           
          where dominio = 'CRIT_PESQ_SLD_LUCR_EXPL.DM_COL_ORIGEM'
            and vl = 'C';
   end;		
   -- 
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CRIT_PESQ_SLD_LUCR_EXPL.DM_COL_ORIGEM'
                                  , 'M'
                                  , 'Movimento (diferença entre Deb - Cred)'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Movimento (diferença entre Deb - Cred)'           
          where dominio = 'CRIT_PESQ_SLD_LUCR_EXPL.DM_COL_ORIGEM'
            and vl = 'M';
   end;		
   -- 
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CRIT_PESQ_SLD_LUCR_EXPL.DM_TIPO_VLR_CALC'
                                  , 'N'
                                  , 'Normal (conforme resultado)'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Normal (conforme resultado)'           
          where dominio = 'CRIT_PESQ_SLD_LUCR_EXPL.DM_TIPO_VLR_CALC'
            and vl = 'N';
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CRIT_PESQ_SLD_LUCR_EXPL.DM_TIPO_VLR_CALC'
                                  , 'D'
                                  , 'Somente se devedor'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Somente se devedor'           
          where dominio = 'CRIT_PESQ_SLD_LUCR_EXPL.DM_TIPO_VLR_CALC'
            and vl = 'D';
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CRIT_PESQ_SLD_LUCR_EXPL.DM_TIPO_VLR_CALC'
                                  , 'C'
                                  , 'Somente se credor'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Somente se credor'           
          where dominio = 'CRIT_PESQ_SLD_LUCR_EXPL.DM_TIPO_VLR_CALC'
            and vl = 'C';
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CRIT_PESQ_LCTO_LUCR_EXPL.DM_IND_LCTO'
                                  , 'N'
                                  , 'Normal'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Normal'           
          where dominio = 'CRIT_PESQ_LCTO_LUCR_EXPL.DM_IND_LCTO'
            and vl = 'N';
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CRIT_PESQ_LCTO_LUCR_EXPL.DM_IND_LCTO'
                                  , 'E'
                                  , 'Encerramento'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Encerramento'           
          where dominio = 'CRIT_PESQ_LCTO_LUCR_EXPL.DM_IND_LCTO'
            and vl = 'E';
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CRIT_PESQ_LCTO_LUCR_EXPL.DM_TIPO_VLR_CALC'
                                  , 'N'
                                  , 'Normal (conforme resultado)'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Normal (conforme resultado)'           
          where dominio = 'CRIT_PESQ_LCTO_LUCR_EXPL.DM_TIPO_VLR_CALC'
            and vl = 'N';
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CRIT_PESQ_LCTO_LUCR_EXPL.DM_TIPO_VLR_CALC'
                                  , 'D'
                                  , 'Somente se devedor'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Somente se devedor'           
          where dominio = 'CRIT_PESQ_LCTO_LUCR_EXPL.DM_TIPO_VLR_CALC'
            and vl = 'D';
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CRIT_PESQ_LCTO_LUCR_EXPL.DM_TIPO_VLR_CALC'
                                  , 'C'
                                  , 'Somente se credor'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Somente se credor'           
          where dominio = 'CRIT_PESQ_LCTO_LUCR_EXPL.DM_TIPO_VLR_CALC'
            and vl = 'C';
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'PER_LUCR_EXPL.DM_SITUACAO'
                                  , 0
                                  , 'Aberto'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Aberto'           
          where dominio = 'PER_LUCR_EXPL.DM_SITUACAO'
            and vl = 0;
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'PER_LUCR_EXPL.DM_SITUACAO'
                                  , 1
                                  , 'Calculo em andamento'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Calculo em andamento'           
          where dominio = 'PER_LUCR_EXPL.DM_SITUACAO'
            and vl = 1;
   end;		
   --			
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'PER_LUCR_EXPL.DM_SITUACAO'
                                  , 2
                                  , 'Calculado'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Calculadoo'           
          where dominio = 'PER_LUCR_EXPL.DM_SITUACAO'
            and vl = 2;
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'PER_LUCR_EXPL.DM_SITUACAO'
                                  , 3
                                  , 'Finalizado'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Finalizado'           
          where dominio = 'PER_LUCR_EXPL.DM_SITUACAO'
            and vl = 3;
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'PER_LUCR_EXPL.DM_SITUACAO'
                                  , 4
                                  , 'Erro de calculo'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Erro de calculo'           
          where dominio = 'PER_LUCR_EXPL.DM_SITUACAO'
            and vl = 4;
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'MEM_CALC_LUCRO_EXPL.DM_TB_ORIGEM'
                                  , 'S'
                                  , 'Saldo'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Saldo'           
          where dominio = 'MEM_CALC_LUCRO_EXPL.DM_TB_ORIGEM'
            and vl = 'S';
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'MEM_CALC_LUCRO_EXPL.DM_TB_ORIGEM'
                                  , 'L'
                                  , 'Lançamento'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Lançamento'           
          where dominio = 'MEM_CALC_LUCRO_EXPL.DM_TB_ORIGEM'
            and vl = 'L';
   end;		
   -- 
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'MEM_CALC_LUCRO_EXPL.DM_TIPO_VLR_CALC'
                                  , 'N'
                                  , 'Normal (conforme resultado)'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Normal (conforme resultado)'           
          where dominio = 'MEM_CALC_LUCRO_EXPL.DM_TIPO_VLR_CALC'
            and vl = 'N';
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'MEM_CALC_LUCRO_EXPL.DM_TIPO_VLR_CALC'
                                  , 'D'
                                  , 'Somente se devedor'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Somente se devedor'           
          where dominio = 'MEM_CALC_LUCRO_EXPL.DM_TIPO_VLR_CALC'
            and vl = 'D';
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'MEM_CALC_LUCRO_EXPL.DM_TIPO_VLR_CALC'
                                  , 'C'
                                  , 'Somente se credor'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Somente se credor'           
          where dominio = 'MEM_CALC_LUCRO_EXPL.DM_TIPO_VLR_CALC'
            and vl = 'C';
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'PARAM_REC_LUCR_EXPL.DM_REC_INCENT'
                                  , 0
                                  , 'Não'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Não'           
          where dominio = 'PARAM_REC_LUCR_EXPL.DM_REC_INCENT'
            and vl = 0;
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'PARAM_REC_LUCR_EXPL.DM_REC_INCENT'
                                  , 1
                                  , 'Sim'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Sim'           
          where dominio = 'PARAM_REC_LUCR_EXPL.DM_REC_INCENT'
            and vl = 1;
   end;	
   --
   begin
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'PARAM_REC_LUCR_EXPL.DM_SITUACAO'
                                  , 0
                                  , 'Inativo'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Inativo'           
          where dominio = 'PARAM_REC_LUCR_EXPL.DM_SITUACAO'
            and vl = 0;
   end;		
   --   
   begin
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'PARAM_REC_LUCR_EXPL.DM_SITUACAO'
                                  , 1
                                  , 'Ativo'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Ativo'           
          where dominio = 'PARAM_REC_LUCR_EXPL.DM_SITUACAO'
            and vl = 1;
   end;		
   --
   begin
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CALC_LUCRO_EXPL.DM_TIPO'
                                  , 0
                                  , 'Não Definido'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Não Definido'           
          where dominio = 'CALC_LUCRO_EXPL.DM_TIPO'
            and vl = 0;
   end;		
   -- 
   begin
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CALC_LUCRO_EXPL.DM_TIPO'
                                  , 1
                                  , 'Calculado'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Calculado'           
          where dominio = 'CALC_LUCRO_EXPL.DM_TIPO'
            and vl = 1;
   end;		
   -- 
   begin
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CALC_LUCRO_EXPL.DM_TIPO'
                                  , 2
                                  , 'Digitado'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Digitado'           
          where dominio = 'CALC_LUCRO_EXPL.DM_TIPO'
            and vl = 2;
   end;		
   -- 
   begin   
       insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CALC_LUCRO_EXPL.DM_TIPO'
                                  , 3
                                  , 'Calculado/Digitado'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Calculado/Digitado'           
          where dominio = 'CALC_LUCRO_EXPL.DM_TIPO'
            and vl = 3;
   end;		
   --   

   begin   
       insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CALC_BENEF_LUCRO_EXPL.DM_FOMA_CALC_IR_ADIC'
                                  , 'R'
                                  , 'Rateio'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Rateio'           
          where dominio = 'CALC_BENEF_LUCRO_EXPL.DM_FOMA_CALC_IR_ADIC'
            and vl = 'R';
   end;		
   -- 
   begin   
       insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CALC_BENEF_LUCRO_EXPL.DM_FOMA_CALC_IR_ADIC'
                                  , 'D'
                                  , 'Direto'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Direto'           
          where dominio = 'CALC_BENEF_LUCRO_EXPL.DM_FOMA_CALC_IR_ADIC'
            and vl = 'D';
   end;		
   --   
   commit;
   --     
end;
/

--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #73922 - Estrutura de tabelas - Dominios
--------------------------------------------------------------------------------------------------------------------------------------
