function [ModelPLSDA, TestPLSDA] = DS_PLSDA(varargin)
    % DS_PLSDA divide múltiplos conjuntos de dados usando Kennard-Stone e os mescla.
    % -------------------------------------------------------------------------
    % Uso:
    %   [ModelPLSDA, TestPLSDA] = DS_PLSDA(S1, LabelS1, S2, LabelS2, ...)
    % -------------------------------------------------------------------------
    % Entradas:
    %   - S1, S2, ...     : Conjuntos de dados numéricos (matrizes)
    %   - LabelS1, LabelS2, ... : Rótulos correspondentes (categóricos, numéricos ou em array de células)
    % -------------------------------------------------------------------------
    % Saídas:
    %   - ModelPLSDA : Conjunto de dados contendo todos os conjuntos de modelos mesclados
    %   - TestPLSDA  : Conjunto de dados contendo todos os conjuntos de teste mesclados
    % -------------------------------------------------------------------------
    % Exemplo:
    %   [ModelPLSDA, TestPLSDA] = DS_PLSDA(data1, labels1, data2, labels2);
    % -------------------------------------------------------------------------
    % Escrito por:
    % Hélio Milito Martins de Amorim Neto
    % Departamento de Química, Instituto de Ciências Exatas
    % Universidade Federal de Minas Gerais
    % Janeiro 2025
    % -------------------------------------------------------------------------
    
    numInputs = length(varargin);  
    numDatasets = numInputs / 2; % Número de conjuntos de dados (cada conjunto de dados tem um rótulo correspondente)

    if mod(numInputs, 2) ~= 0
        error('Cada conjunto de dados deve ter um vetor de rótulos correspondente.');
    end

    modelSets = cell(1, numDatasets);
    testSets = cell(1, numDatasets);
    modelLabels = cell(1, numDatasets);
    testLabels = cell(1, numDatasets);

    for i = 1:numDatasets
        X = varargin{2*i-1}; % Conjunto de dados
        labels = varargin{2*i}; % Rótulos correspondentes

        % Validar conjunto de dados e rótulos
        if ~isnumeric(X)
            error('Conjunto de dados %d deve ser uma matriz numérica.', i);
        end
        if length(labels) ~= size(X, 1)
            error('O vetor de rótulos %d deve ter o mesmo número de linhas que seu conjunto de dados.', i);
        end

        numRows = size(X, 1);
        k = round(2/3 * numRows); % Selecionar 2/3 das linhas para o conjunto de modelos

        % Aplicar a função Kennard-Stone
        [model, test] = kenstone(X, k);

        % Armazenar conjuntos de modelo e teste
        modelSets{i} = X(model, :);
        testSets{i} = X(test, :);

        % Armazenar rótulos correspondentes
        modelLabels{i} = labels(model, :);
        testLabels{i} = labels(test, :);
    end

    % Mesclar todos os conjuntos de modelos, conjuntos de teste e seus rótulos
    ModelPLSDA = dataset(cat(1, modelSets{:})); 
    TestPLSDA = dataset(cat(1, testSets{:})); 
    LabelModel = cat(1, modelLabels{:});
    LabelTest = cat(1, testLabels{:});
    ModelPLSDA.label{1}={LabelModel};
    TestPLSDA.label{1}={LabelTest};
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