classdef FIFO
    % FIFO  Value-����� - ���������� ������ �� ������ ���� ������ ����� ������ ����
    
    % Written by D. Kovalchuk
    % Research group of energetic faculty,
    % department of BNTU.
    % Jule 2017.
    
    properties(Access = private)
        QUEUE  % ����
        LAST % ��������� �������
        SIZED % ������� ������� ����������� (1- �������, 0 - ���������)
        SCONST % ���������� ���������, ����������� �� ������ ���� ���������� ������� ������� ��� ������� ��������� �����������
        TYPE % ��� ��������� �����
    end
    
    methods
        function Stack = FIFO(varargin)
            % Stack  �����������.
            Stack.SCONST = 10;
            switch length(varargin)
                case 0
                    Stack.TYPE = double(0);
                    Stack.QUEUE (Stack.SCONST) = Stack.TYPE;
                    Stack.LAST = 0;
                    Stack.SIZED = 0;
                case 1
                    Stack.TYPE = varargin{1};
                    Stack.QUEUE (Stack.SCONST) = Stack.TYPE;
                    Stack.LAST = 0;
                    Stack.SIZED = 0;
                case 2
                    Stack.TYPE = varargin{1};
                    Stack.QUEUE (varargin{2}) = Stack.TYPE;
                    Stack.LAST = 0;
                    Stack.SIZED = 1;             
            end
        end

        function B = subsref(Stack, S)
            % ����� ��������� ������. ��������� ��������� � ����� �������
            % �� �������� �������� ���������� ����������.
            %
            % B = subsref(g, S)
            %
            % Stack - ������; S - ������ �������� ���������� �������; B -
            % ��������� ��������� � ������� �� ��������� ������.
            
            if length(S) == 1 &&...
                    strcmp(S(1).type, '.')
                
                switch S(1).subs
                    case 'n' % ���������� ���������
                        B = Stack.LAST;
                    case 'len' % ������� ����� �����
                        B = length(Stack.QUEUE);
                    case 'last' % ������ � ������� ������� (������ ����������)
                        B = Stack.QUEUE(1);
                    case 'list' % ������ ���������
                        B = Stack.QUEUE(:);
                    case 'options' % ������ ���������
                        B.SIZED = Stack.SIZED;
                        B.SCONST = Stack.SCONST;
                        B.SCONST = Stack.SCONST;
                    otherwise
                        B = 0;
                end     
            %elseif length(S) == 1
            %    str = Stack.s2str(S);
            %    B = eval(['Stack.QUEUE', str]);
            else
                msg = ['�������� ������ ��������� � �����'];
                warning(msg);
            end
        end
        
        function Stack = add(Stack, Obj)
            % ����� ��������� ������� ��������� � ����. �������� ����������
            % ������������ ����� ���������, � ����� �������� ���������.
            % �������������� �������������� ����� ����������� ��������� �
            % ���� ��������� �����, ��� ������������� �������������� ������
            % �� ����������.
            %
            % Stack = add(Stack, Obj)
            %
            % Stack - ������ ���� �������.
            % Obj - ����������� �������       

            % ��������� ������
            if (length(Stack.QUEUE)<Stack.LAST+length(Obj))
                if Stack.SIZED==0
                    if length(Obj)<=Stack.SCONST
                        nAdd=Stack.SCONST;
                        Stack.QUEUE(length(Stack.QUEUE)+Stack.SCONST) = Stack.TYPE;
                    else
                        nAdd=Stack.SCONST*fix(Stack.SCONST/length(Stack.QUEUE));
                        Stack.QUEUE(length(Stack.QUEUE)+nAdd) = Stack.TYPE;
                    end
                else
                    msg = ['������ ������������ �����, ������ �� �����������'];
                    warning(msg);
                end
            end 
            % ��� ������ ������������ warning, � ������ ����������
            try
                if length(Obj)==1
                    Stack.LAST=Stack.LAST+1;
                    Stack.QUEUE(Stack.LAST)=Obj;
                else
                    Stack.QUEUE(Stack.LAST+1:Stack.LAST+length(Obj))=Obj;
                    Stack.LAST=Stack.LAST+length(Obj);                    
                end
            catch
                warning('�������� ���. ������ �� �����������');
                Stack.QUEUE((length(Stack.QUEUE)-nAdd+1):length(Stack.QUEUE))=[];
                return
            end
        end
        
        function TF = isempty(Stack)
            % ����� ���������� true ���� ������ ������.
            %
            % TF = isempty(Stack)
            %
            % Stack - ������.
            if (Stack.LAST==0)
                TF=1;
            else
                TF=0;
            end
        end
        
        function Stack=del(Stack)
            % ������� ��������� ������� �� �����
            %
            % Stack=del(Stack)
            %
            % Stack - ������.
            if Stack.LAST~=0
                Stack.LAST=Stack.LAST-1;
                Stack.QUEUE(1:Stack.LAST)=Stack.QUEUE(2:Stack.LAST+1);
                Stack.QUEUE(Stack.LAST+1)=0;
                if ((Stack.LAST+2*Stack.SCONST) <= length (Stack.QUEUE)) && (Stack.SIZED == 0)
                   Stack.QUEUE((length (Stack.QUEUE)-Stack.SCONST+1):end)=[]; 
                end
            else
                msg = ['���� ������, �������� �� �����������'];
                display(msg);
            end
        end
        
    end
    methods (Access = private)
                function QUEUE = subsasgn(Stack, S, B)
            
            % ����� ���������� ������������. ��������� ������������ �����
            % ������� ����� ��������. ��������� ���������� ����� �������
            % �������������� �� �������� ��������.
            %
            % hM = subsasgn(hM, S, B)
            %
            % hM - handel �������; S - ��������� ���������� �������; B -
            % ������������� ��������.
            
            str = Stack.s2str(S);
            eval(['Stack', str, '=', num2str(B),';']);
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