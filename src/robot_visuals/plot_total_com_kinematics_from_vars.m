function plot_total_com_kinematics_from_vars(num_vars, varargin)

[n, N] = size(num_vars.variables.q);
t = linspace(0, (N-1) * num_vars.parameters.dt, N);

% Position
subplot(2, 3, 1)
hold on;
plot(t, num_vars.functions.Pcomtotal(1, :), varargin{:});
ylabel("$P_{{\rm COM Total}, x}$", 'Interpreter', 'latex');
grid;

subplot(2, 3, 4)
hold on;
plot(t, num_vars.functions.Pcomtotal(2, :), varargin{:});
ylabel("$P_{{\rm COM Total}, y}$", 'Interpreter', 'latex');
grid;

xlabel("$t$ [s]", 'Interpreter', 'latex');

% Velocity
num_vars.functions.numVcomtot = diff(num_vars.functions.Pcomtotal, 1, 2) ./ num_vars.parameters.dt;
NnumV = size(num_vars.functions.numVcomtot, 2);
subplot(2, 3, 2)
hold on;
plot(t, num_vars.functions.Vcomtotal(1, :), varargin{:});
plot(t(1:NnumV), num_vars.functions.numVcomtot(1, :), varargin{:});
ylabel("$V_{{\rm COM Total}, x}$", 'Interpreter', 'latex');
grid;

subplot(2, 3, 5)
hold on;
plot(t, num_vars.functions.Vcomtotal(2, :), varargin{:});
plot(t(1:NnumV), num_vars.functions.numVcomtot(2, :), varargin{:});
ylabel("$V_{{\rm COM Total}, y}$", 'Interpreter', 'latex');
grid;
    
xlabel("$t$ [s]", 'Interpreter', 'latex');

% Acceleration
num_vars.functions.numAcomtot1 = diff(num_vars.functions.Pcomtotal, 2, 2) ./ num_vars.parameters.dt^2;
NnumA1 = size(num_vars.functions.numAcomtot1, 2);
num_vars.functions.numAcomtot2 = diff(num_vars.functions.Vcomtotal, 1, 2) ./ num_vars.parameters.dt;
NnumA2 = size(num_vars.functions.numAcomtot2, 2);
subplot(2, 3, 3)
hold on;
plot(t, num_vars.functions.Acomtotal(1, :), varargin{:});
plot(t(1:NnumA1), num_vars.functions.numAcomtot1(1, :), varargin{:});
plot(t(1:NnumA2), num_vars.functions.numAcomtot2(1, :), varargin{:});
ylabel("$A_{{\rm COM Total}, x}$", 'Interpreter', 'latex');
grid;

subplot(2, 3, 6)
hold on;
plot(t, num_vars.functions.Acomtotal(2, :), varargin{:});
plot(t(1:NnumA1), num_vars.functions.numAcomtot1(2, 1:NnumA1), varargin{:});
plot(t(1:NnumA2), num_vars.functions.numAcomtot2(2, 1:NnumA2), varargin{:});
ylabel("$A_{{\rm COM Total}, y}$", 'Interpreter', 'latex');
grid;
    
xlabel("$t$ [s]", 'Interpreter', 'latex');

end