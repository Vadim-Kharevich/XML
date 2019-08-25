using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Xml;
using System.Runtime.InteropServices;

namespace XML
{
    public partial class Form1 : Form
    {
        

        public Form1()
        {
            InitializeComponent();
        }

        public string Filename { get; set; }
        public XmlDocument Document { get; set; }
        public XmlNode Root { get; set; }

        private void открытьФайлToolStripMenuItem_Click(object sender, EventArgs e)
        {
            openFileDialog1.Filter = "XML files(*.xml)|*.xml";
            if (openFileDialog1.ShowDialog() == DialogResult.Cancel)
                return;

            Filename = openFileDialog1.FileName;
            Document = new XmlDocument();
            Document.Load(Filename);
            Root = Document.DocumentElement;
            richTextBox1.Text = PrintItem(Root);
            webBrowser1.Url = new Uri(Filename);

            richTextBox1.Visible = true;
            button2.Visible = true;
            button3.Visible = true;
            button4.Visible = false;
            button5.Visible = false;
        }

        private string PrintItem(XmlNode item, int coltabs = 0, bool IsValue = false)
        {
            string result = "";
            for (int i = 0; i < coltabs; i++)
            {
                result += "\t";
            }
            if (item.Attributes != null)  //вывод узла
            {
                result += item.LocalName;
                foreach (XmlAttribute attr in item.Attributes)
                {
                    result += " [" + attr.Name + "=" + attr.InnerText + "] ";
                }
                foreach (var child in item.ChildNodes)
                {
                    if (child is XmlElement node)
                    {
                        result += "\r\n"+PrintItem(node, coltabs + 1);
                    }
                    if (child is XmlText text)
                    {
                        result += ":" + text.InnerText;
                    }
                }
            }
            else //вывод атрибута
            {
                if (IsValue)
                {
                    foreach (XmlNode child in item.ChildNodes)
                    {
                        result += child.InnerText;
                    }
                }
                else
                {
                    foreach (XmlNode child in item.ChildNodes)
                    {
                        result += "[" + item.Name + "=" + child.InnerText + "]";
                    }
                }
            }
            return result;
        }

        private void ввестиXPathToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (Document != null)
            {
                textBox1.Visible = true;
                button1.Visible = true;
                richTextBox2.Text = "";
                richTextBox2.Visible = true;
                textBox1.Focus();
            }
            else
            {
                MessageBox.Show("Для данной операции необходимо выбрать документ!","Внимание",MessageBoxButtons.OK,MessageBoxIcon.Warning);
            }
        }

        private void button1_Click(object sender, EventArgs e)
        {
            richTextBox2.Text = "";
            try
            {
                XmlNodeList nodeList = Root.SelectNodes(textBox1.Text);
                foreach (XmlNode node in nodeList)
                {
                    if (textBox1.Text.Last() == '*')
                    {
                        richTextBox2.Text += PrintItem(node) + "\r\n";
                    }
                    else
                    {
                        richTextBox2.Text += PrintItem(node, 0, true) + "\r\n";
                    }
                }
                if (richTextBox2.Text == "")
                {
                    richTextBox2.Text = "Запрос не дал результатов.";
                }
            }
            catch
            {
                MessageBox.Show("Вы ввели некорректный запрос!", "Ошибка", MessageBoxButtons.OK, MessageBoxIcon.Error); 
            }
        }

        [DllImport("user32.dll")]
        static extern bool HideCaret(IntPtr hWnd);

        private void richTextBox1_MouseDown(object sender, MouseEventArgs e)
        {
            HideCaret(richTextBox1.Handle);
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            ActiveControl = menuStrip1;
            WindowState = FormWindowState.Maximized;
            HideCaret(richTextBox1.Handle);
        }

        private void richTextBox1_TextChanged(object sender, EventArgs e)
        {
            HideCaret(richTextBox1.Handle);
            ActiveControl = menuStrip1;
        }

        private void button2_Click(object sender, EventArgs e)
        {
            richTextBox1.Visible = true;
            webBrowser1.Visible = false;
        }

        private void button3_Click(object sender, EventArgs e)
        {
            richTextBox1.Visible = false;
            webBrowser1.Visible = true;
        }
    }
}
