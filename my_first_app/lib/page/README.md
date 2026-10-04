# Memory Decay Simulation: Monte Carlo Computational Cognitive Science

โปรเจกต์นี้เป็นการจำลองการถดถอยของความทรงจำ (Memory Decay) ด้วยแบบจำลอง Exponential Decay ร่วมกับ Gaussian Noise โดยใช้ Monte Carlo Simulation เพื่อศึกษาผลของอัตราการลืม (`decay_rate`) และความไม่แน่นอนจากการดึงข้อมูลความทรงจำตลอดช่วงเวลา 72 time steps

การทดลองพัฒนาบน **Python และ Google Colab** และใช้ข้อมูลสังเคราะห์ทั้งหมด จึงไม่มีการใช้ข้อมูลส่วนบุคคลหรือข้อมูลจากผู้เข้าร่วมการทดลองจริง

---

## 1. Research Questions

### Research Question 1
**อัตราการถดถอยของความทรงจำ (`d`) ส่งผลต่อเส้นทางการลดลงของระดับความจำ (Retention Trajectory) ตลอดช่วงเวลา 72 ชั่วโมงอย่างไร และความแตกต่างของอัตราการลืมส่งผลต่อ Half-life ของความทรงจำอย่างไร?**

การทดลองเปรียบเทียบค่า `decay_rate` จำนวน 4 ระดับ:
*   `d = 0.03`
*   `d = 0.08`
*   `d = 0.15`
*   `d = 0.25`

เพื่อศึกษาว่าเมื่ออัตราการถดถอยเพิ่มขึ้น ระดับความจำจะลดลงเร็วขึ้นเพียงใด

### Research Question 2
**Stochastic Retrieval Noise (`σ = 0.04`) สร้างความไม่แน่นอนทางสถิติในแต่ละช่วงเวลาอย่างไร และเมื่อทำการจำลองซ้ำจำนวนมาก ผลลัพธ์จะเข้าใกล้ค่าเฉลี่ยของแบบจำลองมากขึ้นหรือไม่?**

คำถามนี้ตรวจสอบผ่าน:
*   Mean Retention
*   Standard Deviation (SD)
*   Standard Error of the Mean (SEM)
*   95% Confidence Interval (CI)
*   Monte Carlo Trials จำนวน 1,000 รอบ

---

## 2. Model

แบบจำลองหลักใช้ Exponential Decay:
\[R(t) = R_0 \times \exp(-d \times t)\]

จากนั้นเพิ่ม Gaussian Noise:
\[R_{\text{trial}}(t) = R(t) + \varepsilon\]

โดยกำหนดคุณสมบัติและข้อจำกัดดังนี้:
*   ε ~ N(0, σ²)
*   σ = 0.04

สุดท้ายใช้ `np.clip()` เพื่อจำกัดค่า Retention ให้อยู่ในช่วง:
\[0.0 \le R(t) \le 1.0\]
*(หรือคิดเป็น 0% ถึง 100%)*

---

## 3. Experimental Configuration

ค่าหลักของการทดลองมีดังนี้:

| Parameter | Value | Description |
| :--- | :--- | :--- |
| `SEED` | `67011212035` | Random Seed สำหรับ Reproducibility |
| `initial_retention` | `1.0` | ค่า Retention เชิงทฤษฎีเริ่มต้น |
| `time_steps` | `72` | จำนวน time steps |
| `Time range` | `0–71` | ชั่วโมงที่จำลอง |
| `n_trials` | `1000` | จำนวน Monte Carlo trials ต่อค่า `d` |
| `noise_std` | `0.04` | Standard deviation ของ Gaussian Noise |
| `decay_rates` | `[0.03, 0.08, 0.15, 0.25]` | ระดับอัตราการลืม |

### Reproducibility
Random Seed ถูกกำหนดเป็น:
```python
SEED = 67011212035 % (2**32)
np.random.seed(SEED)
```
และใน Cell 3 มีการ reset seed ก่อนจำลองแต่ละค่า `d` เพื่อให้การเปรียบเทียบระหว่างพารามิเตอร์สามารถทำซ้ำได้

>**หมายเหตุ:** Seed ช่วยควบคุมกระบวนการสุ่ม แต่ผลลัพธ์อาจขึ้นกับเวอร์ชันของไลบรารีและ environment ด้วย ดังนั้นควรใช้ environment ที่ใกล้เคียงกันเมื่อทำการ reproduce ผลลัพธ์

---

## 4. Project Structure

```text
project/
│
├── README.md                     # ไฟล์อธิบายรายละเอียดโปรเจกต์
├── memory_decay_simulation.ipynb # Jupyter Notebook หลักสำหรับการทดลอง
└── simulation_summary.csv        # ไฟล์สรุปผลข้อมูลทางสถิติอนุกรมเวลา
```

### รายละเอียดไฟล์
*   **`README.md`**: ไฟล์เอกสารนี้ ใช้อธิบาย Research Questions, Model, Experimental Setup, วิธีติดตั้งและใช้งาน, Dependencies, โครงสร้างไฟล์ และผลลัพธ์ที่ได้
*   **`memory_decay_simulation.ipynb`**: Jupyter Notebook หลักที่ประกอบด้วย Cell 1–5 สำหรับดำเนินการทดลองทั้งหมด
*   **`simulation_summary.csv`**: ไฟล์ข้อมูลผลลัพธ์ที่ Export จาก Cell 4 โดยเก็บสถิติอนุกรมเวลาของทุกค่า `decay_rate` ซึ่งประกอบด้วยคอลัมน์:
    *   `decay_rate`
    *   `time_step_hour`
    *   `mean_retention`
    *   `std_dev`
    *   `ci_95_half_width`
    *   `lower_ci`
    *   `upper_ci`

---

## 5. Notebook Cells

### Cell 1 — Environment Setup & Seed Configuration
*   **หน้าที่**: Import Python libraries, กำหนด Random Seed และตั้งค่ารูปแบบกราฟ
*   **Libraries ที่ใช้**:
    ```python
    import numpy as np
    import pandas as pd
    import matplotlib.pyplot as plt
    import sns as sns
    ```
*   **ผลลัพธ์**:
    ```text
    Environment Initialized.
    Random Seed set to: 2616279179
    ```

### Cell 2 — Memory Decay Simulation
*   **หน้าที่**: สร้างฟังก์ชัน `simulate_memory_decay()` เพื่อคำนวณตัวแปรต่างๆ ดังนี้:
    1. สร้าง time vector
    2. คำนวณ Exponential Decay
    3. สร้าง Gaussian Noise
    4. เพิ่ม Noise ให้กับ Retention
    5. Clip ค่าให้อยู่ใน `[0, 1]`
*   **ผลลัพธ์**: คืนค่า `time` และ `trials_data` (ขนาด 1000 × 72)

### Cell 3 — Multi-Parameter Simulation
*   **หน้าที่**: Cell นี้รันการทดลองทั้ง 4 ค่า (`decay_rates = [0.03, 0.08, 0.15, 0.25]`) โดยสำหรับแต่ละค่า `d` จะทำหน้าที่:
    1. จำลอง 1,000 trials
    2. คำนวณ Mean, SD, SEM และ 95% CI
    3. บันทึกข้อมูลลงผลลัพธ์และเตรียมโครงสร้างเพื่อส่งออกไฟล์ CSV
*   **สูตรคำนวณ**:
    *   \(\text{SEM} = \frac{\text{SD}}{\sqrt{N}}\)
    *   95% CI Half-Width = 1.96 × SEM
*   **ตัวแปรผลลัพธ์หลัก**: `results`, `df_all_time_series`, `df_sample`

### Cell 4 — Analytics & CSV Export
*   **หน้าที่**: ตรวจสอบและสรุปผลข้อมูล
    *   *Sample Data*: แสดงตัวอย่าง Raw Simulation Data จำนวน 10 แถวแรก
    *   *Milestone Analysis*: เปรียบเทียบ Mean Retention ณ `milestones = [12, 24, 48, 71]` โดยสร้าง `pivot_summary`
    *   *CSV Export*: บันทึกผลลัพธ์ทั้งหมดลงไฟล์
        ```python
        df_all_time_series.to_csv('simulation_summary.csv', index=False)
        ```

### Cell 5 — Visualization & Uncertainty Analysis
*   **หน้าที่**: สร้างกราฟเปรียบเทียบ Memory Decay ของทั้ง 4 ค่า `d` ในช่วงเวลา `0–71`
*   **องค์ประกอบของกราฟ**:
    *   X-axis: Time Elapsed
    *   Y-axis: Memory Retention Score
    *   เส้นหลัก: Mean Retention (ใช้ `plt.plot()`)
    *   แถบแรเงา: 95% Confidence Interval (ใช้ `plt.fill_between()`)

---

## 6. Dependencies

โปรเจกต์ต้องใช้ Python 3.10 หรือใหม่กว่า โดยมีเวอร์ชันแนะนำดังนี้:
*   `numpy >= 1.23.5`
*   `pandas >= 1.5.3`
*   `matplotlib >= 3.7.1`
*   `seaborn >= 0.12.2`

สามารถติดตั้งทั้งหมดได้ผ่านคำสั่งคำสั่งเดียว:
```bash
pip install numpy pandas matplotlib seaborn
```
*(หากใช้งานบน Google Colab โดยทั่วไปสามารถเรียกใช้งานได้ทันทีโดยไม่ต้องติดตั้งเพิ่มเติม)*

---

## 7. How to Run

### วิธีที่ 1: Google Colab
1. เปิดไฟล์ `memory_decay_simulation.ipynb` บน Google Colab
2. เลือกเมนู **Runtime → Run all**
3. รอให้ Cell 1–5 ทำงานตามลำดับและตรวจสอบผลลัพธ์
4. ระบบจะส่งออกไฟล์ `simulation_summary.csv` และสร้างกราฟใน Cell 5 ทันที

### วิธีที่ 2: Jupyter Notebook
1. ติดตั้ง Dependencies ในสภาพแวดล้อมของคุณ
2. เปิดไฟล์โน้ตบุ๊กและสั่งรันเซลล์เรียงตามลำดับจากบนลงล่าง:
   \[\text{Cell 1} \rightarrow \text{Cell 2} \rightarrow \text{Cell 3} \rightarrow \text{Cell 4} \rightarrow \text{Cell 5}\]
   *(เนื่องจากมีการใช้ตัวแปรต่อเนื่องกัน ห้ามสลับเซลล์การทำงาน)*

---

## 8. Expected Output

เมื่อรันการทดลองเสร็จสิ้น จะได้รับผลลัพธ์หลัก 3 ส่วน:

### 1. Raw Sample Data
ข้อมูลตัวอย่างดิบจาก Monte Carlo Trials ประกอบด้วยหัวข้อ: `decay_rate`, `trial_id`, `time_step_hour`, และ `retention_score`

### 2. Summary Statistics
ตารางแสดงแนวโน้ม Mean Retention ยิ่งค่า `d` สูงขึ้น ระดับการจดจำจะยิ่งลดลงเร็วขึ้นอย่างเห็นได้ชัด:

| Decay Rate | 12h | 24h | 48h | 71h |
| :--- | :---: | :---: | :---: | :---: |
| **0.03** | 69.81% | 48.78% | 23.72% | 12.11% |
| **0.08** | 38.33% | 14.76% | 2.93% | 1.96% |
| **0.15** | 16.57% | 3.39% | 1.68% | 1.78% |
| **0.25** | 5.24% | 1.74% | 1.64% | 1.78% |

### 3. Memory Decay Plot
กราฟเปรียบเทียบการลดลงของความทรงจำในแต่ละอัตราการลืม พร้อมแสดงแถบพื้นที่ความเชื่อมั่น 95% CI ตลอดช่วงเวลา 72 ชั่วโมง

---

## 9. Interpretation

ผลจากการคำนวณสรุปพฤติกรรมของแบบจำลองได้ดังนี้:
*   `d = 0.03` → Memory Decay ช้าที่สุด
*   `d = 0.08` → Memory Decay เร็วขึ้น
*   `d = 0.15` → Memory Decay เร็วมาก
*   `d = 0.25` → Memory Decay เร็วที่สุด

ผลลัพธ์ยืนยันความสัมพันธ์ว่าระดับ Retention จะผกผันแปรตามสัดส่วนของ `decay_rate` อย่างไรก็ตาม โปรดจำไว้ว่าข้อมูลนี้ได้มาจาก **Computational Model** เพื่อการศึกษาเชิงทฤษฎีเท่านั้น ไม่ใช่ผลทดลองจริงในมนุษย์

---

## 10. Important Modeling Note

แบบจำลองนี้มีการประมวลผลคำสั่ง:
```python
np.clip(trials_data, 0.0, 1.0)
```
ซึ่งจะทำงานหลังจากสิ้นสุดขั้นตอนการเพิ่ม Gaussian Noise ส่งผลให้เมื่อค่าจากสมการ Exponential Decay ลดลงใกล้ศูนย์ ค่า Noise ทางสถิติที่เป็นฝั่งลบจะถูกตัดทิ้ง (กลายเป็น `0`) ในขณะที่ Noise ฝั่งบวกยังคงได้รับการสุ่มอยู่ เหตุการณ์นี้ทำให้ค่าเฉลี่ยในช่วงท้ายของการทดลองดูเหมือนจะคงตัวและไม่ลดลงไปจนเป็นศูนย์สัมบูรณ์
