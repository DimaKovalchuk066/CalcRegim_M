classdef CData
    % CData  Value-����� ������������ ���� �������� ������
    % � ������ ���� �� Excel-�����.
    
    % Written by D. Kovalchuk
    % Research group of energetic faculty,
    % department of BNTU.
    % Jule 2017 Mod December 2017
    
    properties(Access = private)
        % ���� ������� ������ ������ � ���� �������� (COMM) ��� ��������
        % �������� (NODE, VETV). ��� ��������� � ����� NODE, VETV,
        % ��������� ����������, �������� ��������� � ��������
        % ��������.
        COMM  % ��������� ����� ����������
        NODE  % ��������� ���������� �� �����
        BRAN  % ��������� ���������� �� ������
    end
    
    methods
        function hDt = CData (xlsFile, options)
            % CData  �����������.
            %
            % hDt = Cdata(xlsFile, options)
            %
            % xlsFile - ��������� ��� ����� MsExcel � ������� �� ����� ����;
            % options - ��������� ����������, ����������� ��� ������������
            % ������;
            %
            % ���� ��������� options:
            % options.NodeSheet - ����� ����� � ����� MsExcel � �������
            % �� �����;
            % options.BranchSheet - ����� ����� � ����� MsExcel � �������
            % �� ������;
            % options.KatLinesSheet - ����� ����� � ����� MsExcel �
            % ��������� ������� �� ������;
            % options.KatTransSheet - ����� ����� � ����� MsExcel �
            % ��������� ������� �� ���������������
            % options.Method - ����� ����� �������� ������.
            
            % ����
            [Data.Sub.Text, Data.Sub.Num, Data.Txt, Data.Num] = hDt.fread(xlsFile, options.NodeSheet, options);
            hDt.NODE = struct(...
                ... % ������
                'Nn1',   int32(Data.Num(:,2)),...        % ���������������� ������ �����
                'Type',  nTip(Data.Num(:,11)),... % ���� ����� (BU, PU ��� PQ)
                'Pn',    Data.Num(:,3),...        % �������� �������� ��������
                'Qn',    Data.Num(:,4),...        % ���������� �������� ��������
                'Pg',    Data.Num(:,5),...        % �������� �������� ���������
                'Qg',    Data.Num(:,6),...        % ���������� �������� ���������
                'Qmin',  Data.Num(:,7),...        % ����������� ������ ���������� ��������
                'Qmax',  Data.Num(:,8),...       % ������������ ������ ���������� ��������
                'Uu',    Data.Num(:,9),...       % ������� ���������� ���������� (��)
                'dUu',   Data.Num(:,10)...       % ���� ���������� (��)   
                );
            hDt.COMM = struct(...
                'TolFun', options.TolFun,...   % �������� ����������
                'Un', Data.Num(1,1)...         % ����������� ����������, ��
                );
            clear Data;
            [Data.Sub.Text, Data.Sub.Num, Data.Txt, Data.Num] = hDt.fread(xlsFile, options.BranchSheet, options);
            hDt.BRAN = struct(...
                ... % ������
                'Nb1',    int32(Data.Num(:,1)),...          % ���������������� ������ ������
                'NbSt',   int32(Data.Num(:,2)),...           % ����� ���� ������
                'NbF',    int32(Data.Num(:,3)),...           % ����� ���� �����
                'CmTpS',  cmTip(Data.Num(:,10)),...   % ��� �� � ������
                'CmStS',  cmStat(Data.Num(:,11)),...  % ��������� �� � ������
                'CmTpF',  cmTip(Data.Num(:,12)),...   % ��� �� � �����
                'CmStF',  cmStat(Data.Num(:,13)),...  % ��������� �� � �����
                'Type',   bTip(Data.Num(:,9)),...    % ��� �����
                'R',      Data.Num(:,4),...           % �������� �������������
                'X',      Data.Num(:,5),...           % ���������� �������������
                'Pxx',    Data.Num(:,6),...           % �������� �������� ��������� ����
                'Qxx',    Data.Num(:,7),...           % ���������� �������� ��������� ����
                'kt',     Data.Num(:,8)...            % ����������� �������������
                );          
        clear Data;        
        end;
        
        function hDt = subsasgn(hDt, S, B)
            % ����� ���������� ������������. ��������� ������������ �����
            % ������� ����� ��������. ��������� ���������� ����� �������
            % �������������� �� �������� ��������.
            %
            % hDt = subsasgn(hDt, S, B)
            %
            % hDt - ������; S - ��������� ���������� �������; B -
            % ������������� ��������.
            
            str = hDt.subs2str(S);
            eval(['hDt', str, '=', num2str(B),';']);
        end
        
        function B = subsref(hDt, S)
            % ����� ��������� ������. ��������� ��������� � ����� �������
            % �� �������� �������� ���������� ����������.
            %
            % B = subsref(hDt, S)
            %
            % hDt - ������; S - ��������� ���������� �������; B -
            % ��������� ��������� � ������� �� ��������� ������.
            if length(S) == 1
                str=[S.type,S.subs];
                B = eval(['hDt', str]);
            elseif length(S) == 2 &&...
                    strcmp(S(2).type, '.') &&...
                    strcmp(S(2).subs, 'n')
                
                % ����� ���������
                switch S(1).subs
                    case 'NODE'
                        B = length(hDt.NODE.Nn);
                    case 'BRANCH'
                        B = length(hDt.VETV.Nb);
                    otherwise
                        B = 0;
                        warning ('���������� ����� ����� ���� %s (�� ����������)',S);
                end
            else
                % ��������� ���������
                str = hDt.subs2str(S);
                B = eval(['hDt', str]);
            end
        end
    end
    
    methods(Access = private)
        
        function [SubText, SubNumb ,DataText,DataNumb] = fread (hDt, xlsFile, NumSheet, options)
            % ����� ����������� ����� ������� ���������� ������.
            % (���������� ���� ������ �� Excel, ������� ������ ���
            % ����������� ���������� �����������).
            %
            % [SubText, SubNumb ,DataText, DataNumb] = fread (hDt, xlsFile, NumSheet, options)
            %
            % SubText - ������� � ��������� ����; SubNumb - ������� �
            % ��������� ����; DataText - ������ � ��������� �����; DataNumb
            % - ������ � �������� �����.
            % hDt - ������, xlsFile - ��� ����� � ���� ������, NumSheet -
            % ����� ����� � Excel, options - ����� ���������� ������
            if (options.Method ==  methTip.XLS)
                [SubText, SubNumb ,DataText,DataNumb] = hDt.fxlsread(xlsFile, NumSheet, options);
                %else if (options.Method ==  methTip.MANUAL)
                % Data= fmanualIn (Data);
                
            else
                error(['��������������� ����� ����� ������']);
            end
        end
               
        function [SubText, SubNumb ,DataText,DataNumb] = fxlsread (hDt, xlsFile, NumSheet, options)
            % ����� ���������� � ��������� ������ � ������� xls
            % ��������� �������� ��������� ������ ���������� �� ��������� �
            % ��������
            %
            % [SubText, SubNumb ,DataText, DataNumb] = fxlsread (hDt, xlsFile, NumSheet, options)
            %
            % hDt - ������; xlsFile - ��� �����; NumSheet - �����
            % ������������ �����; options - ����� ���������� ������.
            % SubText - ��������� �������; SubNumb - �������� �������;
            % DataText - ��������� ������; DataNumb - ��������� ������.
            
            % ������ ������ �� �����
            [Xls.Num, Xls.Txt, Xls.Full] = xlsread (xlsFile, NumSheet);
            % ������������� ������ � ����������� �� ���� ������������ (����, �����, ��������)
            switch NumSheet
                case options.NodeSheet % ��� ������ �� �����
                    SubText = Xls.Full(2,2:3);
                    SubNumb = [Xls.Full(1,1),Xls.Full(2,1),Xls.Full(2,4:11), Xls.Full(2,3)];
                    DataText = Xls.Full(3:(size(Xls.Num,1)),2:3);
                    DataNumb = [zeros(size(Xls.Num,1)-2,1),...
                        cell2mat([Xls.Full(3:(size(Xls.Num,1)),1),...
                        Xls.Full(3:(size(Xls.Num,1)),4:11)])];
                    DataNumb(1,1)=cell2mat(Xls.Full(1,2));
                    % ������� ���� ���� �� ���������� � �������� ��� �
                    % ������ �������������� ����� ����� �� ����
                    DataNumb(:,11)=hDt.ftype(DataText(:,2), Tip.N);       
                case options.BranchSheet % ��� ������ �� ������
                    SubText = [Xls.Full(2,2),Xls.Full(2,5:6)];
                    SubNumb = [Xls.Full(2,1),Xls.Full(2,3:4),Xls.Full(2,7:11),Xls.Full(2,6)];
                    DataText = [Xls.Full(2:(size(Xls.Num,1)+1),2),Xls.Full(2:(size(Xls.Num,1)+1),5:6)];
                    DataNumb = cell2mat([Xls.Full(2:(size(Xls.Num,1)+1),1),...
                        Xls.Full(2:(size(Xls.Num,1)+1),3:4), Xls.Full(2:(size(Xls.Num,1)+1),7:11)]);
                    DataNumb(:,9)=hDt.ftype(DataText(:,3), Tip.B);
                    DataNumb(:,10:13)=hDt.ftype(DataText(:,2), Tip.Commt);    
                otherwise
                    error ('�������� ����� ����� xls-�����. CData');
            end
            DataNumb(isnan(DataNumb)) = 0;  % �������� NaN �� 0
        end    
    end
    
    methods(Static, Access = private)
        
        function Numb = ftype (Text, Object)
            % ����� ������� ����� ����� � ������ �� ������� ����� �
            % �������� ��� ��������� ����������� �������������
            %
            % Numb = ftype(Text, Object);
            %
            % Text - ������� ��������� ����������; Object - ��� �������
            % Tip.N, Tip.V, Commt.
            % Numb - ���������� �� ������� � �������� ����
            
            % ����� �� ���� ����� ��������
            switch Object
                case Tip.N % ����
                    for i=1:size(Text,1)
                        switch 1
                            case (strcmpi(Text(i),'����'))
                                Numb(i,1) = 1;
                            case (strcmpi(Text(i),'��'))
                                Numb(i,1) = 2;
                            case (strcmpi(Text(i),'���'))
                                Numb(i,1)= 3;
                            otherwise
                                Numb(1,i) = 1;
                                warning (...
                                    '�������������� ��� ���� � ������ %s �����\n��� ���������� "��������"'...
                                    ,mat2str(i));
                        end
                    end
                case Tip.B % �����
                    for i=1:size(Text,1)
                        switch 1
                            case (strcmpi(Text(i),'�����'))
                                Numb(i,1) = 1;
                            case (strcmpi(Text(i),'�����'))
                                Numb(i,1) = 2;
                            otherwise
                                Numb(i,1) = 1;
                                warning (...
                                    '�������������� ��� ����� � ������ %s �����\n��� ���������� "�����"'...
                                    ,mat2str(i));
                        end
                    end
                    
                case Tip.Commt % �������������� �������
                    clear k;
                    for i=1:size(Text,1)
                        k=Text{i};
                        if length(k)==4
                            for j= [1,3]
                                switch 1
                                    case (strcmpi(k(j),'�'))
                                        Numb(i,j) = 1;
                                    case (strcmpi(k(j),'�'))
                                        Numb(i,j) = 2;
                                    case (strcmpi(k(j),'�'))
                                        Numb(i,j) = 3;
                                    case (strcmpi(k(j),' '))
                                        Numb(i,j) = 4;
                                    otherwise
                                        Numb(i,j) = 4;
                                        warning (...
                                            '�������������� ��� ��������������� �������� � ������ %s �����\n��� ���������� " "'...
                                            ,mat2str(i));
                                end
                                switch 1
                                    case (strcmp(k(j+1),'0'))
                                        Numb(i,j+1) = 0;
                                    case (strcmp(k(j+1),'1'))
                                        Numb(i,j+1) = 1;
                                    case (strcmp(k(j+1),'2'))
                                        Numb(i,j+1) = 2;
                                    case (strcmp(k(j+1),'3'))
                                        Numb(i,j+1) = 3;
                                    case (strcmp(k(j+1),' '))
                                        Numb(i,j+1) = 3;
                                    otherwise
                                        Numb(i,j+1) = 3;
                                        warning (...
                                            '�������������� ��������� ��������������� �������� � ������ %s �����\n ����������� " "'...
                                            ,mat2str(i));
                                end
                            end
                        else
                            Numb(i,:) = [4,0,4,0]
                            warning ('�������� ���������� �������� � �������� �� � ������ %s �����\n��� ���������� "    "'...
                                ,mat2str(i));
                        end
                    end
            end
        end
        
        
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
            % a = hDt.NODE.Pn;
            
            if ~strcmp(S(1).type, '.')
                error(['�� ������ ������ ���������� ��������� ��� ������� ".".'])
            end
            
            switch length(S)
                case 2
                    if ~strcmp(S(2).type, '.')
                        error(['�� ������ ������ ���������� ��������� ��� ������� ".".'])
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
                            error(['�� ������ ������ ���������� ��������� ��� ������� "." ��� "()".'])
                    end
                otherwise
                    error('��������� ��� ��� ��� ������ ����������.')
            end
        end
    end
end