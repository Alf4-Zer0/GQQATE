% -------------------------------------------------------------------------
% Função:
% [Poder]=ModelPower(X,T,P,E,L,C) 
% -------------------------------------------------------------------------
% Objetivo:
% Calcular e plotar o poder de modelagem para os modelos SIMCA e DD-SIMCA
% -------------------------------------------------------------------------
% Entrada:
% X, matriz de dados, amostras em linhas e variáveis em colunas
% T, matriz de escores, amostras em linhas e PCs em colunas
% P, matriz de loadings, PCs em linhas e variáveis em colunas
% E, vetor de variáveis, variáveis em linha
% L, threshold (opcional, se vazio L = 0.9)
% C, número de classes (opcional, se vazio C = 1)
% -------------------------------------------------------------------------
% Saída:
% Poder, Poder de Modelagem
% -------------------------------------------------------------------------
% Escrito por:
% Pedro Micael de Castro Caputo, Hélio Milito Martins de Amorim Neto
% Departamento de Química, Instituto de Ciências Exatas
% Universidade Federal de Minas Gerais
% Maio 2024
% -------------------------------------------------------------------------
% Referência:
% WOLD, Svante; SJÖSTRÖM, Michael. SIMCA: um método para analisar dados químicos em termos de similaridade e analogia.
% DOI: 10.1021/bk-1977-0052.ch012


function [Poder] = ModelPower(X,T,P,E,L,C)

Matriz_X_dados = X;
Matriz_T_scores = T;
Matriz_P_loadings = P;
if ~exist('E');
    E = [1:size(Matriz_X_dados,2)]';
end
vetor_escala = E;
PC_componentes = size(Matriz_P_loadings,1);
N_amostras_treinamento = size(Matriz_X_dados,1);
V_variaveis_modelo = size(Matriz_X_dados,2);
if ~exist('L');
    L = 0.9;
end
Threshold = L;
if ~exist('C');
    C = 1;
end
C_classes_treinamento = C;

% Calcula TxP, X_TxP, Eki2, Eik2, NA1
Matriz_TxP = Matriz_T_scores * Matriz_P_loadings;
Matriz_X_TxP = Matriz_X_dados - Matriz_TxP;
Matriz_Eki2 = Matriz_X_TxP .^ 2;
Matriz_Eik2 = Matriz_Eki2';
NA1_valor = N_amostras_treinamento - PC_componentes - 1;

% Calcula Div, Q, somaSi, multSi, Si
Matriz_Div = Matriz_Eik2 / NA1_valor;
Q_valor = (1 / C_classes_treinamento) * (V_variaveis_modelo) / (V_variaveis_modelo - PC_componentes);
soma_Si = sum(Matriz_Div, 2);
mult_Si = Q_valor * soma_Si;
Matriz_Si = sqrt(mult_Si);

% Calcula Ym, Ym_rep, Xt_Ym_rep, quadSiy, N_1_Siy, Siy
Vetor_Ym = (sum((Matriz_X_dados'), 2)) / N_amostras_treinamento;
Matriz_Ym_rep = repmat(Vetor_Ym, 1, size(Matriz_X_dados', 2));
Matriz_Xt_Ym_rep = Matriz_X_dados' - Matriz_Ym_rep;
Matriz_quadSiy = Matriz_Xt_Ym_rep.^2;
Matriz_N_1_Siy = Matriz_quadSiy / (N_amostras_treinamento - 1);
Matriz_Siy = sqrt(sum(Matriz_N_1_Siy, 2));

% Calcula o Poder estatístico
Poder = 1 - (Matriz_Si ./ Matriz_Siy);

% Plota o gráfico do poder de modelagem
plot(vetor_escala,Poder,'k-','LineWidth',2);
hold on
plot(vetor_escala,Threshold*ones(size(vetor_escala)),'r-','LineWidth',2);
xlabel('Variables');
ylabel('Modeling Power (\psi)');