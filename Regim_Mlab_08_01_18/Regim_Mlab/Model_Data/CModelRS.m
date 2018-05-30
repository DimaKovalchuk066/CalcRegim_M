classdef CModelRS < handle
    % CModelRS  Handle-����� ������ �� ���������� ������� � ������� ��
    % ����� ����������������� ������������ ����, ������������ �� �������� �
    % �������������� �������. ������������ �������� ��������������
    % ����������
    %
    % Written by A.Zolotoy Mod Kovalchuk
    % Research group of energetic faculty,
    % department of BNTU.
    % April 2017 mod December 2017.
    
    properties(Access = private)
        % ���� ������� ������ ������ � ���� �������� (COMM) ��� ��������
        % �������� (NODE, VETV). ��� ��������� � ����� NODE, VETV
        %, ��������� ����������, �������� ��������� � ��������
        % ��������.
        COMM  % ��������� ����� ����������
        NODE  % ��������� ���������� �� �����
        BRAN  % ��������� ���������� �� ������
    end
    
    methods
        function hM = CModelRS(DataNODE, DataBRAN, DataCOMM)
            % CModelRS  �����������.
            %
            % hM = CModelRS(DataNODE, DataBRAN, DataCOMM)
            
            % hM - handle ���������� ������� ������;
            % DataNODE - ������ ������ �������� ������ CData;
            % DataBRAN - ���� ������� ������ CData, �������� ������ ��
            % ������
            % DataCOMM - ��������� ����������, ����������� ��� ������������
            % ������; 

            %
            
            % ����
            nN=size(DataNODE.Nn1,1);
            nZ = zeros(nN, 1);
            hM.NODE = struct(...
                ... % ������
                'Nn',    [1:nN],...                     % ������ �����
                'Nn1',   DataNODE.Nn1,...              % ���������������� ������ �����
                'Type',  DataNODE.Type,...             % ���� ����� (BU, PU ��� PQ)
                'Pn',    DataNODE.Pn,...               % �������� �������� ��������, ���
                'PnX',   DataNODE.Pn,...               % �������� �������� �������� � ������ ������ ��������� ����, ���                
                'Qn',    DataNODE.Qn,...               % ���������� �������� ��������, ����
                'QnX',   DataNODE.Qn,...               % ��������� �������� �������� � ������ ������ ��������� ����, ���                       
                'Pg',    DataNODE.Pg,...               % �������� �������� ���������, ���
                'Qg',    DataNODE.Qg,...               % ���������� �������� ���������, ����
                'Qmin',  DataNODE.Qmin,...             % ����������� ������ ���������� ��������, ����
                'Qmax',  DataNODE.Qmax,...             % ������������ ������ ���������� ��������, ����
                'Uu',    DataNODE.Uu,...               % ������� ���������� ���������� (��), ��
                'dUu',   DataNODE.dUu.*pi./180,...     % ������� ���������� ���������� (��), ��
                ... % ������� �������
                'Pnb',      DataNODE.Pn,...            % �������� �������� �������� ����� ������������
                'Qnb',      DataNODE.Qn,...            % ���������� �������� �������� ����� ������������
                'QgR',      DataNODE.Qg,...            % ���������� �������� ���������, ����
                'CurrType', DataNODE.Type,...          % ������� ��� ���� � ����������
                'U',        DataNODE.Uu,...            % ������ ���������� � ����, ��
                'Unn',      DataNODE.Uu,...            % ������ ���������� �� ������ ������� ��������������, ��
                'dU',       DataNODE.dUu.*pi./180 ...  % ���� ���������� � ���� (��), ����
            );
            % �������� handle ������� ��� ���������� ��������� ���������� �� ����� 
            hM.NODE.U1=@(J)hM.NODE.U(J).*cos(hM.NODE.dU(J));
            hM.NODE.U2=@(J)hM.NODE.U(J).*sin(hM.NODE.dU(J));
            % �����
            nB=size(DataBRAN.Nb1,1);
            vZ = zeros(nB, 1);
            hM.BRAN = struct(...
                ... % ������
                'Nb',     [1:nB],...              % ������ �����
                'Nb1',    DataBRAN.Nb1,...       % ���������������� ������ ������
                'NbSt',   DataBRAN.NbSt,...      % ����� ���� ������
                'NbStM',  vZ,...      % ����� ���� ������
                'NbF',    DataBRAN.NbF,...       % ����� ���� �����
                'NbFM',   vZ,...       % ����� ���� �����
                'CmTpS',  DataBRAN.CmTpS,...     % ��� �� � ������
                'CmStS',  DataBRAN.CmStS,...     % ��������� �� � ������
                'CmTpF',  DataBRAN.CmTpF,...     % ��� �� � �����
                'CmStF',  DataBRAN.CmStF,...     % ��������� �� � �����
                'Type',   DataBRAN.Type,...      % ��� �����
                'R',      DataBRAN.R,...         % �������� �������������, ��
                'X',      DataBRAN.X,...         % ���������� �������������, ��
                'Pxx',    DataBRAN.Pxx,...       % �������� �������� ��������� ����, ���
                'Qxx',    DataBRAN.Qxx,...       % ���������� �������� ��������� ����, ���
                'kt',     DataBRAN.kt,...        % ����������� �������������
                ... % ���������� �� ������
                'Pn', vZ,...        % ����� P � ������, ���
                'Pk', vZ,...        % ����� P � �����, ���
                'Qn', vZ,...        % ����� Q � ������, ����
                'Qk', vZ...        % ����� Q � �����, ����
                );
            for J=1:nB
                hM.BRAN.NbStM(J)=hM.NODE.Nn(hM.NODE.Nn1(1:nN)==hM.BRAN.NbSt(J));
                hM.BRAN.NbFM(J)=hM.NODE.Nn(hM.NODE.Nn1(1:nN)==hM.BRAN.NbF(J));
            end
            
            % �������� handle ������� ��� ���������� ��������� ����������
            % ������������� ���� �� ������
            % ���� ������
            % �������������� �����
            
            hM.BRAN.I1=@(J)(hM.BRAN.Pn(J).*hM.NODE.U1(hM.BRAN.NbStM(J))+...
                hM.BRAN.Qn(J).*hM.NODE.U2(hM.BRAN.NbStM(J)))./(sqrt(3)*hM.NODE.U(hM.BRAN.NbStM(J)).^2);
            % ������ �����
            hM.BRAN.I2=@(J)(hM.BRAN.Pn(J)*hM.NODE.U2(hM.BRAN.NbStM(J))-...
                hM.BRAN.Qn(J).*hM.NODE.U1(hM.BRAN.NbStM(J)))./(sqrt(3)*hM.NODE.U(hM.BRAN.NbStM(J)).^2);
            % ����������� ��� ������ � �����
            hM.BRAN.Is=@(J)abs(hM.BRAN.I1(J)+1i*hM.BRAN.I2(J));
            % �������� ����� � ������ ������
            hM.BRAN.Sn=@(J)abs(hM.BRAN.Pn(J)+1i*hM.BRAN.Qn(J));
            hM.BRAN.Sk=@(J)abs(hM.BRAN.Pk(J)+1i*hM.BRAN.Qk(J));
            hM.BRAN.dP=@(J)abs(hM.BRAN.Pn(J)-hM.BRAN.Pk(J));
            hM.BRAN.dQ=@(J)abs(hM.BRAN.Qn(J)-hM.BRAN.Qk(J));
            % ������� ���������� � ������
            hM.BRAN.dU1=@(J)(hM.NODE.U1(hM.BRAN.NbStM(J))-hM.NODE.U1(hM.BRAN.NbFM(J)));
            hM.BRAN.dU2=@(J)(hM.NODE.U2(hM.BRAN.NbStM(J))-hM.NODE.U2(hM.BRAN.NbFM(J)));
            hM.BRAN.dU=@(J)abs(hM.BRAN.dU1(J)+1i*hM.BRAN.dU2(J));
            % ����� ���������� � �����
            % ��������� ������ � ������
            LINE = struct(...
                'dpn', 0,...  % ������ P��� � ������, ���
                'dpx', 0,...  % ������ P�� � ������, ���
                'dp', 0,...   % ������ P � ������, ���
                'dqn', 0,...  % ������ Q��� � ������, ����
                'dqx', 0,...  % ������ Q�� � ������, ����
                'dq', 0 ...   % ������ Q � ������, ����
                );
         
            % ��������� ������ � ���������������
            TRANS = struct(...
                'dpn', 0,...  % ������ P��� � ��-���, ���
                'dpx', 0,...  % ������ P�� � ��-���, ���
                'dp', 0,...   % ������ D � ��-���, ���
                'dqn', 0,...  % ������ Q��� � ��-���, ����
                'dqx', 0,...  % ������ Q�� � ��-���, ����
                'dq', 0 ...   % ������ Q � ��-���, ����
                );
            
            hM.COMM = struct(...
                'TolFun', DataCOMM.TolFun,...   % �������� ����������
                'Un', DataCOMM.Un,...           % ����������� ����������, ��
                ... % C�������� �������� � ���������
                'ppotr', sum(hM.NODE.Pnb),...     % �������� P �����, ���
                'pgen', sum(hM.NODE.Pg),...      % ��������� P �����, ���
                'qpotr', sum(hM.NODE.Qnb),...     % �������� Q �����, ����
                'qgen', 0,...      % ��������� Q �����, ����
                ... % ��������� ������ � ������ � ��-���
                'LINE', LINE,...    % ������ ��� � � ������
                'TRANS', TRANS,...  % ������ ��� � � ��-���
                ... % ��������� ������ � �����
                'dpn', 0,...       % ������ P��� � �����, ���
                'dpx', 0,...       % ������ P�� � �����, ���
                'dp', 0,...        % ������ P � �����, ���
                'dqn', 0,...       % ������ Q��� � �����, ����
                'dqx', 0,...       % ������ Q�� � �����, ����
                'dq', 0 ...        % ������ Q � �����, ����
                );
                hM = CalcXX(hM);
        end
        
        function hM = subsasgn(hM, S, B)
            % ����� ���������� ������������. ��������� ������������ �����
            % ������� ����� ��������. ��������� ���������� ����� �������
            % �������������� �� �������� ��������.
            %
            % hM = subsasgn(hM, S, B)
            %
            % hM - handel �������; S - ��������� ���������� �������; B -
            % ������������� ��������.
            
            str = hM.subs2str(S);
            eval(['hM', str, '= B;']);
        end
        
        function B = subsref(hM, S)
            % ����� ��������� ������. ��������� ��������� � ����� �������
            % �� �������� �������� ���������� ����������.
            %
            % B = subsref(hM, S)
            %
            % hM - handel �������; S - ��������� ���������� �������; B -
            % ��������� ��������� � ������� �� ��������� ������.
            
            if length(S) == 2 &&...
                    strcmp(S(2).type, '.') &&...
                    strcmp(S(2).subs, 'n')
                % ����� ���������
                switch S(1).subs
                    case 'NODE'
                        B = length(hM.NODE.Nn1);
                    case 'BRAN'
                        B = length(hM.BRAN.Nb1);
                    otherwise
                        B = 0;
                end
            else
                % ��������� ���������
                str = hM.subs2str(S);
                B = eval(['hM', str]);
            end
        end
        
        function hM = CalcSum(hM)
            % ����� ���������� ������ ������������ ���������� ������
            % ��������. ���������� ������� ������������ � ������ hM.
            % ��������� � ����������� �������� �� ����� �������� ��� ������
            % ������ CModelRS.
            %
            % hM = CalcSum(hM)
            %
            % hM - handle ���������� ������� ������;
            
            % ������ �� ������
            LINE.dpn=sum(hM.BRAN.dP(hM.BRAN.Type==bTip.L));
            LINE.dpx=sum(hM.BRAN.Pxx(hM.BRAN.Type==bTip.L));
            LINE.dp=LINE.dpn+LINE.dpx;   
            LINE.dqn=sum(hM.BRAN.dQ(hM.BRAN.Type==bTip.L));
            LINE.dqx=sum(hM.BRAN.Qxx(hM.BRAN.Type==bTip.L));
            LINE.dq=LINE.dqn+LINE.dqx;
            % ������ �� ���������������
            TRANS.dpn=sum(hM.BRAN.dP(hM.BRAN.Type==bTip.T));
            TRANS.dpx=sum(hM.BRAN.Pxx(hM.BRAN.Type==bTip.T));
            TRANS.dp=TRANS.dpn+TRANS.dpx;   
            TRANS.dqn=sum(hM.BRAN.dQ(hM.BRAN.Type==bTip.T));
            TRANS.dqx=sum(hM.BRAN.Qxx(hM.BRAN.Type==bTip.T));
            TRANS.dq=TRANS.dqn+TRANS.dqx;
            % ����� ������
            hM.COMM.ppotr=sum(hM.NODE.Pn);
            hM.COMM.pgen=sum(hM.NODE.Pg);
            hM.COMM.qpotr=sum(hM.NODE.Qn);
            hM.COMM.qgen=sum(hM.NODE.QgR);
            hM.COMM.LINE = LINE;
            hM.COMM.TRANS = TRANS;
            clear LINE TRANS;
            hM.COMM.dpn= hM.COMM.LINE.dpn+hM.COMM.TRANS.dpn;
            hM.COMM.dpx= hM.COMM.LINE.dpx+hM.COMM.TRANS.dpx;
            hM.COMM.dp= hM.COMM.LINE.dp+hM.COMM.TRANS.dp;
            hM.COMM.dqn= hM.COMM.LINE.dqn+hM.COMM.TRANS.dqn;
            hM.COMM.dqx= hM.COMM.LINE.dqx+hM.COMM.TRANS.dqx; 
            hM.COMM.dq= hM.COMM.LINE.dq+hM.COMM.TRANS.dq;
        end
        
        function hM = CalcXX(hM)
            % ����� ���������� ���� ������ ��������� ���� ����� �
            % ��������������� � ��������� �����.
            %
            % hM = CalcXX(hM)
            %
            % hM - handle ���������� ������� ������;
            
            % ���������� ������ ��������� ���� �� ������
            % � ���� ������
            Lin=hM.BRAN.Type==bTip.L;
            StL=hM.BRAN.NbStM(Lin);
            hM.NODE.PnX(StL)=hM.NODE.Pn(StL)+hM.BRAN.Pxx(Lin)/2;
            hM.NODE.QnX(StL)=hM.NODE.Qn(StL)+hM.BRAN.Qxx(Lin)/2;
            clear StL;
            % � ���� �����
            FL=hM.BRAN.NbFM(Lin);
            hM.NODE.PnX(FL)=hM.NODE.Pn(FL)+hM.BRAN.Pxx(Lin)/2;
            hM.NODE.QnX(FL)=hM.NODE.Qn(FL)+hM.BRAN.Qxx(Lin)/2;
            clear FL;
            clear Lin;
            
            % ���������� ������ ��������� ���� �� ���������������
            % � ���� ������
            Tr=hM.BRAN.Type==bTip.T;
            StT=hM.BRAN.NbStM(Tr);
            hM.NODE.PnX(StT)=hM.NODE.Pn(StT)+hM.BRAN.Pxx(Tr);
            hM.NODE.QnX(StT)=hM.NODE.Qn(StT)+hM.BRAN.Qxx(Tr);
            clear StT;
            clear Tr;
        end
        
        function hM = CalcUT(hM)
            % ����� ���������� �������� ���������� ����� �� ������ �������
            % ���������������.
            %
            % hM = CalcUT(hM)
            %
            % hM - handle ���������� ������� ������;
            
            hM.NODE.Unn=hM.NODE.U;
            % �������� ������� ������ ���������������� ������
            Tr=hM.BRAN.Type==bTip.T;
            FT=hM.BRAN.NbFM(Tr); 
            % ������� ������������ � ������ ������� ���������� ��
            % ����������� �������������
            hM.NODE.Unn(FT)=hM.NODE.U(FT)./hM.BRAN.kt(Tr);
            clear FT;
            clear Tr;
        end
end
    methods(Static, Access = private)
        function Str = subs2str(S)
            % ����� ����������� ��������� ���������� ������� � ������.
            % ���������� ������� ���������� �������. ������������ � �������
            % subsref � subsasgn.
            %
            % Str = subs2str(S)
            %
            % S - ��������� ��������� ������; Str - ������ ����������
            % �������.
            %
            % ������ � ����� ������� �������� � ���� �������� ��������.
            % ������ ��� ��������� � ����� ������� ����������� ���������
            % ��������� � �������� ��������. ����� subs2str ��� ��� �
            % ��������� ��������� ������� ���������� ���������.
            %
            % ������������� ��������� ���������� ����� �������
            % �������������� �� ��������� �������� ���������:
            %
            % � ����� ���������� -
            % a1 = hM.COMM.TolFun;
            % a2 = hM.COMM.LINE.dp;
            %
            % � ����� -
            % a3_15 = hM.NODE(3:15).nb1;
            % a_all = hM.NODE(:).nb1;
            %
            % � ������ -
            % a3_15 = hM.VETV(3:15).nvn;
            % a_all = hM.VETV(:).nvk;
            %
            % � ��������� -
            % a3_15 = hM.POLI(2:3).a0;
            % a_all = hM.POLI(:).a1;
            
            if ~strcmp(S(1).type, '.')
                error(['�� ������ ������ ���������� ��������� ��� ',...
                    '������� ".".'])
            end
            
            switch length(S)
                case 2
                    if ~strcmp(S(2).type, '.')
                        error(['�� ������ ������ ���������� ��������� ',...
                            '��� ������� ".".'])
                    end
                    Str = [S(1).type, S(1).subs, S(2).type, S(2).subs];
                case 3
                    switch S(2).type
                        case '.'
                            Str = [S(1).type, S(1).subs, S(2).type,...
                                S(2).subs, S(3).type, S(3).subs];
                        case '()'
                            Str = [S(1).type, S(1).subs, S(3).type,...
                               S(3).subs, S(2).type(1),...
                                mat2str(S(2).subs{1}), S(2).type(2)];
                        otherwise
                            error(['�� ������ ������ ���������� ',...
                                '��������� ��� ������� "." ��� "()".'])
                    end
                otherwise
                    error('��������� ��� ��� ��� ������ ����������.')
            end
        end
    end
end