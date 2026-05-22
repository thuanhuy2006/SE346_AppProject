buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.1")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    val proj = this
    val patchAction = {
        if (proj.name == "speech_to_text") {
            val android = proj.extensions.findByName("android")
            if (android != null) {
                try {
                    val getSourceSetsMethod = android.javaClass.methods.firstOrNull { it.name == "getSourceSets" }
                    val sourceSets = getSourceSetsMethod?.invoke(android)
                    if (sourceSets != null) {
                        val getByNameMethod = sourceSets.javaClass.methods.firstOrNull { 
                            it.name == "getByName" && it.parameterCount == 1 && it.parameterTypes[0] == String::class.java 
                        }
                        val main = getByNameMethod?.invoke(sourceSets, "main")
                        if (main != null) {
                            val getJavaMethod = main.javaClass.methods.firstOrNull { it.name == "getJava" }
                            val java = getJavaMethod?.invoke(main)
                            if (java != null) {
                                val setSrcDirsMethod = java.javaClass.methods.firstOrNull { 
                                    it.name == "setSrcDirs" && it.parameterCount == 1 
                                }
                                setSrcDirsMethod?.invoke(java, listOf("src/main/java"))
                                proj.logger.lifecycle("Successfully patched speech_to_text sourceSets to avoid double Kotlin compilation.")
                            }
                        }
                    }
                } catch (e: Exception) {
                    proj.logger.warn("Failed to patch speech_to_text sourceSets: ${e.message}")
                }
            }
        }
    }

    if (proj.state.executed) {
        patchAction()
    } else {
        proj.afterEvaluate { patchAction() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
