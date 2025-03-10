% -------------------------------------------------------------------------
% Fun��o:
% importxrf
% -------------------------------------------------------------------------
% Uso:
% Esta fun��o importa dados de arquivos .txt de an�lises Raman na pasta atual, realiza o processamento necess�rio e 
% os adiciona ao workspace do MATLAB. 
% -------------------------------------------------------------------------
% A fun��o executa as seguintes etapas:
% 1. Identifica todos os arquivos .txt na pasta atual.
% 2. Inicializa a matriz de sa�da Data.
% 3. Abre o arquivo e l� seu conte�do para cada arquivo .txt:
% 4. Importa um vetor com os r�tulos das amostras.
% 5. Adiciona as vari�veis Data e Label ao workspace base do MATLAB.
% -------------------------------------------------------------------------
% Escrito por:
% H�lio Milito Martins de Amorim Neto
% Departamento de Qu�mica, Instituto de Ci�ncias Exatas
% Universidade Federal de Minas Gerais
% Janeiro 2025
% -------------------------------------------------------------------------

% Obter lista de arquivos .txt na pasta atual
asc = dir('*.txt');

% Inicializar a matriz Data
Data = [];

% Loop sobre todos os arquivos .txt encontrados
for i = 1:length(asc)
    % Nome do arquivo atual
    nomeArquivo = asc(i).name;
    
    % Importar os dados do arquivo (assumindo que os dados s�o num�ricos)
    % Aqui, utilizamos o comando 'load' para carregar dados num�ricos
    dadosArquivo = load(nomeArquivo);
    
    % Verificar se os dados do arquivo s�o uma coluna ou uma matriz
    if iscolumn(dadosArquivo)
        % Se for uma coluna, s� adicionar na matriz Data
        Data = [Data, dadosArquivo];
    elseif ismatrix(dadosArquivo)
        % Se for uma matriz, concatene coluna por coluna
        Data = [Data, dadosArquivo];
    end
end

% Importa o vetor com os r�tulos das amostras
nomes_arquivos = {asc.name}';
Label = cellfun(@(x) strtok(x, '.'), nomes_arquivos, 'UniformOutput', false);
clear asc dadosArquivo i nomeArquivo nomes_arquivos