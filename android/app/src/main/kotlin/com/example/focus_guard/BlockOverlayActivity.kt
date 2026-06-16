package com.example.focus_guard

import android.app.Activity
import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.Vibrator
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
import org.json.JSONObject
import java.util.concurrent.ThreadLocalRandom
import kotlin.math.min

class BlockOverlayActivity : Activity() {
    private val handler = Handler(Looper.getMainLooper())
    private var blockedPackage = ""
    private var blockReason = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        blockedPackage = intent.getStringExtra("blocked_package") ?: "this app"

        val prefs = getSharedPreferences("FocusGuardPrefs", MODE_PRIVATE)
        val settingsJson = prefs.getString("block_settings_$blockedPackage", "")

        blockReason = if (settingsJson.isNullOrEmpty()) {
            "Focus" // Default reason
        } else {
            try {
                val jsonObject = JSONObject(settingsJson)
                jsonObject.optString("reason", "Focus")
            } catch (e: Exception) {
                "Focus"
            }
        }

        showFocusOrbScreen()
    }

    private fun showFocusOrbScreen() {
        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#1A1A2E"))
            setPadding(60, 60, 60, 60)
        }

        val title = TextView(this).apply {
            text = "Hold the orb to continue"
            textSize = 24f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 48)
        }

        val focusOrbView = FocusOrbView(this).apply {
            onHoldCompleteListener = {
                showBreathingExercise()
            }
        }
        
        val params = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            0,
            1.0f
        )
        focusOrbView.layoutParams = params


        layout.addView(title)
        layout.addView(focusOrbView)

        setContentView(layout)
    }

    private fun showBreathingExercise() {
        // ... (rest of the functions remain the same as before)
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
        animateBreathing(breathingText, circle)
    }

    private fun animateBreathing(breathingText: TextView, circle: TextView) {
        val totalTime = 10000L
        val interval = 50L
        val startTime = System.currentTimeMillis()

        val runnable = object : Runnable {
            override fun run() {
                val elapsed = System.currentTimeMillis() - startTime
                val progress = elapsed.toFloat() / totalTime

                if (progress < 0.5f) {
                    breathingText.text = "Breathe in..."
                } else {
                    breathingText.text = "Breathe out..."
                }

                val scale = 0.5f + 0.5f * kotlin.math.sin(progress * 2 * Math.PI).toFloat()
                circle.scaleX = scale
                circle.scaleY = scale

                if (elapsed < totalTime) {
                    handler.postDelayed(this, interval)
                } else {
                    showMathChallenge()
                }
            }
        }
        handler.post(runnable)
    }
    
    private fun showMathChallenge() {
        // ... (this function remains the same as before)
        var currentProblem = 0
        var correctCount = 0

        fun generateAndShowProblem() {
            if (currentProblem >= 3) {
                showMotivationQuote()
                return
            }
            val num1 = ThreadLocalRandom.current().nextInt(1, 21)
            val num2 = ThreadLocalRandom.current().nextInt(1, 21)
            val operations = listOf('+', '-', '*')
            val operation = operations[ThreadLocalRandom.current().nextInt(0, operations.size)]
            val correctAnswer = when (operation) {
                '+' -> num1 + num2
                '-' -> num1 - num2
                '*' -> num1 * num2
                else -> 0
            }
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
            val answerInput = TextView(this).apply {
                hint = "Answer"
                textSize = 24f
                setTextColor(Color.WHITE)
                setBackgroundColor(Color.parseColor("#2D2D44"))
                setPadding(20, 20, 20, 20)
                gravity = Gravity.CENTER
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
                            currentProblem++
                            correctCount++
                            Toast.makeText(this@BlockOverlayActivity, "Correct!", Toast.LENGTH_SHORT).show()
                            handler.postDelayed({ generateAndShowProblem() }, 500)
                        } else {
                            currentProblem = 0
                            correctCount = 0
                            Toast.makeText(this@BlockOverlayActivity, "Wrong! Try again", Toast.LENGTH_SHORT).show()
                            answerInput.text = ""
                        }
                    }
                }
            }
            val numberPad = LinearLayout(this).apply {
                orientation = LinearLayout.VERTICAL
                gravity = Gravity.CENTER
                setPadding(0, 20, 0, 0)
            }
            val rows = listOf(listOf("1", "2", "3"), listOf("4", "5", "6"), listOf("7", "8", "9"), listOf("0", "Clear"))
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
                            if (number == "Clear") {
                                answerInput.text = ""
                            } else {
                                answerInput.append(number)
                            }
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
        generateAndShowProblem()
    }

    private fun showMotivationQuote() {
        // ... (this function remains the same as before)
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
            setOnClickListener { finish() }
        }
        layout.addView(quoteText)
        layout.addView(goBackButton)
        setContentView(layout)
        handler.postDelayed({ finish() }, 3000)
    }

    private fun getMotivationalQuote(reason: String): String {
        return when (reason) {
            "study" -> "The beautiful thing about learning is that no one can take it away from you."
            "work" -> "The future depends on what you do today."
            "sleep" -> "A good laugh and a long sleep are the two best cures for anything."
            "health" -> "The greatest wealth is health."
            else -> "The secret of getting ahead is getting started."
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        // Prevent users from exiting during the challenge
    }
}

// --- Custom View for the Focus Orb ---
class FocusOrbView(context: Context) : View(context) {
    var onHoldCompleteListener: (() -> Unit)? = null

    private val orbPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.parseColor("#6C63FF") }
    private val progressPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.parseColor("#FFFFFF"); strokeWidth = 15f; style = Paint.Style.STROKE }
    private val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.WHITE; textSize = 64f; textAlign = Paint.Align.CENTER }
    
    private var centerX = 0f
    private var centerY = 0f
    private var radius = 0f

    private var isHolding = false
    private val holdDuration = 5000L // 5 seconds
    private var holdStartTime = 0L
    private var progress = 0f

    private val handler = Handler(Looper.getMainLooper())
    private val vibrator = context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator

    private val progressRunnable = object : Runnable {
        override fun run() {
            if (isHolding) {
                val elapsed = System.currentTimeMillis() - holdStartTime
                progress = elapsed.toFloat() / holdDuration
                
                if (progress >= 1.0f) {
                    progress = 1.0f
                    isHolding = false
                    vibrator.vibrate(100)
                    onHoldCompleteListener?.invoke()
                } else {
                    handler.postDelayed(this, 16) // ~60fps
                }
                invalidate()
            }
        }
    }

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        centerX = w / 2f
        centerY = h / 2f
        radius = min(w, h) / 3f
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        // Draw the main orb
        canvas.drawCircle(centerX, centerY, radius, orbPaint)
        
        // Draw the progress ring
        val sweepAngle = progress * 360
        canvas.drawArc(centerX - radius, centerY - radius, centerX + radius, centerY + radius, -90f, sweepAngle, false, progressPaint)

        // Draw countdown text
        if (isHolding && progress < 1.0f) {
            val remaining = (holdDuration - (progress * holdDuration).toLong()) / 1000 + 1
            canvas.drawText(remaining.toString(), centerX, centerY - ((textPaint.descent() + textPaint.ascent()) / 2), textPaint)
        }
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        val x = event.x
        val y = event.y
        val distance = kotlin.math.sqrt((x - centerX).pow(2) + (y - centerY).pow(2))

        when (event.action) {
            MotionEvent.ACTION_DOWN -> {
                if (distance <= radius) {
                    isHolding = true
                    holdStartTime = System.currentTimeMillis()
                    handler.post(progressRunnable)
                    vibrator.vibrate(50)
                    invalidate()
                    return true
                }
            }
            MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                if (isHolding) {
                    isHolding = false
                    progress = 0f
                    handler.removeCallbacks(progressRunnable)
                    Toast.makeText(context, "Hold Reset", Toast.LENGTH_SHORT).show()
                    invalidate()
                }
            }
            MotionEvent.ACTION_MOVE -> {
                if (isHolding && distance > radius) {
                    // Finger moved outside the orb
                    isHolding = false
                    progress = 0f
                    handler.removeCallbacks(progressRunnable)
                    Toast.makeText(context, "Stay inside the orb!", Toast.LENGTH_SHORT).show()
                    invalidate()
                }
            }
        }
        return super.onTouchEvent(event)
    }
}
