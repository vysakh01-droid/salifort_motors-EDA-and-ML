# 🧑‍💼 Salifort Motors — Employee Attrition Analysis

<p align="center">
  <img src="dashboard1/dashboard.png" alt="Salifort Motors Attrition Dashboard" width="100%"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Python-3.x-blue?logo=python&logoColor=white" />
  <img src="https://img.shields.io/badge/PostgreSQL-Query%20Analysis-336791?logo=postgresql&logoColor=white" />
  <img src="https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?logo=powerbi&logoColor=black" />
  <img src="https://img.shields.io/badge/Scikit--Learn-ML%20Models-orange?logo=scikit-learn&logoColor=white" />
  <img src="https://img.shields.io/badge/Random%20Forest-98%25%20Accuracy-success" />
</p>

---

## 📌 Business Problem

The HR department at **Salifort Motors** wants to improve employee retention but doesn't know where to start. They collected internal HR data and asked: **what's likely to make an employee leave the company?**

This project answers that question end-to-end — Python EDA, SQL business-rule queries, two predictive ML models, and a Power BI dashboard — to give HR a clear, data-backed action plan.

---

## 🔑 Headline Results

| Metric | Value |
|---|---|
| **Total employees analysed** | 11,991 (post-cleaning) |
| **Attrition rate** | 16.60% |
| **Best model accuracy** | **98.17%** (Random Forest) |
| **Quitter recall** | **91%** — catches 9 of 10 employees who will leave |
| **Top attrition driver** | Low satisfaction score (not salary) |
| **Estimated cost of attrition** | **$171.36M** across salary bands |

---

## 🗂️ Repository Structure

```
salifort-attrition-analysis/
│
├── 📓 notebooks/
│   ├── 01_EDA.ipynb                   # Cleaning + exploratory analysis
│   └── 02_ML_Models.ipynb             # Logistic Regression + Random Forest
│
├── 🗄️ sql/
│   └── salifort_queries.sql           # HR business-rule SQL queries
│
├── 📊 dashboard/
│   ├── salifort_dashboard.pbix
│   └── dashboard.png
│
├── 📁 data/
│   ├── HR_capstone_dataset.csv        # Raw dataset
│   └── capstone.csv                   # Cleaned dataset (used for ML)
│
├── 📈 visuals/                        # All exported chart PNGs
│
├── requirements.txt
└── README.md
```

---

## 📦 Dataset

| Property | Value |
|---|---|
| Raw rows | 14,999 |
| Rows after cleaning (duplicates removed) | 11,991 |
| Columns | 10 |
| Duplicate rows found | 3,008 (20% of data) |
| Missing values | 0 |
| Source | Google Advanced Data Analytics Professional Certificate - Capstone Project |

| Column | Description |
|---|---|
| `satisfaction_level` | Employee satisfaction score (0–1) |
| `last_evaluation` | Most recent performance review score (0–1) |
| `number_project` | Number of projects assigned |
| `average_monthly_hours` | Average hours worked per month |
| `tenure` | Years at the company |
| `work_accident` | Whether employee had a workplace accident |
| `left` | **Target** — 1 if employee left, 0 if stayed |
| `promotion_last_5years` | Promoted in the last 5 years? |
| `department` | Department name |
| `salary` | Low / Medium / High |

---

## 🧹 Phase 1 — Data Cleaning

<p align="center">
  <img src="eda_missing_duplicates.png" alt="Missing values and duplicate check" width="85%"/>
  <br/><em>Zero missing values, but 3,008 duplicate rows (20% of the dataset) — dropped before analysis</em>
</p>

- **Renamed columns** for clarity (`Work_accident` → `work_accident`, `average_montly_hours` → `average_monthly_hours`, `time_spend_company` → `tenure`, `Department` → `department`)
- **Dropped 3,008 duplicate rows** — kept first occurrence, reducing dataset from 14,999 → 11,991 rows
- **Checked for outliers** using IQR method across all numeric columns

<p align="center">
  <img src="eda_outlier_summary.png" alt="Outlier count summary by column" width="70%"/>
  <br/><em>Tenure had 824 statistical outliers — but in HR data, outliers are usually real signal, not noise</em>
</p>

> **Analyst decision:** Outliers in `tenure` (long-serving employees) were **not removed**. In HR analytics, 10-year veterans are genuine, valuable data points — not errors. This decision was revisited per-model: tree-based models tolerate outliers well, so Random Forest used the full dataset including outliers.

---

## 📊 Phase 2 — Exploratory Data Analysis

### Attrition Overview

<p align="center">
  <img src="eda_attrition_overview.png" alt="Attrition rate and count" width="80%"/>
  <br/><em>10,000 stayed vs 1,991 left — an overall attrition rate of 16.60%</em>
</p>

### Tenure vs Attrition

<p align="center">
  <img src="eda_tenure_attrition_boxplot.png" alt="Tenure by attrition status boxplot" width="80%"/>
  <br/><em>Employees who left had a median tenure of 4 years vs 3 years for those who stayed</em>
</p>

> **Finding:** Attrition peaks at **mid-career (3–4 years)**, not at entry level. Freshers (0–2 years) rarely quit. Employees who survive past 5 years become loyal — 10-year veterans show near-zero attrition. **The danger zone is years 3–4**, when employees feel they've "learned everything" and look elsewhere for growth.

### Workload Analysis — Projects & Hours

<p align="center">
  <img src="eda_projects_hours_boxplot.png" alt="Monthly hours by number of projects, comparing stayed vs left" width="90%"/>
  <br/><em>Employees who left consistently worked more projects and more hours than those who stayed</em>
</p>

<p align="center">
  <img src="eda_projects_hist.png" alt="Number of projects histogram by attrition" width="90%"/>
  <br/><em>All employees with 7 projects left the company — a 100% attrition signal at maximum workload</em>
</p>

> **Finding:** **Top 2 reasons employees leave: workload and overwork.** Leavers handled a median of 4 projects (vs 3–4 for stayers) and worked ~225 hrs/month (vs ~200 for stayers). Every single employee assigned 7 projects quit — a clear burnout ceiling.

### Hours vs Satisfaction — Burnout Patterns

<p align="center">
  <img src="eda_hexbin_hours_satisfaction.png" alt="Hexbin plot of hours vs satisfaction for stayed vs left" width="90%"/>
  <br/><em>Two distinct attrition clusters emerge among leavers: burned-out & unhappy, and overworked-but-satisfied</em>
</p>

> **Finding:** There are **two types of leavers**: (1) employees working 250–300 hrs/month with low satisfaction (~0.1) — classic burnout, and (2) high performers working 225–250 hrs/month who are still satisfied (~0.8) but leave anyway — likely poached or seeking growth elsewhere. A third hidden group ("quiet quitting") works normal hours (140–160) with moderate satisfaction (~0.4) and still leaves.

### Satisfaction Level — The Core Signal

<p align="center">
  <img src="eda_satisfaction_boxplot1.png" alt="Satisfaction level by attrition status" width="75%"/>
  <br/><em>Leavers split into two groups: low satisfaction + short tenure, and high satisfaction + medium tenure</em>
</p>

<p align="center">
  <img src="eda_satisfaction_meanmedian.png" alt="Mean and median satisfaction scores by attrition" width="80%"/>
</p>

| Group | Mean Satisfaction | Median Satisfaction |
|---|---|---|
| Stayed | 0.667 | 0.69 |
| Left | 0.440 | 0.41 |

> **Finding:** Satisfaction is the clearest single dividing line between stayers and leavers. But it's not the whole story — a meaningful subset of leavers had *high* satisfaction, meaning factors like growth and pay also matter independently.

### Hours vs Evaluation — Performance ≠ Loyalty

<p align="center">
  <img src="eda_scatter_hours_eval.png" alt="Scatter of hours vs evaluation by attrition, plus density hexbin" width="90%"/>
  <br/><em>Burnout top performers leave: high hours + high evaluation = quit. Low performers also leave at low hours + low evaluation</em>
</p>

> **Finding:** Working 280 hrs/month does not guarantee a top evaluation score — most high-hour employees scored 0.6–0.7, not 0.9. Roughly 90% of all employees work more than 167 hrs/month (38 hrs/week), meaning **overtime is embedded in company culture**, not an exception.

### Promotions — The Missing Lever

<p align="center">
  <img src="eda_promotion_hours_dept.png" alt="Monthly hours by promotion in last 5 years" width="85%"/>
  <br/><em>Very few employees who left were promoted in the last 5 years — and very few who worked the most hours were promoted either</em>
</p>

> **Finding:** Promotion is almost entirely absent for both high-hour and departing employees. The company is **not rewarding overwork with advancement** — a direct contributor to attrition among its hardest-working staff.

### Salary vs Tenure

<p align="center">
  <img src="eda_salary_tenure_hist.png" alt="Salary histogram by tenure: short vs long tenured" width="90%"/>
  <br/><em>Long-tenured employees are not disproportionately higher-paid</em>
</p>

> **Finding:** Tenure does not guarantee salary growth. Many long-serving employees remain in the low/medium salary band — a possible compounding factor in mid-career attrition.

### Department-Level View

<p align="center">
  <img src="eda_dept_attrition_insights.png" alt="Counts of stayed vs left by department, with insights" width="90%"/>
  <br/><em>No department differs significantly in attrition proportion — this is a company-wide culture issue, not a team-specific one</em>
</p>

### EDA Summary — Why Employees Leave

| # | Driver | Evidence |
|---|---|---|
| 1 | **Burnout from workload** | Leavers handled 5+ projects vs 3–4 for stayers; 7-project employees had 100% attrition |
| 2 | **Overwork** | Leavers averaged ~225 hrs/month vs ~200 for stayers; 300+ hr outliers all quit |
| 3 | **Low satisfaction is the trigger** | Leaver median satisfaction = 0.41 vs 0.69 for stayers |
| 4 | **Mid-career cliff, not fresher attrition** | Leaver median tenure = 4 years vs 3 years for stayers; 10-year veterans rarely leave |
| 5 | **The deadly combo** | 3–4 yrs tenure + 5+ projects + 225+ hrs + satisfaction < 0.5 = high-risk profile, flaggable 6 months in advance |

---

## 🗄️ Phase 3 — SQL Analysis (Business-Rule Queries)

Used PostgreSQL to validate business rules and quantify attrition costs.

**Key SQL insights:**
1. **Employees don’t quit for salary** — Satisfaction + tenure drive attrition 20x more than salary
2. **The danger zone** — 3–4 years tenure + 5+ projects + low satisfaction = 58.53% attrition rate  
3. **Financial impact** — $171.36M estimated replacement cost across all salary bands
4. **Recognition matters** — High workload + no promotion = 18.46% attrition vs 1.98% with promotion

## 🤖 Phase 4 — Machine Learning

**Goal:** Predict whether an employee will leave (`left` = 1) — a binary classification problem. Two models were built and compared.

---

### Model A — Logistic Regression

```python
# Encode categorical features
df_enc['salary'] = (df_enc['salary'].astype('category')
                     .cat.set_categories(['low', 'medium', 'high']).cat.codes)
df_enc = pd.get_dummies(df_enc, drop_first=False)

X = df_enc.drop('left', axis=1)
y = df_enc['left']

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)

lr = LogisticRegression(random_state=42, max_iter=1000, class_weight='balanced')
lr.fit(X_train, y_train)
```

<p align="center">
  <img src="ml_logreg_confusion_matrix.png" alt="Logistic Regression confusion matrix and classification report" width="85%"/>
</p>

| Metric | Class 0 (Stayed) | Class 1 (Left) |
|---|---|---|
| Precision | 0.96 | 0.42 |
| Recall | 0.77 | 0.84 |
| F1-score | 0.86 | 0.56 |

**Overall accuracy: 77.55%** — `class_weight='balanced'` was used to improve recall on the minority class (quitters), since missing a quitter is costlier to HR than a false alarm.

### Logistic Regression — Feature Coefficients

<p align="center">
  <img src="ml_logreg_top_features.png" alt="Top features driving and reducing attrition — Logistic Regression coefficients" width="80%"/>
</p>

<p align="center">
  <img src="ml_logreg_quit_stay_reasons.png" alt="Top 7 reasons employees quit vs top 5 reasons employees stay — bar charts" width="90%"/>
</p>

| Drives Attrition ⬆️ | Coefficient | Reduces Attrition ⬇️ | Coefficient |
|---|---|---|---|
| Last evaluation | +1.16 | Satisfaction level | −4.40 |
| Tenure | +0.66 | Work accident | −1.33 |
| Average monthly hours | +0.004 | Promotion last 5 years | −1.24 |

> **Finding:** Counter-intuitively, **high evaluation scores increase quit risk** — top performers leave when they feel under-rewarded. **Satisfaction is the single strongest retention anchor**, roughly 4× stronger than any other factor in the model. Salary ranked surprisingly low.

---

### Model B — Random Forest Classifier

**Why move to Random Forest after Logistic Regression?** Three documented reasons:

1. **Logistic Regression assumes linear relationships** — but the EDA showed tenure risk *spikes* at 3–4 years and *drops* again after year 10. A straight-line model can't capture that curve.
2. **Tenure outliers are real signal, not noise** — 15+ year veterans and 1-month churners are both legitimate business cases that a linear model would treat as the same trend direction.
3. **Interaction effects matter** — "high evaluation + 4 years tenure + no promotion" is a much stronger risk signal than any single feature alone. Random Forest captures these combinations automatically; Logistic Regression cannot.

```python
# Hyperparameter tuning via GridSearchCV
# Best params: {'max_depth': None, 'min_samples_leaf': 5, 'min_samples_split': 6, 'n_estimators': 200}

y_pred_rf = best_rf.predict(X_test)
print("Accuracy:", round(accuracy_score(y_test, y_pred_rf), 4))
print(classification_report(y_test, y_pred_rf))
```

<p align="center">
  <img src="ml_rf_results.png" alt="Random Forest results — accuracy 98.17%, classification report" width="85%"/>
</p>

### 🏆 Final Model Comparison

<p align="center">
  <img src="ml_model_comparison_conclusion.png" alt="Model comparison table — Logistic Regression vs Random Forest" width="85%"/>
</p>

| Model | Accuracy | Recall (Quit) | Precision (Quit) | F1 (Quit) |
|---|---|---|---|---|
| Logistic Regression | 0.7755 | 0.8213 | 0.4419 | 0.5486 |
| **Random Forest** | **0.9817** | **0.9116** | **0.9763** | **0.9429** |

> **Why Random Forest wins:** F1-score for the quit class jumped from 0.55 to 0.94. Logistic Regression assumes attrition is linear and features act independently — Random Forest uncovered the real pattern: **mid-tenure burnout combined with a satisfaction drop**, an interaction effect invisible to a linear model.

### Random Forest — Feature Importance

<p align="center">
  <img src="ml_rf_top_reasons.png" alt="Top 7 reasons employees quit — Random Forest feature importance" width="85%"/>
</p>

| Rank | Feature | Importance | Interpretation |
|---|---|---|---|
| 1 | Satisfaction level | 0.268 | #1 driver — low satisfaction = exit, regardless of tenure or performance |
| 2 | Tenure | 0.261 | Confirms non-linear "danger zone" — risk rises year 3–5, then drops |
| 3 | Number of projects | 0.160 | Combines with hours to form the burnout signal |
| 4 | Average monthly hours | 0.148 | 5+ projects + 250+ hrs/month = compounding quit risk |
| 5 | Last evaluation | 0.121 | High performers still quit if satisfaction is low — performance ≠ loyalty |
| 6 | Salary | 0.011 | Surprisingly weak — ~20× less important than satisfaction |

> **Most important business insight: people don't quit primarily for money.** Salary importance (0.011) is dwarfed by satisfaction (0.268) and tenure-stage risk (0.261). Retention budgets aimed purely at pay raises will under-perform compared to fixing workload and recognition systems.

---

## 📊 Power BI Dashboard

Interactive dashboard for HR self-service. Filter by Department, Tenure, Salary, Projects, Promotion to flag high-risk employees instantly.

> Built the dashboard from SQL + ML insights so non-technical HR can use it daily

## 💡 Final Recommendations for HR

| # | Recommendation | Supporting Evidence |
|---|---|---|
| 1 | **Cap project load at 4–5 per employee** | 100% of 7-project employees left; burnout is the top quit driver |
| 2 | **Build a "4-year review" intervention program** | Mid-tenure (3–4 yr) + low satisfaction = 58.53% attrition — the highest-risk segment in the company |
| 3 | **Reward overtime, don't just expect it** | High hours without promotion = 18.46% attrition; same hours WITH promotion = 1.98% |
| 4 | **Decouple high evaluation scores from long hours** | Working 280 hrs/month doesn't guarantee a top score — and high evaluators still quit if unsatisfied |
| 5 | **Prioritise satisfaction surveys over pay raises** | ML proves satisfaction is 20× more predictive of attrition than salary |
| 6 | **Deploy the Random Forest model operationally** | 98% accuracy, 91% recall — HR can flag high-risk employees 6 months in advance using satisfaction + tenure + workload |
| 7 | **Address HR & Accounting department attrition specifically** | SQL shows these two departments have the highest attrition rates (18.80% and 17.55%) |
| 8 | **Use the $171M attrition cost estimate to secure retention budget** | Converts an HR problem into a board-level financial argument |

---

## 🛠️ Tech Stack

| Layer | Tools |
|---|---|
| Language | Python 3.x |
| Data Manipulation | Pandas, NumPy |
| Visualisation | Matplotlib, Seaborn |
| Machine Learning | Scikit-learn — LogisticRegression, RandomForestClassifier, GridSearchCV |
| Model Evaluation | accuracy_score, precision_score, recall_score, f1_score, confusion_matrix, classification_report, roc_auc_score |
| Database | PostgreSQL |
| BI Dashboard | Power BI |
| Notebook | Jupyter Notebook |

---

## 🚀 How to Run

```bash
# 1. Clone the repo
git clone https://github.com/yourusername/salifort-attrition-analysis.git
cd salifort-attrition-analysis

# 2. Install dependencies
pip install -r requirements.txt

# 3. Run the EDA notebook
jupyter notebook notebooks/01_EDA.ipynb

# 4. Run the ML notebook
jupyter notebook notebooks/02_ML_Models.ipynb

# 5. Run SQL queries
# Connect to your PostgreSQL instance and execute sql/salifort_queries.sql
```

### requirements.txt
```
pandas
numpy
matplotlib
seaborn
scikit-learn
jupyter
```

---

## 👤 Author

**[Vysakh S Raj]**
Data Analyst · Python · SQL · Power BI · Machine Learning

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?logo=linkedin)](https://linkedin.com/in/yourprofile)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-black?logo=github)](https://github.com/yourusername)

---

## 📃 License

This project is for educational and portfolio purposes. Dataset based on the Google Advanced Data Analytics capstone (Salifort Motors case study).

---

*Built with Python · PostgreSQL · Scikit-learn · Power BI*
