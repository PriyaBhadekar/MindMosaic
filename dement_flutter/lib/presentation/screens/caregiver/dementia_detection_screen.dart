import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/assessment_provider.dart';
import '../../../providers/mri_provider.dart';

class DementiaDetectionScreen extends StatefulWidget {
  const DementiaDetectionScreen({super.key});

  @override
  State<DementiaDetectionScreen> createState() =>
      _DementiaDetectionScreenState();
}

class _DementiaDetectionScreenState
    extends State<DementiaDetectionScreen> {

  int currentStep = 0;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController ageController =
      TextEditingController(text: "70");

  final TextEditingController educationController =
      TextEditingController(text: "12");

  int gender = 0;

  double ses = 2;

  @override
  void dispose() {
    ageController.dispose();
    educationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final assessmentProvider =
        context.watch<AssessmentProvider>();

    final mriProvider =
        context.watch<MriProvider>();

    return Scaffold(

      backgroundColor: AppColors.background,

      appBar: AppBar(

        elevation: 0,

        backgroundColor: AppColors.background,

        centerTitle: true,

        title: const Text(
          "Dementia Care Screen",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

      ),

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(20),

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              const Center(

                child: Text(

                  "AI Powered Caregiver Assessment Tool",

                  style: TextStyle(

                    fontSize: 17,

                    color: Colors.grey,

                    fontWeight: FontWeight.w500,

                  ),
                ),
              ),

              const SizedBox(height: 30),

              _buildStepper(),

              const SizedBox(height: 30),

              if (currentStep == 0)
                _buildPatientInfo(
                  assessmentProvider,
                ),

              if (currentStep == 1)
                _buildMMSETest(
                  assessmentProvider,
                ),

              if (currentStep == 2)
                _buildResultScreen(
                  assessmentProvider,
                  mriProvider,
                ),
            ],
          ),
        ),
      ),
    );
  }

  //==========================================================
  // STEP INDICATOR
  //==========================================================

  Widget _buildStepper() {

    return Row(

      children: [

        Expanded(
          child: _stepChip(
            "1",
            "Patient Info",
            currentStep >= 0,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _stepChip(
            "2",
            "Cognitive Test",
            currentStep >= 1,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _stepChip(
            "3",
            "Results",
            currentStep >= 2,
          ),
        ),
      ],
    );
  }

  Widget _stepChip(

    String number,

    String title,

    bool active,

  ) {

    return AnimatedContainer(

      duration:
          const Duration(milliseconds: 250),

      padding:
          const EdgeInsets.symmetric(
        vertical: 14,
      ),

      decoration: BoxDecoration(

        color: active
            ? AppColors.primary
            : Colors.grey.shade300,

        borderRadius:
            BorderRadius.circular(30),

      ),

      child: Center(

        child: Text(

          "$number\n$title",

          textAlign: TextAlign.center,

          style: TextStyle(

            fontWeight: FontWeight.bold,

            color: active
                ? Colors.white
                : Colors.black54,

          ),
        ),
      ),
    );
  }
  //==========================================================
  // STEP 1 - PATIENT INFORMATION
  //==========================================================

  Widget _buildPatientInfo(
    AssessmentProvider provider,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Icon(
                    Icons.info_outline,
                    color: Colors.indigo,
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      "Enter the patient's basic information before starting the cognitive assessment.",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            "Patient Information",
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          DropdownButtonFormField<int>(
            value: gender,
            decoration: InputDecoration(
              labelText: "Gender",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: const [

              DropdownMenuItem(
                value: 0,
                child: Text("Female"),
              ),

              DropdownMenuItem(
                value: 1,
                child: Text("Male"),
              ),

            ],
            onChanged: (value) {

              setState(() {

                gender = value!;

              });

            },
          ),

          const SizedBox(height: 18),

          TextFormField(

            controller: ageController,

            keyboardType: TextInputType.number,

            decoration: InputDecoration(

              labelText: "Age",

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              prefixIcon: const Icon(
                Icons.person_outline,
              ),

            ),

            validator: (value) {

              if (value == null || value.isEmpty) {
                return "Enter patient's age";
              }

              return null;
            },
          ),

          const SizedBox(height: 18),

          TextFormField(

            controller: educationController,

            keyboardType: TextInputType.number,

            decoration: InputDecoration(

              labelText: "Years of Education",

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              prefixIcon: const Icon(
                Icons.school_outlined,
              ),

            ),

            validator: (value) {

              if (value == null || value.isEmpty) {
                return "Enter education";
              }

              return null;
            },
          ),

          const SizedBox(height: 18),

          DropdownButtonFormField<double>(

            value: ses,

            decoration: InputDecoration(

              labelText: "Socioeconomic Status",

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),

            ),

            items: const [

              DropdownMenuItem(
                value: 1,
                child: Text("1 - High"),
              ),

              DropdownMenuItem(
                value: 2,
                child: Text("2 - Upper Middle"),
              ),

              DropdownMenuItem(
                value: 3,
                child: Text("3 - Middle"),
              ),

              DropdownMenuItem(
                value: 4,
                child: Text("4 - Lower Middle"),
              ),

              DropdownMenuItem(
                value: 5,
                child: Text("5 - Low"),
              ),

            ],

            onChanged: (value) {

              setState(() {

                ses = value!;

              });

            },
          ),

          const SizedBox(height: 35),

          SizedBox(

            width: double.infinity,

            height: 55,

            child: ElevatedButton.icon(

              icon: const Icon(Icons.arrow_forward),

              label: const Text(
                "Next - Cognitive Test",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              onPressed: () {

                if (!_formKey.currentState!.validate()) {
                  return;
                }

                provider.setPatientInfo(

                  gender: gender,

                  age: double.parse(
                    ageController.text,
                  ),

                  education: double.parse(
                    educationController.text,
                  ),

                  ses: ses,

                );

                setState(() {

                  currentStep = 1;

                });

              },
            ),
          ),

          const SizedBox(height: 20),

        ],
      ),
    );
  }

  //==========================================================
  // STEP 2 - MMSE COGNITIVE TEST
  //==========================================================

  Widget _buildMMSETest(
    AssessmentProvider provider,
  ) {

    final orientationTime =
        provider.getAnswer("orientationTime") ?? 0;

    final orientationPlace =
        provider.getAnswer("orientationPlace") ?? 0;

    final registration =
        provider.getAnswer("registration") ?? 0;

    final attention =
        provider.getAnswer("attention") ?? 0;

    final recall =
        provider.getAnswer("recall") ?? 0;

    final language =
        provider.getAnswer("language") ?? 0;

    final visuospatial =
        provider.getAnswer("visuospatial") ?? 0;

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        const Text(
          "MMSE Cognitive Assessment",
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          "Assign scores for each Mini-Mental State Examination section.",
          style: TextStyle(
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 25),

        _scoreCard(
          title: "1. Orientation to Time",
          subtitle: "Year, Season, Month, Date, Day",
          max: 5,
          value: orientationTime,
          onChanged: (v) {
            provider.setAnswer(
              "orientationTime",
              v,
            );
            setState(() {});
          },
        ),

        const SizedBox(height: 18),

        _scoreCard(
          title: "2. Orientation to Place",
          subtitle:
              "Country, State, City, Hospital, Floor",
          max: 5,
          value: orientationPlace,
          onChanged: (v) {
            provider.setAnswer(
              "orientationPlace",
              v,
            );
            setState(() {});
          },
        ),

        const SizedBox(height: 18),

        _scoreCard(
          title: "3. Registration",
          subtitle:
              "Repeat three words correctly",
          max: 3,
          value: registration,
          onChanged: (v) {
            provider.setAnswer(
              "registration",
              v,
            );
            setState(() {});
          },
        ),

        const SizedBox(height: 18),

        _scoreCard(
          title: "4. Attention & Calculation",
          subtitle:
              "Serial 7 subtraction / WORLD backwards",
          max: 5,
          value: attention,
          onChanged: (v) {
            provider.setAnswer(
              "attention",
              v,
            );
            setState(() {});
          },
        ),

        const SizedBox(height: 18),

        _scoreCard(
          title: "5. Recall",
          subtitle:
              "Recall the previous three words",
          max: 3,
          value: recall,
          onChanged: (v) {
            provider.setAnswer(
              "recall",
              v,
            );
            setState(() {});
          },
        ),

        const SizedBox(height: 18),

        _scoreCard(
          title: "6. Language",
          subtitle:
              "Naming, reading, writing and commands",
          max: 8,
          value: language,
          onChanged: (v) {
            provider.setAnswer(
              "language",
              v,
            );
            setState(() {});
          },
        ),

        const SizedBox(height: 18),

        _scoreCard(
          title: "7. Visuospatial",
          subtitle:
              "Copy intersecting pentagons",
          max: 1,
          value: visuospatial,
          onChanged: (v) {
            provider.setAnswer(
              "visuospatial",
              v,
            );
            setState(() {});
          },
        ),

        const SizedBox(height: 30),

        // ==========================================================
        // MMSE SCORE SUMMARY
        // ==========================================================

        Builder(
          builder: (_) {
            final total =
                orientationTime +
                orientationPlace +
                registration +
                attention +
                recall +
                language +
                visuospatial;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [

                  const Text(
                    "Calculated MMSE Score",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "$total / 30",
                    style: const TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    total >= 24
                        ? "Normal Cognitive Function"
                        : total >= 18
                            ? "Mild Cognitive Impairment"
                            : total >= 10
                                ? "Moderate Cognitive Impairment"
                                : "Severe Cognitive Impairment",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 30),

        // ==========================================================
        // GENERATE AI PREDICTION
        // ==========================================================

        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(

            icon: const Icon(Icons.psychology),

            label: const Text(
              "Generate AI Prediction",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            onPressed: () async {

              final total =
                  orientationTime +
                  orientationPlace +
                  registration +
                  attention +
                  recall +
                  language +
                  visuospatial;

              provider.setMMSE(total);

              final mri =
                  context.read<MriProvider>();

              await mri.predictDementia(

                gender: provider.gender,

                age: provider.age,

                educ: provider.education,

                ses: provider.ses,

                mmse: total.toDouble(),

              );

              if (!mounted) return;

              setState(() {

                currentStep = 2;

              });

            },
          ),
        ),

        const SizedBox(height: 40),

      ],
    );
  }

  //==========================================================
  // STEP 3 - RESULT SCREEN
  //==========================================================

  Widget _buildResultScreen(
    AssessmentProvider provider,
    MriProvider mri,
  ) {

    if (mri.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (mri.error != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [

            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),

            const SizedBox(height: 15),

            const Text(
              "Prediction Failed",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              mri.error!,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (mri.predictionResult == null) {
      return const Center(
        child: Text(
          "No prediction available.",
        ),
      );
    }

    final result = mri.predictionResult!;

    final bool hasDementia =
        result["hasDementia"] ?? false;

    final String stage =
        result["stage"] ?? "Unknown";

    final String riskLevel =
        result["riskLevel"] ?? "";

    final double probability =
        (result["probability"] as num)
            .toDouble();

    final String recommendation =
        result["recommendation"] ?? "";

    final String emoji =
        result["emoji"] ?? "AI";

    Color stageColor;

    if (stage == "Normal") {

      stageColor = Colors.green;

    } else if (stage == "Very Mild") {

      stageColor = Colors.orange;

    } else if (stage == "Mild") {

      stageColor = Colors.deepOrange;

    } else {

      stageColor = Colors.red;

    }

    return Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Center(

          child: Column(

            children: [

              Text(
                emoji,
                style: const TextStyle(
                  fontSize: 60,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                stage,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: stageColor,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                hasDementia
                    ? "Dementia Indicated"
                    : "No Dementia Detected",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),

              Row(
                children: [

                  Expanded(
                    child: _resultCard(
                      title: "MMSE Score",
                      value: "${provider.mmse} / 30",
                      icon: Icons.psychology,
                      color: Colors.indigo,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: _resultCard(
                      title: "Risk Probability",
                      value: "${probability.toStringAsFixed(1)}%",
                      icon: Icons.analytics,
                      color: Colors.orange,
                    ),
                  ),

                ],
              ),

              const SizedBox(height: 15),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: stageColor.withOpacity(.10),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: stageColor.withOpacity(.35),
                  ),
                ),
                child: Row(
                  children: [

                    Icon(
                      Icons.health_and_safety,
                      color: stageColor,
                      size: 34,
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          const Text(
                            "Risk Level",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            riskLevel,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: stageColor,
                            ),
                          ),

                        ],
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 25),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Row(
                      children: [

                        Icon(
                          Icons.lightbulb,
                          color: Colors.orange,
                        ),

                        SizedBox(width: 8),

                        Text(
                          "Recommendation",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      ],
                    ),

                    const SizedBox(height: 15),

                    Text(
                      recommendation,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 25),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.amber.shade300,
                  ),
                ),
                child: const Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                    ),

                    SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        "This tool is intended for educational and screening purposes only. It is not a medical diagnosis. Always consult a qualified neurologist or healthcare professional.",
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(

                  icon: const Icon(Icons.restart_alt),

                  label: const Text(
                    "Start New Assessment",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  onPressed: () {

                    provider.reset();

                    mri.clearPrediction();

                    ageController.text = "70";
                    educationController.text = "12";

                    gender = 0;
                    ses = 2;

                    setState(() {

                      currentStep = 0;

                    });

                  },
                ),
              ),

              const SizedBox(height: 30),

            ],
          ),
        ),
      ],
    );
  }

  Widget _resultCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [

          Icon(
            icon,
            color: color,
            size: 34,
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),

        ],
      ),
    );
  }

  //==========================================================
  // MMSE SCORE CARD
  //==========================================================

  Widget _scoreCard({
    required String title,
    required String subtitle,
    required int max,
    required int value,
    required Function(int) onChanged,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 20),

            Slider(
              value: value.toDouble(),
              min: 0,
              max: max.toDouble(),
              divisions: max,
              label: "$value",
              activeColor: AppColors.primary,
              onChanged: (v) {
                onChanged(v.round());
              },
            ),

            Row(
              children: [

                Text(
                  "0",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),

                const Spacer(),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "$value / $max",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
