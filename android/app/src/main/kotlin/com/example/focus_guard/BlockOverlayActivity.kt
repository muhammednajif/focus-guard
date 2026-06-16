package com.example.focus_guard

import android.app.Activity
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.widget.Button
import android.widget.TextView
import android.graphics.Color
import android.view.Gravity
import android.widget.LinearLayout
import android.widget.EditText
import android.view.inputmethod.EditorInfo
import android.widget.Toast
import org.json.JSONObject
import java.util.concurrent.ThreadLocalRandom

class BlockOverlayActivity : Activity() {
    private val handler = Handler(Looper.getMainLooper())
    private var currentStep = 0
    private var blockedPackage = ""
    private var blockReason = ""
    private var currentProblem = 0
    private var correctCount = 0
    private var currentAnswer = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        blockedPackage = intent.getStringExtra("blocked_package") ?: "this app"

        // Get block reason from SharedPreferences
        val prefs = getSharedPreferences("FocusGuardPrefs", MODE_PRIVATE)
        val settingsJson = prefs.getString("block_settings_$blockedPackage", "")

        if (settingsJson.isNullOrEmpty()) {
            blockReason = "Focus" // Default reason
        } else {
            try {
                val jsonObject = JSONObject(settingsJson)
                blockReason = jsonObject.optString("reason", "Focus")
            } catch (e: Exception) {
                blockReason = "Focus"
            }
        }

        showRealityCheckScreen()
    }

    private fun showRealityCheckScreen() {
        currentStep = 0

        // Build UI in code, no XML needed
        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#1A1A2E"))
            setPadding(60, 60, 60, 60)
        }

        val emoji = TextView(this).apply {
            text = when (blockReason.lowercase()) {
                "study" -> "📚"
                "work" -> "💼"
                "sleep" -> "😴"
                "health" -> "💪"
                else -> "🚫"
            }
            textSize = 64f
            gravity = Gravity.CENTER
        }

        val title = TextView(this).apply {
            text = "This is your $blockReason time"
            textSize = 28f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            setPadding(0, 24, 0, 12)
        }

        val subtitle = TextView(this).apply {
            text = "The app you tried to open is blocked"
            textSize = 16f
            setTextColor(Color.parseColor("#AAAAAA"))
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 40)
        }

        val keepFocusedButton = Button(this).apply {
            text = "No, keep me focused"
            textSize = 16f
            setTextColor(Color.WHITE)
            setBackgroundColor(Color.parseColor("#6C63FF"))
            setPadding(40, 20, 40, 20)
            setOnClickListener {
                // Close activity - user stays focused
                finish()
            }
        }

        val wantToLeaveButton = Button(this).apply {
            text = "I still want to leave"
            textSize = 16f
            setTextColor(Color.WHITE)
            setBackgroundColor(Color.parseColor("#4CAF50"))
            setPadding(40, 20, 40, 20)
            setOnClickListener {
                // Proceed to next step
                showBreathingExercise()
            }
        }

        layout.addView(emoji)
        layout.addView(title)
        layout.addView(subtitle)
        layout.addView(keepFocusedButton)
        layout.addView(wantToLeaveButton)

        setContentView(layout)
    }

    private fun showBreathingExercise() {
        currentStep = 1

        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#1A1A2E"))
            setPadding(60, 60, 60, 60)
        }

        val breathingText = TextView(this).apply {
            text = "Breathe in..."
            textSize = 28f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 40)
        }

        // Simple animated circle using text
        val circle = TextView(this).apply {
            text = "●"
            textSize = 100f
            setTextColor(Color.parseColor("#6C63FF"))
            gravity = Gravity.CENTER
            setPadding(0, 40, 0, 40)
        }

        layout.addView(breathingText)
        layout.addView(circle)

        setContentView(layout)

        // Start breathing animation
        animateBreathing(breathingText, circle)
    }

    private fun animateBreathing(breathingText: TextView, circle: TextView) {
        val totalTime = 10000L // 10 seconds
        val interval = 500L // 500ms update interval

        val startTime = System.currentTimeMillis()

        val runnable = object : Runnable {
            override fun run() {
                val elapsed = System.currentTimeMillis() - startTime
                val progress = elapsed.toFloat() / totalTime

                // Alternate between "Breathe in..." and "Breathe out..."
                if (progress < 0.5f) {
                    breathingText.text = "Breathe in..."
                } else {
                    breathingText.text = "Breathe out..."
                }

                // Animate circle size
                val scale = 0.5f + 0.5f * Math.sin(progress * 2 * Math.PI).toFloat()
                circle.scaleX = scale
                circle.scaleY = scale

                if (elapsed < totalTime) {
                    handler.postDelayed(this, interval)
                } else {
                    // Move to math challenge after 10 seconds
                    showMathChallenge()
                }
            }
        }

        handler.post(runnable)
    }

    private fun showMathChallenge() {
        currentStep = 2
        currentProblem = 0
        correctCount = 0
        generateAndShowProblem()
    }

    private fun generateAndShowProblem() {
        if (currentProblem >= 3) {
            // All problems solved correctly, show motivation quote
            showMotivationQuote()
            return
        }

        // Generate random numbers between 1 and 20
        val num1 = ThreadLocalRandom.current().nextInt(1, 21)
        val num2 = ThreadLocalRandom.current().nextInt(1, 21)

        // Generate random operation (+, -, *)
        val operations = listOf('+', '-', '*')
        val operation = operations[ThreadLocalRandom.current().nextInt(0, operations.size)]

        // Calculate the correct answer
        val correctAnswer = when (operation) {
            '+' -> num1 + num2
            '-' -> num1 - num2
            '*' -> num1 * num2
            else -> 0
        }

        // Build UI for math challenge
        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#1A1A2E"))
            setPadding(60, 60, 60, 60)
        }

        val problemText = TextView(this).apply {
            text = "$num1 $operation $num2 = ?"
            textSize = 32f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 40)
        }

        val answerInput = EditText(this).apply {
            hint = "Enter your answer"
            textSize = 24f
            setTextColor(Color.WHITE)
            setBackgroundColor(Color.parseColor("#2D2D44"))
            setPadding(20, 20, 20, 20)
            gravity = Gravity.CENTER
            setSingleLine()
            imeOptions = EditorInfo.IME_ACTION_DONE
        }

        val submitButton = Button(this).apply {
            text = "Submit"
            textSize = 16f
            setTextColor(Color.WHITE)
            setBackgroundColor(Color.parseColor("#6C63FF"))
            setPadding(40, 20, 40, 20)
            setOnClickListener {
                val userAnswer = answerInput.text.toString()
                if (userAnswer.isNotEmpty()) {
                    val answer = userAnswer.toIntOrNull()
                    if (answer != null && answer == correctAnswer) {
                        // Correct answer
                        currentProblem++
                        correctCount++
                        Toast.makeText(this@BlockOverlayActivity, "Correct!", Toast.LENGTH_SHORT).show()
                        handler.postDelayed({
                            generateAndShowProblem()
                        }, 500)
                    } else {
                        // Wrong answer
                        currentProblem = 0
                        correctCount = 0
                        Toast.makeText(this@BlockOverlayActivity, "Wrong! Try again", Toast.LENGTH_SHORT).show()
                        answerInput.setText("")
                    }
                }
            }
        }

        val numberPad = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(0, 20, 0, 0)
        }

        // Create 3 rows of number pad
        val rows = listOf(
            listOf("1", "2", "3"),
            listOf("4", "5", "6"),
            listOf("7", "8", "9"),
            listOf("0")
        )

        rows.forEach { row ->
            val rowLayout = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER
                setPadding(0, 0, 0, 10)
            }

            row.forEach { number ->
                val button = Button(this).apply {
                    text = number
                    textSize = 20f
                    setTextColor(Color.WHITE)
                    setBackgroundColor(Color.parseColor("#4A4A6A"))
                    setPadding(20, 20, 20, 20)
                    setOnClickListener {
                        answerInput.append(number)
                    }
                }
                rowLayout.addView(button)
            }

            numberPad.addView(rowLayout)
        }

        layout.addView(problemText)
        layout.addView(answerInput)
        layout.addView(submitButton)
        layout.addView(numberPad)

        setContentView(layout)
    }

    private fun showMotivationQuote() {
        currentStep = 3

        val quote = getMotivationalQuote(blockReason.lowercase())

        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#1A1A2E"))
            setPadding(60, 60, 60, 60)
        }

        val quoteText = TextView(this).apply {
            text = quote
            textSize = 24f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 40)
        }

        val goBackButton = Button(this).apply {
            text = "Go Back to Home"
            textSize = 16f
            setTextColor(Color.WHITE)
            setBackgroundColor(Color.parseColor("#6C63FF"))
            setPadding(40, 20, 40, 20)
            setOnClickListener {
                finish()
            }
        }

        layout.addView(quoteText)
        layout.addView(goBackButton)

        setContentView(layout)

        // Automatically go back to home after 3 seconds
        handler.postDelayed({
            finish()
        }, 3000)
    }

    private fun getMotivationalQuote(reason: String): String {
        return when (reason) {
            "study" -> "Learning is the beginning of wealth, learning is the beginning of health, learning is the beginning of spirituality. - James A. Michener"
            "work" -> "The secret of getting ahead is getting started. - Mark Twain"
            "sleep" -> "Sleep is the best meditation. - Dalai Lama"
            "health" -> "Take care of your body. It's the only place you have to live. - Jim Rohn"
            else -> "Stay focused and keep moving forward. Your future self will thank you."
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        // Block back button throughout the entire flow
        // This prevents users from exiting during the challenge
    }
}
