function [ModelSIMCA, TestSIMCA] = DS_SIMCA(varargin)
    % DS_SIMCA aplica Kennard-Stone apenas no primeiro conjunto de dados (S1), enquanto todos os outros são dados de teste.
    % -------------------------------------------------------------------------
    % Uso:
    %   [ModelSIMCA, TestSIMCA] = DS_SIMCA(S1, LabelS1, S2, LabelS2, ...)
    % -------------------------------------------------------------------------
    % Entradas:
    %   - S1, LabelS1: Primeiro conjunto de dados e rótulos (usados para divisão de treino/teste)
    %   - S2, LabelS2, ...: Outros conjuntos de dados e rótulos (usados inteiramente para teste)
    % -------------------------------------------------------------------------
    % Saídas:
    %   - ModelSIMCA : Conjunto de dados contendo dados de treino (de S1)
    %   - TestSIMCA  : Conjunto de dados contendo dados de teste (de S1 e todos os outros conjuntos de dados)
    % -------------------------------------------------------------------------
    % Exemplo:
    %   [ModelSIMCA, TestSIMCA] = DS_SIMCA(data1, labels1, data2, labels2, data3, labels3);
    % -------------------------------------------------------------------------
    % Escrito por:
    % Hélio Milito Martins de Amorim Neto
    % Departamento de Química, Instituto de Ciências Exatas
    % Universidade Federal de Minas Gerais
    % Janeiro 2025
    % -------------------------------------------------------------------------
    
    numInputs = length(varargin);
    
    if mod(numInputs, 2) ~= 0
        error('Cada conjunto de dados deve ter um vetor de rótulos correspondente.');
    end

    numDatasets = numInputs / 2; % Número de pares conjunto de dados-rótulos

    % Extrair o primeiro conjunto de dados e seus rótulos
    S1 = varargin{1};
    LabelS1 = varargin{2};

    % Validar o primeiro conjunto de dados
    if ~isnumeric(S1)
        error('O primeiro conjunto de dados (S1) deve ser uma matriz numérica.');
    end
    if length(LabelS1) ~= size(S1, 1)
        error('LabelS1 deve ter o mesmo número de linhas que S1.');
    end

    numRows = size(S1, 1);
    k = round(2/3 * numRows); % Selecionar 2/3 das linhas para o conjunto de treino

    % Aplicar Kennard-Stone apenas em S1
    [modelIdx, testIdx] = kenstone(S1, k);

    % Dados de treino (de S1)
    ModelSIMCA = dataset(S1(modelIdx, :));
    LabelModel = LabelS1(modelIdx, :);

    % Dados de teste (teste S1 + todos os outros conjuntos de dados)
    TestSIMCA = dataset(S1(testIdx, :));
    LabelTest = LabelS1(testIdx, :);

    % Processar conjuntos de dados adicionais (S2, S3, ...)
    for i = 2:numDatasets
        X = varargin{2*i-1}; % Conjunto de dados
        labels = varargin{2*i}; % Rótulos correspondentes

        % Validar conjunto de dados
        if ~isnumeric(X)
            error('Conjunto de dados %d deve ser uma matriz numérica.', i);
        end
        if length(labels) ~= size(X, 1)
            error('O vetor de rótulos %d deve ter o mesmo número de linhas que seu conjunto de dados.', i);
        end

        % Adicionar todo o conjunto de dados ao conjunto de teste
        TestSIMCA = dataset(cat(1, X, double(TestSIMCA))); % Converter para double para evitar erros
        LabelTest = cat(1, labels, LabelTest);
        ModelSIMCA.label{1}={LabelModel};
        TestSIMCA.label{1}={LabelTest};
       
    end
end

% -------------------------------------------------------------------------
% Função incorporada Kenstone
% Function:
% [model,test]=kenstone(X,k) 
% -------------------------------------------------------------------------
% Aim:
% Uniform subset selection with Kennard and Stone algorithm
% -------------------------------------------------------------------------
% Input:
% X, matrix (n,p), predictor variables in columns
% k, number of objects to be selected to the model set
% -------------------------------------------------------------------------
% Output:
% model, vector (k,1), list of objects selected to model set
% test, vector (n-k,1), list of objects selected to test set (optionally)
% -----------------------------------------------------------------------
% Example: 
% X=randn(300,2);
% [model,test]=kenstone(X,20)
% [model]=kenstone(X,20)
% plot(X(test,1),X(test,2),'k.');hold on;
% plot(X(model,1),X(model,2),'rs','markerfacecolor','r');
% figure(gcf)
% -----------------------------------------------------------------------
% References:
% [1] R.W. Kennard, L.A. Stone, Computer aided design of experiments, 
% Technometrics 11 (1969) 137-148
% [2] M. Daszykowski, B. Walczak, D.L. Massart, Representative subset selection,
% Analytica Chimica Acta 468 (2002) 91-103
% -------------------------------------------------------------------------
% Written by Michal Daszykowski
% Department of Chemometrics, Institute of Chemistry, 
% The University of Silesia
% December 2004
% http://www.chemometria.us.edu.pl
% -------------------------------------------------------------------------
function [model,test]=kenstone(X,k)
    [m,n]=size(X);
    if k>=m | k<=0  
        h=errordlg('Wrongly specified number of objects to be selected to model set.','Error');
        model=[];
        if nargout==2
            test=[];
        end
        waitfor(h)
        return
    end

    x=[[1:size(X,1)]' X];
    n=size(x,2);
    [i1,ind1]=min(fastdist(mean(x(:,2:n)),x(:,2:n)));
    model(1)=x(ind1,1);
    x(ind1,:)=[];

    [i2,ind2]=max(fastdist(X(model(1),:),x(:,2:n)));
    model(2)=x(ind2,1);
    x(ind2,:)=[];

    for d=3:k
        [ii,ww]=max(min(fastdist(x(:,2:n),X(model,:))));
        model(d)=x(ww,1);
        x(ww,:)=[];
    end

    if nargout==2
        test=1:size(X,1);
        test(model)=[];
    end
end

function D=fastdist(x,y)
    D=((sum(y'.^2))'*ones(1,size(x,1)))+(ones(size(y,1),1)*(sum(x'.^2)))-2*(y*x');
end