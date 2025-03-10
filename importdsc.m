function importdsc(X, Y)
    % -------------------------------------------------------------------------
    % Função:
    % importdsc(X, Y)
    % -------------------------------------------------------------------------
    % Uso:
    % Esta função importa dados de arquivos .txt de análises DSC na pasta atual, realiza o processamento necessário e 
    % os adiciona ao workspace do MATLAB. 
    % -------------------------------------------------------------------------
    % Parâmetros:
    %   X: valor inicial do intervalo de escala
    %   Y: valor final do intervalo de escala
    % -------------------------------------------------------------------------
    % A função executa as seguintes etapas:
    % 1. Identifica todos os arquivos .txt na pasta atual.
    % 2. Inicializa as matrizes de saída Scale e Data.
    % 3. Para cada arquivo .txt:
    %    a. Abre o arquivo e lê seu conteúdo.
    %    b. Identifica a linha que contém o peso da amostra.
    %    c. Localiza a seção [Data] e extrai as colunas de dados.
    %    d. Processa os dados linha por linha e realiza a interpolação dos valores de DSC mW.
    %    e. Adiciona os dados processados à matriz Data.
    % 4. Importa um vetor com os rótulos das amostras.
    % 5. Adiciona as variáveis Scale, Data e Label ao workspace base do MATLAB.
    % -------------------------------------------------------------------------
    % Escrito por:
    % Hélio Milito Martins de Amorim Neto
    % Departamento de Química, Instituto de Ciências Exatas
    % Universidade Federal de Minas Gerais
    % Janeiro 2025
    % -------------------------------------------------------------------------
      
    % Identificar arquivos .txt na pasta atual
    asc = dir('*.txt');
    
    % Inicializar matrizes de saída
    Scale = X:0.1:Y; % Vetor para o intervalo especificado pelo usuário
    Data = []; % Dados importados para todas as amostras
    
    for i = 1:length(asc)
        % Abrir o arquivo atual
        fileID = fopen(asc(i).name, 'r');
        content = textscan(fileID, '%s', 'Delimiter', '\n');
        content = content{1};
        fclose(fileID);

        % Encontrar peso da amostra
        weightLine = false(size(content));
        for j = 1:length(content)
            if ~isempty(strfind(content{j}, 'Sample Weight:'))
                weightLine(j) = true;
            end
        end
        weightStr = regexp(content{weightLine}, '\d+\.\d+', 'match');
        if isempty(weightStr)
            error('Não foi possível encontrar o peso da amostra no arquivo %s.', asc(i).name);
        end
        sampleWeight = str2double(weightStr{1});

        % Localizar a seção [Data] e extrair colunas
        dataStart = find(~cellfun('isempty', strfind(content, '[Data]'))) + 2;
        if isempty(dataStart)
            error('Seção [Data] não encontrada no arquivo %s.', asc(i).name);
        end
        rawData = content(dataStart:end);
        
        % Processar dados linha por linha
        dataArray = [];
        for j = 1:length(rawData)
            lineData = sscanf(rawData{j}, '%f');
            if length(lineData) == 3 % Garantir que haja 3 colunas
                dataArray = [dataArray; lineData'];
            end
        end

        % Verificar se as colunas esperadas estão presentes
        if size(dataArray, 2) < 3
            error('Dados insuficientes no arquivo %s. Verifique se as colunas estão completas.', asc(i).name);
        end

        % Extrair e processar colunas
        tempC = round(dataArray(:, 2) * 10) / 10; % Arredondar Temp C para 1 casa decimal
        dscMw = dataArray(:, 3) / sampleWeight; % Dividir DSC mW pelo peso da amostra

        % Criar matriz temporária para interpolação
        tempMatrix = [tempC, dscMw];
        
        % Remover duplicatas e interpolar valores ausentes
        [uniqueTemp, ia, ~] = unique(tempMatrix(:, 1));
        uniqueDSC = tempMatrix(ia, 2);
        interpolatedDSC = interp1(uniqueTemp, uniqueDSC, Scale, 'linear', 'extrap');
        
        % Preencher valores ausentes conforme especificado
        for j = 1:length(interpolatedDSC)
            if isnan(interpolatedDSC(j))
                prev = find(~isnan(interpolatedDSC(1:j-1)), 1, 'last');
                next = find(~isnan(interpolatedDSC(j+1:end)), 1, 'first') + j;
                if ~isempty(prev) && ~isempty(next)
                    interpolatedDSC(j) = mean([interpolatedDSC(prev), interpolatedDSC(next)]);
                elseif ~isempty(prev)
                    interpolatedDSC(j) = interpolatedDSC(prev);
                elseif ~isempty(next)
                    interpolatedDSC(j) = interpolatedDSC(next);
                else
                    interpolatedDSC(j) = 0; % Valor padrão se nenhum outro estiver disponível
                end
            end
        end

        % Adicionar coluna de dados processados
        Data = [Data, interpolatedDSC'];
    end
    
    % Importa o vetor com os rótulos das amostras
    asc = dir('*.txt');
    nomes_arquivos = {asc.name}';
    Label = cellfun(@(x) strtok(x, '.'), nomes_arquivos, 'UniformOutput', false);
    assignin('base', 'Label', Label);
    clear nomes_arquivos asc
    
    % Adiciona as variáveis Scale, Data e Label ao workspace base
    assignin('base', 'Scale', Scale'); % Transposta de Scale
    assignin('base', 'Data', Data');   % Transposta de Data
    assignin('base', 'Label', Label);  % Vetor Label
   
end