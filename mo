import math
from flask import Flask, render_template_string, request, jsonify

app = Flask(__name__)

# Global variables to store calculation results
calculation_results = {
    'mosfet_output': '',
    'not_details': '',
    'nand_details': '',
    'nor_details': '',
    'globals': {}
}

HTML_TEMPLATE = '''
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>MOSFET + K-Map + NOT/NAND/NOR/POS Circuit</title>
<style>
    body {
        background: #f5f5f5;
        color: #222;
        font-family: Arial, sans-serif;
        padding: 20px;
    }
    h1, h2, h3 {
        color: #333;
        border-right: 4px solid #0077cc;
        padding-right: 10px;
    }
    .container {
        max-width: 1200px;
        margin: 0 auto;
        background: white;
        padding: 20px;
        border-radius: 8px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }
    .form-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: 15px;
        margin: 20px 0;
    }
    .form-group {
        display: flex;
        flex-direction: column;
    }
    label {
        font-weight: bold;
        margin-bottom: 5px;
    }
    input, select {
        padding: 8px;
        background: #fff;
        border: 1px solid #0077cc;
        color: #222;
        border-radius: 4px;
    }
    button {
        margin-top: 10px;
        padding: 10px 20px;
        cursor: pointer;
        background: #0077cc;
        color: white;
        border: none;
        border-radius: 4px;
        font-size: 16px;
    }
    button:hover {
        background: #005fa3;
    }
    .delay-buttons {
        margin-top: 20px;
        display: flex;
        gap: 10px;
        flex-wrap: wrap;
    }
    .delay-buttons button {
        background: #666;
    }
    .delay-buttons button:hover {
        background: #444;
    }
    .output-area {
        margin-top: 20px;
        background: #f9f9f9;
        padding: 15px;
        border-radius: 6px;
        border: 1px solid #ddd;
        white-space: pre-wrap;
        font-family: monospace;
        max-height: 500px;
        overflow-y: auto;
    }
    .delay-boxes {
        margin-top: 20px;
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        gap: 15px;
    }
    .delay-box {
        padding: 15px;
        border-radius: 6px;
        border: 1px solid #333;
        white-space: pre-wrap;
        font-family: monospace;
        display: none;
    }
    #notBox { background: #e0f0ff; }
    #nandBox { background: #e0ffe0; }
    #norBox { background: #ffe0e0; }
    .loading {
        display: none;
        text-align: center;
        color: #0077cc;
        margin: 10px 0;
    }
</style>
</head>
<body>

<div class="container">
    <h1>MOSFET Parameters + K-Map + NOT/NAND/NOR/POS Circuit</h1>

    <h2>1) MOSFET Parameters</h2>

    <form id="mosfetForm">
        <div class="form-grid">
            <div class="form-group">
                <label>Wn (μm):</label>
                <input type="number" step="any" name="Wn" id="Wn" required>
            </div>
            <div class="form-group">
                <label>Ln (μm):</label>
                <input type="number" step="any" name="Ln" id="Ln" required>
            </div>
            <div class="form-group">
                <label>Wp (μm):</label>
                <input type="number" step="any" name="Wp" id="Wp" required>
            </div>
            <div class="form-group">
                <label>Lp (μm):</label>
                <input type="number" step="any" name="Lp" id="Lp" required>
            </div>
            <div class="form-group">
                <label>LDn (μm):</label>
                <input type="number" step="any" name="LDn" id="LDn" required>
            </div>
            <div class="form-group">
                <label>LDp (μm):</label>
                <input type="number" step="any" name="LDp" id="LDp" required>
            </div>
            <div class="form-group">
                <label>un (μm):</label>
                <input type="number" step="any" name="un" id="un" required>
            </div>
            <div class="form-group">
                <label>up (μm):</label>
                <input type="number" step="any" name="up" id="up" required>
            </div>
            <div class="form-group">
                <label>Tox (nm):</label>
                <input type="number" step="any" name="Tox" id="Tox" required>
            </div>
            <div class="form-group">
                <label>K1n (NMOS):</label>
                <input type="number" step="any" name="K1n" id="K1n" required>
            </div>
            <div class="form-group">
                <label>K1p (PMOS):</label>
                <input type="number" step="any" name="K1p" id="K1p" required>
            </div>
            <div class="form-group">
                <label>Vthop (PMOS):</label>
                <input type="number" step="any" name="Vthop" id="Vthop" required>
            </div>
            <div class="form-group">
                <label>Vthon (NMOS):</label>
                <input type="number" step="any" name="Vthon" id="Vthon" required>
            </div>
            <div class="form-group">
                <label>VBS (Bulk-Source Voltage):</label>
                <input type="number" step="any" name="VSB" id="VSB" required>
            </div>
            <div class="form-group">
                <label>Cgdop (PMOS):</label>
                <input type="number" step="any" name="Cgdop" id="Cgdop" required>
            </div>
            <div class="form-group">
                <label>Cgdon (NMOS):</label>
                <input type="number" step="any" name="Cgdon" id="Cgdon" required>
            </div>
            <div class="form-group">
                <label>Cjswn:</label>
                <input type="number" step="any" name="Cjswn" id="Cjswn" required>
            </div>
            <div class="form-group">
                <label>Cjswp:</label>
                <input type="number" step="any" name="Cjswp" id="Cjswp" required>
            </div>
            <div class="form-group">
                <label>Cgn:</label>
                <input type="number" step="any" name="Cgn" id="Cgn" required>
            </div>
            <div class="form-group">
                <label>Cgp:</label>
                <input type="number" step="any" name="Cgp" id="Cgp" required>
            </div>
            <div class="form-group">
                <label>Cjn:</label>
                <input type="number" step="any" name="Cjn" id="Cjn" required>
            </div>
            <div class="form-group">
                <label>Cjb:</label>
                <input type="number" step="any" name="Cjb" id="Cjb" required>
            </div>
            <div class="form-group">
                <label>VDD (V):</label>
                <input type="number" step="any" name="VDD" id="VDD" required>
            </div>
            <div class="form-group">
                <label>n (FOR NAND/NOR):</label>
                <input type="number" step="any" name="nVal" id="nVal" required>
            </div>
            <div class="form-group">
                <label>geat:</label>
                <input type="number" step="any" name="geatVal" id="geatVal" required>
            </div>
        </div>

        <button type="submit">Calculate MOSFET</button>
    </form>

    <div class="loading" id="loading">جاري الحساب...</div>

    <div class="output-area" id="mosfetOutput"></div>

    <div class="delay-buttons">
        <button onclick="showNOT()">Show NOT Time Delay</button>
        <button onclick="showNAND()">Show NAND Time Delay</button>
        <button onclick="showNOR()">Show NOR Time Delay</button>
    </div>

    <div class="delay-boxes">
        <div id="notBox" class="delay-box"></div>
        <div id="nandBox" class="delay-box"></div>
        <div id="norBox" class="delay-box"></div>
    </div>
</div>

<script>
document.getElementById('mosfetForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const formData = new FormData(e.target);
    const data = Object.fromEntries(formData.entries());
    
    document.getElementById('loading').style.display = 'block';
    document.getElementById('mosfetOutput').textContent = '';
    
    try {
        const response = await fetch('/calculate', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data)
        });
        
        const result = await response.json();
        
        if (result.error) {
            document.getElementById('mosfetOutput').textContent = 'خطأ: ' + result.error;
        } else {
            document.getElementById('mosfetOutput').textContent = result.output;
        }
    } catch (error) {
        document.getElementById('mosfetOutput').textContent = 'خطأ في الاتصال: ' + error.message;
    } finally {
        document.getElementById('loading').style.display = 'none';
    }
});

function hideAllDelayBoxes() {
    document.getElementById('notBox').style.display = 'none';
    document.getElementById('nandBox').style.display = 'none';
    document.getElementById('norBox').style.display = 'none';
}

async function showNOT() {
    hideAllDelayBoxes();
    const response = await fetch('/get_details/not');
    const result = await response.json();
    const box = document.getElementById('notBox');
    box.style.display = 'block';
    box.textContent = result.details || 'لا توجد بيانات. قم بحساب MOSFET أولاً.';
}

async function showNAND() {
    hideAllDelayBoxes();
    const response = await fetch('/get_details/nand');
    const result = await response.json();
    const box = document.getElementById('nandBox');
    box.style.display = 'block';
    box.textContent = result.details || 'لا توجد بيانات. قم بحساب MOSFET أولاً.';
}

async function showNOR() {
    hideAllDelayBoxes();
    const response = await fetch('/get_details/nor');
    const result = await response.json();
    const box = document.getElementById('norBox');
    box.style.display = 'block';
    box.textContent = result.details || 'لا توجد بيانات. قم بحساب MOSFET أولاً.';
}
</script>

</body>
</html>
'''

@app.route('/')
def index():
    return render_template_string(HTML_TEMPLATE)

@app.route('/calculate', methods=['POST'])
def calculate():
    try:
        data = request.json
        
        Eox = 0.34
        Esi = 1
        ni = 1.45e10
        Vt = 0.025875
        q = 1.6e-19
        
        Wn = float(data['Wn'])
        Ln = float(data['Ln'])
        Wp = float(data['Wp'])
        Lp = float(data['Lp'])
        LDn = float(data['LDn'])
        LDp = float(data['LDp'])
        un = float(data['un'])
        up = float(data['up'])
        Tox = float(data['Tox'])
        K1n = float(data['K1n'])
        K1p = float(data['K1p'])
        Vthop = float(data['Vthop'])
        Vthon = float(data['Vthon'])
        VBS = float(data['VSB'])
        Cgdop = float(data['Cgdop'])
        Cgdon = float(data['Cgdon'])
        Cjswn = float(data['Cjswn'])
        Cjswp = float(data['Cjswp'])
        Cgn = float(data['Cgn'])
        Cgp = float(data['Cgp'])
        Cjn = float(data['Cjn'])
        Cjb = float(data['Cjb'])
        VDD = float(data['VDD'])
        nInput = float(data['nVal'])
        geatInput = float(data['geatVal'])
        
        Cox = (Eox / Tox) * 1e-10
        Kn = (un * Cox * Wn / Ln) * 100
        Kp = (up * Cox * Wp / Lp) * 100
        
        NBn = (math.pow(K1n * Cox, 2)) / (2.0 * q * Esi) * 1e4
        NBp = (math.pow(K1p * Cox, 2)) / (2.0 * q * Esi) * 1e4
        
        psi_on = 2.0 * Vt * math.log(NBn / ni)
        psi_op = 2.0 * Vt * math.log(NBp / ni)
        
        Vthn = Vthon
        sqrt_sum = math.sqrt(psi_op + VBS)
        sqrt_psi = math.sqrt(psi_op)
        delta = sqrt_sum - sqrt_psi
        Vthp = Vthop + K1p * delta
        
        VFBn = Vthon - psi_on - K1n * math.sqrt(psi_on)
        VFBp = Vthop - psi_op - K1p * math.sqrt(psi_op)
        
        Cgbnc = Wn * Ln * Cox * 1e-12 / math.sqrt(1 + 4 * abs(VFBn) / (K1n*K1n))
        Cgbpc = Wp * Lp * Cox * 1e-12 / math.sqrt(1 + 4 * abs(VFBp) / (K1p*K1p))
        
        CgdnC = Cgdon * Wn * 1e-6
        Cgsnc = CgdnC
        Cdbnc = Cjn * Wn * LDn * 1e-12 + Cjswn * 2 * (Wn + LDn) * 1e-6
        
        Cgdpc = Cgdop * Wp * 1e-6
        Cgspc = Cgdpc
        Cdbbc = Cjb * Wp * LDp * 1e-12 + Cjswp * 2 * (Wp + LDp) * 1e-6
        
        Cgdnt = CgdnC + ((Wn * Ln) / 2) * Cox * 1e-12
        Cgdpt = Cgdpc + ((Wp * Lp) / 2) * Cox * 1e-12
        
        Cdbpt = Cdbbc + ((Wp * Lp) / 2.0) * Cgp * 1e-12
        Cdbnt = Cdbnc + ((Wn * Ln) / 2.0) * Cgn * 1e-12
        
        Vinss = ((math.sqrt(Kp) * (VDD - Vthp)) + (math.sqrt(Kn) * Vthn)) / (math.sqrt(Kp) + math.sqrt(Kn))
        
        if VBS != 0:
            C_load_plus = 2 * (Cgdpt + CgdnC + Cdbpt) + Cdbnc + Cgbnc
            C_load_minus = 2 * (Cgdpc + Cgdnt + Cdbbc) + Cdbnt + Cgbpc
        else:
            C_load_plus = 2 * (Cgdpt + CgdnC) + Cdbpt + Cdbnc + Cgbnc
            C_load_minus = 2 * (Cgdpc + Cgdnt) + Cdbbc + Cdbnt + Cgbpc
        
        t_critical_plus_NOT = (2 * C_load_plus * Vthp * 1e6) / (Kp * math.pow(VDD - Vthp, 2))
        t_critical_minus_NOT = (2 * C_load_minus * Vthn * 1e6) / (Kn * math.pow(VDD - Vthn, 2))
        
        term1_NOT = (VDD - Vthn) / (2 * Vthn)
        term2_NOT = (VDD - Vthp) / (2 * Vthp)
        
        tau_plus_NOT = float('nan')
        tau_minus_NOT = float('nan')
        
        if term1_NOT - 1 > 0 and term2_NOT - 1 > 0:
            log_term1 = math.log(term1_NOT - 1)
            log_term2 = math.log(term2_NOT - 1)
            tau_plus_NOT = t_critical_plus_NOT * (1 + term2_NOT * log_term2)
            tau_minus_NOT = t_critical_minus_NOT * (1 + term1_NOT * log_term1)
        
        terma = Wp * (Lp + 2 * LDp)
        termb = Wn * (Ln + 2 * LDn)
        totalArea_NOT = terma + termb
        MaxPower_NOT = ((Kn / 2) * VDD * math.pow((Vinss - Vthn), 2))
        
        nNAND = nInput
        geatNAND = geatInput
        termy = Wp * (Lp + 2 * LDp)
        termx = Wn * (Ln + 2 * LDn)
        totalArea_NAND = nNAND * (termy + termx)
        MaxPower_NAND = geatNAND * ((Kn / 2) * VDD * math.pow((Vinss - Vthn), 2))
        
        a_NAND = VDD - Vthn
        x1_NAND = a_NAND * (1.0 - math.sqrt(1.0 / nNAND))
        x2_NAND = a_NAND * (1.0 - math.sqrt((1.0 / nNAND) * (1.0 + math.pow(1.0 - (Vthn / a_NAND), 2) * (nNAND - 1))))
        
        Cload_plus_ND = nNAND * Cgdpt + nNAND * Cdbpt + nNAND * Cgbnc + (Cdbnc / nNAND) + nNAND * CgdnC
        Cload_minus_ND = nNAND * Cgdpc + nNAND * Cdbbc + (Cdbnt / nNAND) + nNAND * Cgdnt
        
        I_critical_plus_ND = (2.0 * Cload_plus_ND * Vthp * 1e6) / (Kp * math.pow(VDD - Vthp, 2))
        t_critical_minus_ND_base = (2.0 * Cload_minus_ND * Vthn * 1e6) / (Kn * math.pow(VDD - Vthn, 2))
        t_critical_minus_ND = nNAND * t_critical_minus_ND_base
        
        Z_ND_minus = float('nan')
        ZND_plus = float('nan')
        
        if x1_NAND > 0 and x2_NAND > 0:
            Z_ND_minus = ((nNAND * Cload_minus_ND * 1e6) / ((math.pow(nNAND, 2) - 1) * Kn * a_NAND)) * (
                (nNAND - 1) * math.log((a_NAND - x2_NAND / 2) / (a_NAND - x1_NAND / 2)) +
                2 * math.log((1 - (x2_NAND / a_NAND) * (nNAND / (nNAND - 1))) / (1 - (nNAND / (nNAND - 1)) * (x1_NAND / a_NAND))) +
                (nNAND + 1) * math.log(x1_NAND / x2_NAND)
            ) + t_critical_minus_ND
            ZND_plus = I_critical_plus_ND * (1.0 + (VDD - Vthp) / (2.0 * Vthp) * math.log((VDD - Vthp) / (2.0 * Vthp) - 1.0))
        
        nNOR = nInput
        geatNOR = geatInput
        termZ = Wp * (Lp + 2 * LDp)
        termW = Wn * (Ln + 2 * LDn)
        totalArea_NOR = nNOR * (termZ + termW)
        MaxPower_NOR = geatNOR * ((Kn / 2) * VDD * math.pow((Vinss - Vthn), 2))
        
        alpha = VDD - Vthp
        X1_NR = alpha * (1.0 - math.sqrt(1.0 / nNOR))
        X2_NR = alpha * (1.0 - math.sqrt((1.0 / nNOR) * (1.0 + math.pow(1.0 - (Vthp / alpha), 2) * (nNOR - 1))))
        
        Cload_plus_NR = nNOR * Cgdpt + (Cdbpt / nNOR) + nNOR * CgdnC + nNOR * Cdbnc
        Cload_minus_NR = nNOR * Cgdpc + (Cdbbc / nNOR) + nNOR * Cgbpc + nNOR * Cgdnt + nNOR * Cdbnt
        
        I_critical_plus_NR = (2 * Cload_plus_NR * Vthp * 1e6) / (Kp * math.pow(VDD - Vthp, 2))
        I_critical_minus_NR = (2 * Cload_minus_NR * Vthn * 1e6) / (Kn * math.pow(VDD - Vthn, 2))
        
        Z_NR_minus = float('nan')
        ZNR_plus = float('nan')
        
        if X1_NR > 0 and X2_NR > 0:
            Z_NR_minus = I_critical_minus_NR * (1.0 + (VDD - Vthn) / (2.0 * Vthn) * math.log((VDD - Vthn) / (2.0 * Vthn) - 1.0))
            ZNR_plus = (nNOR * Cload_plus_NR * 1e6) / ((nNOR*nNOR - 1) * Kp * alpha) * (
                (nNOR - 1) * math.log((alpha - X2_NR / 2.0) / (alpha - X1_NR / 2.0)) +
                2.0 * math.log((1.0 - (nNOR / (nNOR - 1.0) * (X2_NR / alpha))) / (1.0 - (nNOR / (nNOR - 1.0) * (X1_NR / alpha)))) +
                (nNOR + 1) * math.log(X1_NR / X2_NR)
            ) + I_critical_plus_NR
        
        out = '--- output ---\n'
        out += f'Cox  {Cox:.10f} F/m^2\n'
        out += f'Kn = {Kn:.6f} A/V^2\n'
        out += f'Kp = {Kp:.6f} A/V^2\n'
        out += f'NBn = {NBn:.3e} cm^-3\n'
        out += f'NBp = {NBp:.3e} cm^-3\n'
        out += f'psi_on = {psi_on} V\n'
        out += f'psi_op = {psi_op} V\n'
        out += f'Vthn = {Vthn} V\n'
        out += f'Vthp = {Vthp:.6f} V\n\n'
        out += '--- N MOSFET CAP Calculations ---\n'
        out += f'Cgbnc = {Cgbnc:.3e} F\n'
        out += f'Cgsnc = {Cgsnc:.3e} F\n'
        out += f'Cdbnc = {Cdbnc:.3e} F\n'
        out += f'Cgdnt = {Cgdnt:.3e} F\n'
        out += f'Cdbnt = {Cdbnt:.3e} F\n\n'
        out += '--- P MOSFET CAP Calculations ---\n'
        out += f'Cgspc = {Cgspc:.3e} F\n'
        out += f'Cgbpc = {Cgbpc:.3e} F\n'
        out += f'Cdbbc = {Cdbbc:.3e} F\n'
        out += f'Cgdpt = {Cgdpt:.3e} F\n'
        out += f'Cdbpt = {Cdbpt:.3e} F\n'
        
        not_details = '--- NOT Time delay Calculations ---\n'
        not_details += f'total Area NOT = {totalArea_NOT:.2f}\n'
        not_details += f'VINSS = {Vinss:.4e}\n'
        not_details += f'MAX POWER NOT = {MaxPower_NOT:.2f} µW\n'
        not_details += f'C_load_+ = {C_load_plus:.3e} F\n'
        not_details += f'C_load_- = {C_load_minus:.3e} F\n'
        not_details += f't_critical+ = {t_critical_plus_NOT:.3e}\n'
        not_details += f't_critical- = {t_critical_minus_NOT:.3e}\n'
        if not math.isnan(tau_plus_NOT) and not math.isnan(tau_minus_NOT):
            not_details += f'tau_j+ = {tau_plus_NOT:.3e}\n'
            not_details += f'tau_j- = {tau_minus_NOT:.3e}\n'
        else:
            not_details += 'tau terms invalid for log() — skipped\n'
        
        nand_details = '--- NAND Time delay Calculations ---\n'
        nand_details += f'total Area NAND = {totalArea_NAND:.2f}\n'
        nand_details += f'VINSS = {Vinss:.4e}\n'
        nand_details += f'MAX POWER NAND = {MaxPower_NAND:.2f}\n'
        nand_details += f'a = {a_NAND:.4e} V\n'
        nand_details += f'x1 = {x1_NAND:.4e}\n'
        nand_details += f'x2 = {x2_NAND:.5f}\n'
        nand_details += f'Cload_plus_ND = {Cload_plus_ND:.3e} F\n'
        nand_details += f'Cload_minus_ND = {Cload_minus_ND:.3e} F\n'
        nand_details += f'I_critical_plus = {I_critical_plus_ND:.3e} A\n'
        nand_details += f't_critical_minus = {t_critical_minus_ND_base:.3e} s\n'
        nand_details += f't_critical_minus_ND = {t_critical_minus_ND:.3e} s\n'
        if not math.isnan(Z_ND_minus) and not math.isnan(ZND_plus):
            nand_details += f'Z_ND_minus = {Z_ND_minus:.3e} s\n'
            nand_details += f'ZND_plus = {ZND_plus:.3e} s\n'
        else:
            nand_details += 'ZND terms invalid (log) — skipped\n'
        
        nor_details = '--- NOR Time delay Calculations ---\n'
        nor_details += f'total Area NOR = {totalArea_NOR:.2f}\n'
        nor_details += f'VINSS = {Vinss:.4e}\n'
        nor_details += f'MAX POWER NOR = {MaxPower_NOR:.2f}\n'
        nor_details += f'alpha = {alpha:.4e} V\n'
        nor_details += f'x1 = {X1_NR:.4e}\n'
        nor_details += f'x2 = {X2_NR:.5f}\n'
        nor_details += f'Cload_plus_NR = {Cload_plus_NR:.3e} F\n'
        nor_details += f'Cload_minus_NR = {Cload_minus_NR:.3e} F\n'
        nor_details += f'I_critical_plus_NR = {I_critical_plus_NR:.3e} A\n'
        nor_details += f'I_critical_minus_NR = {I_critical_minus_NR:.3e} A\n'
        if not math.isnan(Z_NR_minus) and not math.isnan(ZNR_plus):
            nor_details += f'Z_NR_minus = {Z_NR_minus:.3e} s\n'
            nor_details += f'ZNR_plus = {ZNR_plus:.3e} s\n'
        else:
            nor_details += 'ZNR terms invalid (log) — skipped\n'
        
        calculation_results['mosfet_output'] = out
        calculation_results['not_details'] = not_details
        calculation_results['nand_details'] = nand_details
        calculation_results['nor_details'] = nor_details
        
        return jsonify({'output': out})
    
    except Exception as e:
        return jsonify({'error': str(e)})

@app.route('/get_details/<detail_type>')
def get_details(detail_type):
    if detail_type == 'not':
        return jsonify({'details': calculation_results.get('not_details', '')})
    elif detail_type == 'nand':
        return jsonify({'details': calculation_results.get('nand_details', '')})
    elif detail_type == 'nor':
        return jsonify({'details': calculation_results.get('nor_details', '')})
    return jsonify({'details': ''})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
