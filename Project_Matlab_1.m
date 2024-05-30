%Mari Davide (0296192)
%Progetto controlli automatici 2024

clc         % Pulisce la finestra dei comandi
clear       % Cancella tutte le variabili dalla memoria
close all   % Chiude tutte le figure aperte
%%
s = tf('s'); % Definisce la variabile di Laplace 's' per le funzioni di trasferimento

% Definizione dell'impianto nel dominio di Laplace
P = (1.151*s + 0.1774) / (s * (s^2 + 0.739*s + 0.921)); % Definisce la funzione di trasferimento dell'impianto(noto che ho uno zero)

% Calcolo dei poli della funzione di trasferimento P(s)
[num, den] = tfdata(P); % Estrae il numeratore e il denominatore della funzione di trasferimento
disp("Poli della funzione d'impianto P(s) :");
Poli = roots(den{1}); % Calcola i poli, cioè le radici del denominatore
zeri = roots(num{1}); % Calcola gli zeri, cioè le radici del numeratore

% SPECIFICHE PROGETTO
% errore nullo per riferimenti a rampa
% s% <= 15%
% settling time il più piccolo possibile

% Per ottenere errore nullo per riferimenti a rampa, devo aggiungere un polo(poiche ho uno zero)all'origine nel controllore
% quindi definisco C1 = 1/s. Dall'analisi del luogo delle radici (rlocus)
% vedo che posso spostare i due poli nel semipiano sinistro
% scegliendo il guadagno adatto, in questo caso scelgo 0.00432

C1 = 0.00432 / s; % Definisce il primo controllore con un polo all'origine e guadagno 0.00432
L1 = C1 * P; % Funzione di trasferimento del sistema ad anello aperto (L1)

Wyr1 = minreal(L1 / (1 + L1)); % Funzione di trasferimento ad anello chiuso semplificata

figure(1)
rlocus(L1); % Plotta il luogo delle radici del sistema L1

figure(2)
margin(L1); % Plotta il margine di guadagno e fase del sistema L1

figure(3)
step(Wyr1); % Plotta la risposta al gradino del sistema ad anello chiuso Wyr1

%% Aggiungo un filtro feed-forward
% Aggiungo un filtro in feed-forward per migliorare l'overshoot (s%) e il tempo di assestamento
tau_ff = 0.01; % Definisce la costante di tempo del filtro
Ff = (1 / P)/((1+tau_ff*s)^2); % Definisce il filtro feed-forward Ff
Wyr2 = Wyr1 + minreal(Ff * P / (1 + L1)); % Nuova funzione di trasferimento ad anello chiuso con il filtro aggiunto

%%Funzione di sensività e sensività del controllo 
Wer = 1/(1+L1) %funzione di sensività
WerFf = minreal((1+L1-P*Ff)/(1+L1)) %funzione di sensivita con Ff 

figure(5)
bode(Wer,WerFf)
legend('W_(er)','W_(erFf)')
grid on

Wur = C1/(1+L1) %funzione di sensività
WurFf = minreal((Ff+C1)/(1+L1)) %funzione di sensivita con Ff 

figure(6)
bode(Wur,WurFf)
legend('W_(ur)','W_(urFf)')
grid on

%% Massimo Ritardo Ammissibile
figure(1);
margin(L1); % Plotta di nuovo il margine di guadagno e fase del sistema L1
grid on;

figure(2);
rlocus(L1); % Plotta di nuovo il luogo delle radici del sistema L1
grid on;

figure(3);
step(Wyr2); % Plotta la risposta al gradino del sistema ad anello chiuso Wyr2
grid on;

%% Simulo la risposta del sistema a ciclo chiuso alla rampa:
time = 0:0.1:100; % Definisce il vettore del tempo per la simulazione
y = lsim(Wyr2, time, time); % Simula la risposta del sistema Wyr2 ad un ingresso a rampa

figure(4)
hold on
plot(time, y); % Plotta la risposta del sistema
plot(time, time); % Plotta la rampa di riferimento
hold off
legend('Wyr'); % Aggiunge una legenda al grafico
grid on;











