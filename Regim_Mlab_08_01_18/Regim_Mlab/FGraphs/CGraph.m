classdef CGraph
    % CGraph  Value-����� ������ ���� ����� � ������������� ���������� ���
    % ������ � ������. ����������� ������ ���������� ��������� ������
    % ������.
    %
    % �������������� ��������� ��������� ��������� � ������� g �������
    % ������:
    % g.nod.n - ����� ����� �����;
    % g.nod(i) - ������ �������� ����� �����;
    % g.nod(i).an - ������ �������� ������� ����� �����
    % g.nod(i).ar - ������ �������� ������� ������ �����
    % g.rib.n - ����� ������ �����;
    % g.rib(i) - ������ �������� ������ �����;
    % g.rib(i).ny1 - ������ �������� ����� ������ (� nod)
    % g.rib(i).ny2 - ������ �������� ����� ����� (� nod)
    %
    % Written by A.Zolotoy
    % Research group of energetic faculty,
    % department of BNTU.
    % April 2017, June 2017.
    
    properties(Access = private)
        nod   % ������ ������ n �������� ����� � ����� ������� ������ �� ����� ����� ������ N (n <= N)
        ira   % ������ ����� ������� ����� ������ n, ��� n - ����� �����
        lra   % ������ ����� ������������ ������� ������� ����� � ������ � �������� ka � kb ������ n, ��� n - ����� �����
        rib   % ������ ������ m �������� ������ � ����� ������� ������ �� ������ ����� ������ M (m <= M)
        ny1   % ������ ������� ����� ������ ������ (� nod) ������ m, ��� m - ����� ������
        ny2   % ������ ������� ����� ����� ������ (� nod) ������ m, ��� m - ����� ������
        ka    % ������ ������� ������� ����� (� nod) ������ 2m, ��� m - ����� ������
        kb    % ������ ������� ������� ������ (� rib) ������ 2m, ��� m - ����� ������
        ny    % ���������� �����
        nb    % ���������� ������
    end
    
    methods
        function g = CGraph(varargin)
            % CGraph  �����������.
            %
            % g = CGraph
            % g = CGraph(g1)
            % g = CGraph(hFN, I, hFV, J)
            %
            % g = CGraph ����������� �� ���������. ������ ������ ������.
            %
            % g = CGraph(g1) ����������� �����������. �������� ������ ��
            % ������� g1 ������������ ����.
            %
            % g = CGraph(hFN, I, hFV, J) ������ ���� �� ������� ������.
            % I, J - ������� �������� ����� � ������ � ������ �� �����
            % ��������� n-��-1 � m-��-1, ��� n - ����� �����, m - �����
            % ������; hFN, hFV - handles �������, ������� �� �������� �
            % �������� ������ ���������� ������ ����� � ������ �����.
            % N = hFN(I) - ���������� ������ n-��-1 ������� ����� �����;
            % V = hFN(J) - ���������� ������ m-��-1 ������� ������ �����
            % (V(:,1) - ������ �����, V(:,2) - ������ ������).
            
            if isempty(varargin)
                return
            elseif length(varargin) == 1
                if isa(varargin{1}, 'CGraph')
                    g = varargin{1};
                else
                    error('�������� ������ ���� "CGraph".');
                end
            elseif length(varargin) == 4
                hFN = varargin{1};
                I = varargin{2};
                hFV = varargin{3};
                J = varargin{4};
                
                g.ny = length(I);
                g.nb = length(J);
                g.nod = I;
                g.ira = zeros(g.ny, 1);
                g.lra = zeros(g.ny, 1);
                g.rib = J;
                g.ny1 = zeros(g.nb, 1);
                g.ny2 = zeros(g.nb, 1);
                g.ka = zeros(2, 1);
                g.kb = zeros(2, 1);
                
                N = hFN(I);
                V = hFV(J);
                if isempty(V)==0
                    g = g.CalcAdr(N, V);
                end
            else
                msg = ['�������� ���������� ������� ���������� - \n',...
                    '%s\n%s\n%s'];
                error(msg, 'g = CGraph;', 'g = CGraph(g1);',...
                    'g = CGraph(hFN, I, hFV, J).'); %#ok<CTPCT>
            end
        end
        
        function B = subsref(g, S)
            % ����� ��������� ������. ��������� ��������� � ����� �������
            % �� �������� �������� ���������� ����������.
            %
            % B = subsref(g, S)
            %
            % g - ������; S - ������ �������� ���������� �������; B -
            % ��������� ��������� � ������� �� ��������� ������.
            
            if length(S) == 2 &&...
                    strcmp(S(1).type, '.') &&...
                    strcmp(S(2).type, '.') &&...
                    strcmp(S(2).subs, 'n')
                % ����� ��������� ����� (g - ������)
                switch S(1).subs
                    case 'nod'
                        B = g.ny;
                    case 'rib'
                        B = g.nb;
                    otherwise
                        B = 0;
                end
            elseif length(S) == 3 &&...
                    strcmp(S(1).type, '()') &&...
                    strcmp(S(2).type, '.') &&...
                    strcmp(S(3).type, '.') &&...
                strcmp(S(3).subs, 'n')
                % ����� ��������� ����� (g - �������)
                switch S(2).subs
                    case 'nod'
                        str = g.s2str(S(1));
                        B = eval(['length(g', str, '.nod)']);
                    case 'rib'
                        str = g.s2str(S(1));
                        B = eval(['length(g', str, '.rib)']);
                    otherwise
                        B = 0;
                end
            elseif length(S) > 2 &&...
                    strcmp(S(end-2).type, '.') &&...
                    strcmp(S(end-1).type, '()') &&...
                    strcmp(S(end).type, '.') &&...
                    strcmp(S(end).subs, 'ny')
                if strcmp(S(end-2).subs, 'rib')
                    if length(S) > 3
                    str1 = [g.s2str(S(1))];
                    else
                        str1='';
                    end
                    str2 = [g.subs2str(S(end-1))];
                    B(:,1) = eval(['g',str1,'.ny1',str2]);
                    B(:,2) = eval(['g',str1,'.ny2',str2]);
                    return;
                else
                    B = 0;
                end
            else
                % ��������� ��������� �����
                if length(g(:)) < 2 && strcmp(S(1).type, '.')
                    str = g.subs2str(S);
                elseif length(S) < 2
                    str = g.s2str(S(1));
                else
                    str = [g.s2str(S(1)), g.subs2str(S(2:end), 2)];
                end
                B = eval(['g', str]);
            end
        end
        
        function TF = isempty(g)
            % ����� ���������� true ���� ������ ������.
            %
            % TF = isempty(g)
            %
            % g - ������.
            
            TF = isempty(g.nod) && isempty(g.rib);
        end
    end
    
    methods(Access = private)
        function g = CalcAdr(g, N, V)
            % ����� ��������� �������� �����������.
            %
            % g = CalcAdr(g, N, V)
            %
            % N - ������ �������� n-��-1 ������� ����� �����, ��� n - �����
            % �����; V - ������ �������� m-��-2 ������� ������ �����, ���
            % m - ����� ������ (V(:,1) - ������ �����, V(:,2) - ������
            % ������).
            
            %ny = length(g.nod);
            %nb = length(g.rib);
            
            % �������� ����������� ������:
            for i = 1:g.ny
                g.ny1(V(:,1) == N(i)) = i;
                g.ny2(V(:,2) == N(i)) = i;
            end
            
            % �������� ����������� �����:
            jrab = 0;
            for i = 1:g.ny
                irab = 0;
                for j = 1:g.nb
                    if (i == g.ny1(j))
                        jrab = jrab + 1;
                        irab = irab + 1;
                        g.ka(jrab) = g.ny2(j);
                        g.kb(jrab) = j;
                    end;
                    if (i == g.ny2(j))
                        jrab = jrab + 1;
                        irab = irab + 1;
                        g.ka(jrab) = g.ny1(j);
                        g.kb(jrab) = j;
                    end
                    g.lra(i) = jrab - irab;
                end
                g.ira(i) = irab;
            end
        end
        
        function K = getan(g, I)
            % ����� ���������� ������� �������� ������� ����� �����.
            %
            % K = getan(g, I)
            %
            % g - ������; I - ������ �������� ����� ������ n, ��� n - �����
            % �����, ��� ������� ��������� ������� ������� �������� �������
            % �����; K - ������� �������� ������� �����.
            %
            % I ����� ���� �������� ��� ��������. ���� I ������, �� K
            % �������� �������� �������� ����� ����� �������� k-��-1, ���
            % k - ����� �����, ������� ���� ����� � ��������, ��������� �
            % I. ���� I ������, �� � �������� �������� ����� (cell array)
            % �������� n-��-1, ��� n - ����� ������� I. � ������ ������
            % ������� � ���������� ������ �������� ����� �����, �������
            % ����, ������ �������� ������ � ��������������� ��������
            % ������� I.
            
            if length(I) > 1
                K = cell(length(I), 1);
                for i = 1:length(I)
                    lrab = g.lra(I(i)) + 1;
                    irab = g.lra(I(i)) + g.ira(I(i));
                    K{i} = g.ka(lrab:irab);
                end
            else
                lrab = g.lra(I) + 1;
                irab = g.lra(I) + g.ira(I);
                K = g.ka(lrab:irab);
            end
        end
        
        function K = getar(g, I)
            % ����� ���������� ������� �������� ������� ������ �����.
            %
            % K = getar(g, I)
            %
            % g - ������; I - ������ �������� ����� ������ n, ��� n - �����
            % �����, ��� ������� ��������� ������� ������� �������� �������
            % ������; K - ������� �������� ������� ������.
            %
            % I ����� ���� �������� ��� ��������. ���� I ������, �� K
            % �������� �������� �������� ������ ����� �������� k-��-1, ���
            % k - ����� ������, ������� ���� ����� � ��������, ��������� �
            % I. ���� I ������, �� � �������� �������� ����� (cell array)
            % �������� n-��-1, ��� n - ����� ������� I. � ������ ������
            % ������� � ���������� ������ �������� ������ �����, �������
            % ����, ������ �������� ������ � ��������������� ��������
            % ������� I.
            
            if length(I) > 1
                K = cell(length(I), 1);
                for i = 1:length(I)
                    lrab = g.lra(I(i)) + 1;
                    irab = g.lra(I(i)) + g.ira(I(i));
                    K{i} = g.kb(lrab:irab);
                end
            else
                lrab = g.lra(I) + 1;
                irab = g.lra(I) + g.ira(I);
                K = g.kb(lrab:irab);
            end
        end
        
        function Str = subs2str(g, S, i)
            % ����� ����������� ������ �������� ���������� ������� � ������.
            % ���������� ������� ���������� �������. ������������ � �������
            % subsref � subsasgn.
            %
            % Str = subs2str(S)
            %
            % g - ������; S - ������ �������� ��������� ������; i -
            % ���������� ������ ������� �������� � ������� �������� S ���
            % ������������ �������������� ������� � ������ ����������
            % �������; Str - ������ ���������� �������.
            %
            % �������������� ��������� ��������� ��������� � �������:
            % g.nod.n - ����� ����� �����;
            % g.nod(i) - ������ �������� ����� �����;
            % g.nod(i).an - ������ �������� ������� ����� �����
            % g.nod(i).ar - ������ �������� ������� ������ �����
            % g.rib.n - ����� ������ �����;
            % g.rib(i) - ������ �������� ������ �����;
            % g.rib(i).ny1 - ������ �������� ����� ������ (� nod)
            % g.rib(i).ny2 - ������ �������� ����� ����� (� nod)
            % g.rib(i).kc1 - ������ �������� ���������� ������ ������ �����
            % g.rib(i).kc2 - ������ �������� ���������� ����� ������ �����
            
            if nargin < 3
                i = 1;
            end
            
            if strcmp(S(1).type, '.') && (...
                    strcmp(S(1).subs, 'nod') || strcmp(S(1).subs, 'rib'))
                % ��������� � ����� ������� � ���������� ����������
                switch length(S)
                    case 1
                        Str = [S(1).type, S(1).subs];
                    case 2
                        if ~strcmp(S(2).type, '()')
                            msg = ['�� %d-� ������ ��������� ��� ',...
                                '������� "()".'];
                            error(msg, i+1)
                        end
                        Str = [S(1).type, S(1).subs,...
                            S(2).type(1), mat2str(S(2).subs{1}), S(2).type(2)];
                    case 3
                        if ~strcmp(S(3).type, '.')
                            msg = ['�� %d-� ������ ��������� ��� ',...
                                '������� ".".'];
                            error(msg, i+2)
                        end
                        switch S(3).subs
                            case 'an'
                                if strcmp(S(1).subs, 'nod')
                                    Str = [S(3).type, 'getan(S(',...
                                        mat2str(i+1),').subs{1})'];
                                else
                                    msg = ['�� %d-� ������ ���������� ',...
                                        '�������� ��������� ������ ',...
                                        '"nod".'];
                                    error(msg, i)
                                end
                            case 'ar'
                                if strcmp(S(1).subs, 'nod')
                                    Str = [S(3).type, 'getar(S(',...
                                        mat2str(i+1),').subs{1})'];
                                else
                                    msg = ['�� %d-� ������ ���������� ',...
                                        '�������� ��������� ������ ',...
                                        '"nod".'];
                                    error(msg, i)
                                end
                            case {'ny1', 'ny2', 'ny'}
                                if strcmp(S(1).subs, 'rib')
                                    Str = [S(1).type, S(3).subs,...
                                        S(2).type(1), mat2str(S(2).subs{1}),...
                                        S(2).type(2)];
                                else
                                    msg = ['�� %d-� ������ ���������� ',...
                                        '�������� ��������� ������ ',...
                                        '"rib".'];
                                    error(msg, i)
                                end
                        end
                    otherwise
                        msg = '��������� %d ��� %d ������ ����������.';
                        error(msg, i, i+2)
                end
            else
                % ��������� ������ ��������� - ��� ��������� ����������
                Str = g.s2str(S);
            end
        end
    end
    methods(Static, Access = private)
        function Str = s2str(S)
            % ����� ����������� ������ �������� ���������� ������� � ������
            % ��� ��������� ���������� ���������.
            %
            % Str = s2str(S)
            %
            % S - ������ �������� ��������� ������; Str - ������ ����������
            % �������.
            
            Str = [];
            for i = 1:length(S)
                switch S(i).type
                    case '()'
                        Str = [Str, S(i).type(1)]; %#ok<AGROW>
                        for j = 1:length(S(i).subs)
                            Str = [Str, mat2str(S(i).subs{j})]; %#ok<AGROW>
                            if j < length(S(i).subs)
                                Str = [Str, ',']; %#ok<AGROW>
                            end
                        end
                        Str = [Str, S(i).type(2)]; %#ok<AGROW>
                    case '.'
                        Str = [Str, S(i).type, S(i).subs]; %#ok<AGROW>
                end
            end
        end
    end
end