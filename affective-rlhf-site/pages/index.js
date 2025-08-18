import { useEffect } from "react";
import { motion } from "framer-motion";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, LineChart, Line, PieChart, Pie, Cell } from "recharts";

const chartData = [
  { name: "Cost", Research: 100, Traditional: 300 },
  { name: "Latency", Research: 80, Traditional: 250 },
  { name: "Scalability", Research: 300, Traditional: 150 },
  { name: "Accuracy", Research: 95, Traditional: 75 },
  { name: "Speed", Research: 400, Traditional: 100 },
];

const performanceData = [
  { month: "Jan", Traditional: 65, AffectiveRLHF: 85 },
  { month: "Feb", Traditional: 68, AffectiveRLHF: 88 },
  { month: "Mar", Traditional: 72, AffectiveRLHF: 92 },
  { month: "Apr", Traditional: 75, AffectiveRLHF: 94 },
  { month: "May", Traditional: 78, AffectiveRLHF: 96 },
  { month: "Jun", Traditional: 80, AffectiveRLHF: 98 },
];

const signalData = [
  { name: "EEG", value: 35, color: "#4ade80" },
  { name: "EMG", value: 25, color: "#f87171" },
  { name: "HRV", value: 20, color: "#60a5fa" },
  { name: "Facial", value: 20, color: "#a78bfa" },
];

const teamMembers = [
  {
    name: "Dr. Sarah Chen",
    role: "Chief Research Officer",
    expertise: "Neuroscience & ML",
    image: "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face"
  },
  {
    name: "Dr. Marcus Rodriguez",
    role: "CTO & Co-founder",
    expertise: "Computer Science",
    image: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face"
  },
  {
    name: "Dr. Elena Petrov",
    role: "Head of Biometrics",
    expertise: "Signal Processing",
    image: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face"
  },
  {
    name: "Dr. James Kim",
    role: "Lead ML Engineer",
    expertise: "Deep Learning",
    image: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face"
  }
];

const technologies = [
  { name: "PyTorch", icon: "🔥", description: "Deep Learning Framework" },
  { name: "TensorFlow", icon: "⚡", description: "ML Infrastructure" },
  { name: "OpenBCI", icon: "🧠", description: "EEG Hardware" },
  { name: "OpenCV", icon: "👁️", description: "Computer Vision" },
  { name: "Scikit-learn", icon: "📊", description: "ML Algorithms" },
  { name: "React", icon: "⚛️", description: "Frontend Framework" }
];

export default function AffectiveRLHFHome() {
  useEffect(() => {
    document.title = "Affective RLHF | Next-Gen Human Feedback";
  }, []);

  return (
    <div className="min-h-screen bg-gradient-to-br from-black via-gray-900 to-gray-800 text-white">
      {/* Navigation */}
      <header className="p-6 flex justify-between items-center border-b border-gray-700">
        <div className="flex items-center space-x-4">
          <h1 className="text-3xl font-bold tracking-tight">Affective RLHF</h1>
          <span className="text-sm bg-blue-600 px-2 py-1 rounded">v2.1</span>
        </div>
        <nav className="hidden md:flex space-x-6">
          <a href="#about" className="hover:text-blue-400 transition-colors">About</a>
          <a href="#technology" className="hover:text-blue-400 transition-colors">Technology</a>
          <a href="#team" className="hover:text-blue-400 transition-colors">Team</a>
          <a href="#contact" className="hover:text-blue-400 transition-colors">Contact</a>
        </nav>
        <Button variant="outline" className="text-white border-white hover:bg-white hover:text-black transition-all">Request Demo</Button>
      </header>

      {/* Hero Section */}
      <section className="p-12 text-center relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-r from-blue-600/10 to-purple-600/10"></div>
        <div className="relative z-10">
          <motion.h2 
            initial={{ opacity: 0, y: 50 }} 
            animate={{ opacity: 1, y: 0 }} 
            transition={{ duration: 0.8 }} 
            className="text-6xl font-extrabold mb-6 bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent"
          >
            Reinventing Human Feedback with Biometric Signals
          </motion.h2>
          <p className="text-xl text-gray-300 max-w-4xl mx-auto mb-8 leading-relaxed">
            We bridge the gap between human preference and machine learning with real-time affective signals: 
            EEG, EMG, HRV, and facial micro-expressions. Our approach enables scalable, accurate, and implicit 
            feedback for training reward models.
          </p>
          <div className="flex justify-center space-x-4">
            <Button className="bg-blue-600 hover:bg-blue-700 px-8 py-3 text-lg">Get Started</Button>
            <Button variant="outline" className="px-8 py-3 text-lg">Watch Demo</Button>
          </div>
        </div>
      </section>

      {/* Problem & Solution Cards */}
      <section className="grid md:grid-cols-3 gap-8 p-12">
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}>
          <Card className="h-full">
            <CardContent className="p-8">
              <div className="text-4xl mb-4">💡</div>
              <h3 className="text-2xl font-semibold mb-4">The Problem</h3>
              <p className="text-gray-300 leading-relaxed">
                Human-labeled preference data is time-consuming, expensive, and often noisy. Traditional RLHF 
                pipelines rely heavily on manual ranking, which doesn't scale. Current methods suffer from:
              </p>
              <ul className="mt-4 space-y-2 text-sm text-gray-400">
                <li>• High annotation costs ($50-200 per hour)</li>
                <li>• Subjective human judgments</li>
                <li>• Limited scalability</li>
                <li>• Inconsistent feedback quality</li>
              </ul>
            </CardContent>
          </Card>
        </motion.div>
        
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2 }}>
          <Card className="h-full">
            <CardContent className="p-8">
              <div className="text-4xl mb-4">🧠</div>
              <h3 className="text-2xl font-semibold mb-4">Our Solution</h3>
              <p className="text-gray-300 leading-relaxed">
                We use multimodal biosignals collected during the annotation process to infer implicit feedback 
                and emotional reactions—enabling faster, more authentic training data.
              </p>
              <ul className="mt-4 space-y-2 text-sm text-gray-400">
                <li>• Real-time physiological monitoring</li>
                <li>• Objective biometric measurements</li>
                <li>• Scalable data collection</li>
                <li>• Consistent feedback signals</li>
              </ul>
            </CardContent>
          </Card>
        </motion.div>
        
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.3 }}>
          <Card className="h-full">
            <CardContent className="p-8">
              <div className="text-4xl mb-4">🚀</div>
              <h3 className="text-2xl font-semibold mb-4">The Impact</h3>
              <p className="text-gray-300 leading-relaxed">
                Reduced annotation cost, faster iteration cycles, and more robust reward models with real-time 
                physiological feedback as supervision signals.
              </p>
              <ul className="mt-4 space-y-2 text-sm text-gray-400">
                <li>• 70% cost reduction</li>
                <li>• 5x faster iteration</li>
                <li>• 25% accuracy improvement</li>
                <li>• Unlimited scalability</li>
              </ul>
            </CardContent>
          </Card>
        </motion.div>
      </section>

      {/* Technology Overview */}
      <section id="technology" className="p-12 bg-gray-900">
        <div className="max-w-6xl mx-auto">
          <h3 className="text-4xl font-bold mb-8 text-center">🔬 Technology Stack</h3>
          <div className="grid md:grid-cols-2 gap-12 items-center">
            <div>
              <h4 className="text-2xl font-semibold mb-6">Biometric Signal Processing</h4>
              <div className="space-y-4">
                <div className="flex items-center space-x-4 p-4 bg-gray-800 rounded-lg">
                  <div className="text-2xl">🧠</div>
                  <div>
                    <h5 className="font-semibold">EEG (Electroencephalography)</h5>
                    <p className="text-sm text-gray-400">Brain wave patterns for cognitive load and attention</p>
                  </div>
                </div>
                <div className="flex items-center space-x-4 p-4 bg-gray-800 rounded-lg">
                  <div className="text-2xl">💪</div>
                  <div>
                    <h5 className="font-semibold">EMG (Electromyography)</h5>
                    <p className="text-sm text-gray-400">Muscle activity for stress and engagement levels</p>
                  </div>
                </div>
                <div className="flex items-center space-x-4 p-4 bg-gray-800 rounded-lg">
                  <div className="text-2xl">❤️</div>
                  <div>
                    <h5 className="font-semibold">HRV (Heart Rate Variability)</h5>
                    <p className="text-sm text-gray-400">Autonomic nervous system responses</p>
                  </div>
                </div>
                <div className="flex items-center space-x-4 p-4 bg-gray-800 rounded-lg">
                  <div className="text-2xl">👁️</div>
                  <div>
                    <h5 className="font-semibold">Facial Micro-expressions</h5>
                    <p className="text-sm text-gray-400">Subtle emotional responses and reactions</p>
                  </div>
                </div>
              </div>
            </div>
            <div>
              <div className="bg-gray-800 p-6 rounded-lg">
                <h5 className="text-lg font-semibold mb-4">Signal Distribution</h5>
                <ResponsiveContainer width="100%" height={300}>
                  <PieChart>
                    <Pie
                      data={signalData}
                      cx="50%"
                      cy="50%"
                      outerRadius={80}
                      dataKey="value"
                      label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                    >
                      {signalData.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.color} />
                      ))}
                    </Pie>
                    <Tooltip />
                  </PieChart>
                </ResponsiveContainer>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Benchmark Comparison */}
      <section className="p-12">
        <div className="max-w-6xl mx-auto">
          <h3 className="text-4xl font-bold mb-8 text-center">⚖️ Performance Benchmark</h3>
          <div className="grid md:grid-cols-2 gap-12">
            <div>
              <h4 className="text-2xl font-semibold mb-6">Traditional vs Affective RLHF</h4>
              <ResponsiveContainer width="100%" height={400}>
                <BarChart data={chartData} margin={{ top: 10, right: 30, left: 20, bottom: 5 }}>
                  <XAxis dataKey="name" stroke="#ccc" />
                  <YAxis stroke="#ccc" />
                  <Tooltip />
                  <Bar dataKey="Research" fill="#4ade80" name="Affective RLHF" />
                  <Bar dataKey="Traditional" fill="#f87171" name="Traditional RLHF" />
                </BarChart>
              </ResponsiveContainer>
            </div>
            <div>
              <h4 className="text-2xl font-semibold mb-6">Performance Over Time</h4>
              <ResponsiveContainer width="100%" height={400}>
                <LineChart data={performanceData} margin={{ top: 10, right: 30, left: 20, bottom: 5 }}>
                  <XAxis dataKey="month" stroke="#ccc" />
                  <YAxis stroke="#ccc" />
                  <Tooltip />
                  <Line type="monotone" dataKey="AffectiveRLHF" stroke="#4ade80" strokeWidth={3} />
                  <Line type="monotone" dataKey="Traditional" stroke="#f87171" strokeWidth={3} />
                </LineChart>
              </ResponsiveContainer>
            </div>
          </div>
        </div>
      </section>

      {/* Use Cases */}
      <section className="p-12 bg-gray-950">
        <div className="max-w-6xl mx-auto">
          <h3 className="text-4xl font-bold text-center mb-12">📈 Applications & Use Cases</h3>
          <div className="grid md:grid-cols-3 gap-8">
            <Card>
              <CardContent className="p-8">
                <div className="text-3xl mb-4">🔍</div>
                <h4 className="text-xl font-semibold mb-4">LLM Fine-tuning</h4>
                <p className="text-gray-300 mb-4">
                  Fine-tuning large language models with minimal manual preference data, 
                  using real-time emotional responses to guide model optimization.
                </p>
                <ul className="text-sm text-gray-400 space-y-1">
                  <li>• GPT-4 optimization</li>
                  <li>• Claude fine-tuning</li>
                  <li>• Custom model training</li>
                </ul>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-8">
                <div className="text-3xl mb-4">🎮</div>
                <h4 className="text-xl font-semibold mb-4">Gaming & Entertainment</h4>
                <p className="text-gray-300 mb-4">
                  Adaptive game mechanics using players' real-time emotions to create 
                  personalized and engaging experiences.
                </p>
                <ul className="text-sm text-gray-400 space-y-1">
                  <li>• Dynamic difficulty adjustment</li>
                  <li>• Emotional storytelling</li>
                  <li>• VR/AR experiences</li>
                </ul>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-8">
                <div className="text-3xl mb-4">🧪</div>
                <h4 className="text-xl font-semibold mb-4">Research & Development</h4>
                <p className="text-gray-300 mb-4">
                  Cognitive research and stimulus-response experiments with precise 
                  physiological measurements.
                </p>
                <ul className="text-sm text-gray-400 space-y-1">
                  <li>• Psychology studies</li>
                  <li>• UX research</li>
                  <li>• Clinical trials</li>
                </ul>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Team Section */}
      <section id="team" className="p-12 bg-gray-900">
        <div className="max-w-6xl mx-auto">
          <h3 className="text-4xl font-bold text-center mb-12">👥 Our Team</h3>
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            {teamMembers.map((member, index) => (
              <motion.div
                key={member.name}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.1 }}
              >
                <Card>
                  <CardContent className="p-6 text-center">
                    <img
                      src={member.image}
                      alt={member.name}
                      className="w-24 h-24 rounded-full mx-auto mb-4 object-cover"
                    />
                    <h4 className="font-semibold text-lg">{member.name}</h4>
                    <p className="text-blue-400 text-sm mb-2">{member.role}</p>
                    <p className="text-gray-400 text-xs">{member.expertise}</p>
                  </CardContent>
                </Card>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Technologies Used */}
      <section className="p-12">
        <div className="max-w-6xl mx-auto">
          <h3 className="text-4xl font-bold text-center mb-12">🛠️ Technologies We Use</h3>
          <div className="grid md:grid-cols-3 lg:grid-cols-6 gap-6">
            {technologies.map((tech, index) => (
              <motion.div
                key={tech.name}
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: index * 0.1 }}
              >
                <Card>
                  <CardContent className="p-6 text-center">
                    <div className="text-3xl mb-2">{tech.icon}</div>
                    <h4 className="font-semibold text-sm">{tech.name}</h4>
                    <p className="text-gray-400 text-xs">{tech.description}</p>
                  </CardContent>
                </Card>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Contact Section */}
      <section id="contact" className="p-12 bg-gray-950">
        <div className="max-w-4xl mx-auto text-center">
          <h3 className="text-4xl font-bold mb-8">🚀 Ready to Get Started?</h3>
          <p className="text-xl text-gray-300 mb-8">
            Join the future of human-AI interaction with affective computing technology.
          </p>
          <div className="flex justify-center space-x-4">
            <Button className="bg-blue-600 hover:bg-blue-700 px-8 py-3 text-lg">Request Demo</Button>
            <Button variant="outline" className="px-8 py-3 text-lg">Contact Sales</Button>
          </div>
          <div className="mt-8 grid md:grid-cols-3 gap-8 text-sm">
            <div>
              <h4 className="font-semibold mb-2">📧 Email</h4>
              <p className="text-gray-400">hello@affectiverlhf.ai</p>
            </div>
            <div>
              <h4 className="font-semibold mb-2">📱 Phone</h4>
              <p className="text-gray-400">+1 (555) 123-4567</p>
            </div>
            <div>
              <h4 className="font-semibold mb-2">📍 Location</h4>
              <p className="text-gray-400">San Francisco, CA</p>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="p-8 border-t border-gray-700">
        <div className="max-w-6xl mx-auto">
          <div className="grid md:grid-cols-4 gap-8 mb-8">
            <div>
              <h4 className="font-semibold mb-4">Affective RLHF</h4>
              <p className="text-gray-400 text-sm">
                Pioneering the future of human-AI interaction through biometric signal processing.
              </p>
            </div>
            <div>
              <h4 className="font-semibold mb-4">Product</h4>
              <ul className="text-gray-400 text-sm space-y-2">
                <li>Features</li>
                <li>Pricing</li>
                <li>Documentation</li>
                <li>API Reference</li>
              </ul>
            </div>
            <div>
              <h4 className="font-semibold mb-4">Company</h4>
              <ul className="text-gray-400 text-sm space-y-2">
                <li>About</li>
                <li>Team</li>
                <li>Careers</li>
                <li>Blog</li>
              </ul>
            </div>
            <div>
              <h4 className="font-semibold mb-4">Support</h4>
              <ul className="text-gray-400 text-sm space-y-2">
                <li>Help Center</li>
                <li>Contact</li>
                <li>Status</li>
                <li>Privacy Policy</li>
              </ul>
            </div>
          </div>
          <div className="border-t border-gray-700 pt-8 text-center text-gray-400 text-sm">
            © 2025 AffectiveRLHF.ai — Built with ❤️ for the next generation of AI.
          </div>
        </div>
      </footer>
    </div>
  );
}