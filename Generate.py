#!/usr/bin/python
# -*- coding: UTF-8 -*-

def change_to_list(filename):
    content = open(filename,"r").read().strip()
    return list(content.split("\n"))


def traceroute_to_dict(filename):

    txtfile = open(filename,"r")
    content = txtfile.read().strip().split("\n")[1:]
    d=dict()

    for i in range(len(content)):

        line = content[i]
        if line[1].isdigit():
            if line[4] != "*" :
                latency=line.strip().split("  ")[2]
                asn = line.strip().split("  ")[3]
                route = line.strip().split("  ")[4]
                ip = line.strip().split("  ")[1]
                step = line[0:2]
            else:
                latency="*"
                asn = "*"
                route = "*"
                ip = "*"
                step = line[0:2]

            d[int(step)]=dict()
            d[int(step)]["ip"]=ip
            if int(step) < 3:
                d[int(step)]["ip"]="*.*.*.*(已隐藏)"
            d[int(step)]["latency"]=latency
            d[int(step)]["asn"]=asn
            d[int(step)]["route"]=route


    return dict(d)


def traceroute_to_table(filename):
    d = traceroute_to_dict(filename)
    string = ""
    for i in sorted(d.keys()):
        x = d[i]
        template = """
    <tr>
      <td>{0}</td>
      <td>{1}</td>
      <td>{2}</td>
      <td>{3}</td>
      <td>{4}</td>
    </tr>
    """
    string = string + template.format(i,x["ip"],x["route"],x["asn"],x["latency"]) + "\n"

    writefile = open(filename + "_table","w")
    writefile.write(string)
    writefile.close()


def dict_to_table(d,tab):

    table_class = "ui bottom attached tab segment"
    if tab == "first":
        table_class = table_class + " active"

    table_html = """

<div class="{0}" data-tab="{1}">
<table class="ui very compact striped table">
  <thead>
    <tr><th>跳数</th>
    <th>IP</th>
    <th>路由</th>
    <th>ASN</th>
    <th>延迟</th>
  </tr></thead>
  <tbody>
    """.format(table_class,tab)

    for step in sorted(d.keys()):
        table_html = table_html + """
        <tr>
          <td>{0}</td>
          <td>{1}</td>
          <td>{2}</td>
          <td>{3}</td>
          <td>{4}</td>
        </tr>
        """.format(step,d[step]["ip"],d[step]["route"],d[step]["asn"],d[step]["latency"])

    table_html = table_html + """
  </tbody>
</table>
</div>
    """
    return table_html

html = """
<html>
<head>
    <meta charset="UTF-8" id="home">
    <meta name="keywords" content="Zbench,DesperadoJ,Benchmark,VPS,测评,测试脚本">
    <title>Zbench v1.0 HTML Output</title>
<link rel="stylesheet" type="text/css" href="https://cdn.bootcss.com/semantic-ui/2.4.1/semantic.min.css">
<script src="https://cdn.bootcss.com/jquery/3.4.1/jquery.min.js"></script>
<script src="https://cdn.bootcss.com/semantic-ui/2.4.1/semantic.min.js"></script>
</head>
<body>
<div class="ui attached stackable menu">
  <div class="ui container">
    <a class="item" onclick="javascript:scroller('home', 100);">
      <i class="home icon"></i> 主页
    </a>
    <a class="item" onclick="javascript:scroller('system', 300);">
      <i class="grid layout icon"></i> 系统信息
    </a>
    <a class="item" onclick="javascript:scroller('hdd', 600);">
      <i class="desktop icon"></i> 硬盘 I/O
    </a>
    <a class="item" onclick="javascript:scroller('net', 900);">
      <i class="sitemap icon"></i> 网络测试
    </a>
    <a class="item" onclick="javascript:scroller('route', 1600);">
      <i class="plug icon"></i> 路由追踪
    </a>
    <div class="ui simple dropdown item">
      更多
      <i class="dropdown icon"></i>
      <div class="menu">
        <a class="item" href="https://www.github.com/DesperadoJ"><i class="edit icon"></i> 关于我们</a>
        <a class="item" href="https://github.com/DesperadoJ/ZBench/"><i class="github icon"></i>Github </a>
      </div>
    </div>
    <div class="right item">
      <div class="ui">
            <a href="https://github.com/DesperadoJ/ZBench/">ZBench v1.0</a>
      </div>
    </div>
  </div>
</div>
<div class="ui hidden divider"></div>
<div class="ui hidden divider"></div>
<div class="ui container">
<div class="ui message">
  <div class="header">
    测试数据准确性说明
  </div>
  <p>请注意，所有的测试数据为测试时的实时数据. 我们不保证您的服务商会在日后一直使用保持完全相同的服务。数据仅供参考.</p>
</div>
</div>
<div class="ui hidden divider" id="system"></div>
<h2 class="ui center aligned icon header">
  <i class="circular laptop icon"></i>
  系统信息
</h2>
<div class="ui hidden divider"></div>
<div class="ui container">
<table class="ui celled striped table">
  <thead>
    <tr>
      <th>项目</th>
      <th>数据</th>
  </tr></thead>
  <tbody>
    <tr>
      <td class="collapsing">
        <i class="microchip icon"></i> CPU 型号
      </td>
      <td>{0}</td>
    </tr>
    <tr>
      <td>
        <i class="microchip icon"></i> CPU 核心数
      </td>
      <td>{1}</td>
    </tr>
    <tr>
      <td>
        <i class="microchip icon"></i> CPU 主频
      </td>
      <td>{2}</td>
    </tr>
    <tr>
      <td>
        <i class="hdd icon"></i> 硬盘大小
      </td>
      <td>{3}</td>
    </tr>
    <tr>
      <td>
        <i class="lightning icon"></i> 内存大小
      </td>
      <td>{4}</td>
    </tr>
    <tr>
      <td>
        <i class="database icon"></i> SWAP 交换空间大小
      </td>
      <td>{5}</td>
    </tr>
    <tr>
      <td>
        <i class="bar chart icon"></i> 在线时长
      </td>
      <td>{6}</td>
    </tr>
    <tr>
      <td>
        <i class="pie chart icon"></i> 系统负载
      </td>
      <td>{7}</td>
    </tr>
    <tr>
      <td>
        <i class="linux icon"></i> 系统
      </td>
      <td>{8}</td>
    </tr>
    <tr>
      <td>
        <i class="columns icon"></i> 架构
      </td>
      <td>{9}</td>
    </tr>
    <tr>
      <td>
        <i class="file code outline icon"></i> 内核
      </td>
      <td>{10}</td>
    </tr>
    <tr>
      <td>
        <i class="globe icon"></i> TCP 拥塞控制算法
      </td>
      <td>{11}</td>
    </tr>
    <tr>
      <td>
        <i class="group object icon"></i> 虚拟化技术
      </td>
      <td>{12}</td>
    </tr>
  </tbody>
</table>
</div>
<div class="ui hidden divider" id="hdd"></div>
<h2 class="ui center aligned icon header">
  <i class="circular copy outline icon"></i>
  硬盘 I/O
</h2>
<div class="ui hidden divider"></div>
<div class="ui container">
<table class="ui celled striped table">
  <thead>
    <tr>
      <th>次数</th>
      <th>速度</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class="collapsing">
        <i class="folder icon"></i> 第一次测试
      </td>
      <td>{13}</td>
    </tr>
    <tr>
      <td>
        <i class="folder icon"></i> 第二次测试
      </td>
      <td>{14}</td>
    </tr>
    <tr>
      <td>
        <i class="folder icon"></i> 第三次测试
      </td>
      <td>{15}</td>
    </tr>
  </tbody>
</table>
</div>
<div class="ui hidden divider" id="net"></div>
<h2 class="ui center aligned icon header">
  <i class="circular download icon"></i>
  网络测试
</h2>
<div class="ui hidden divider"></div>
<div class="ui container">
<table class="ui compact striped table">
  <thead>
    <tr>
      <th>节点</th>
      <th>IP 地址</th>
      <th>下载速度</th>
      <th>延迟</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>CacheFly</td>
      <td>{16}</td>
      <td>{17}</td>
      <td>{18}</td>
    </tr>
    <tr>
      <td>Linode 日本 东京</td>
      <td>{19}</td>
      <td>{20}</td>
      <td>{21}</td>
    </tr>
    <tr>
      <td>Linode 新加坡</td>
      <td>{22}</td>
      <td>{23}</td>
      <td>{24}</td>
    </tr>
    <tr>
      <td>Linode 美国 费利蒙</td>
      <td>{25}</td>
      <td>{26}</td>
      <td>{27}</td>
    </tr>
    <tr>
      <td>Linode 英国 伦敦</td>
      <td>{28}</td>
      <td>{29}</td>
      <td>{30}</td>
    </tr>
    <tr>
      <td>Linode 德国 法兰克福</td>
      <td>{31}</td>
      <td>{32}</td>
      <td>{33}</td>
    </tr>
    <tr>
      <td>Softlayer 中国 香港</td>
      <td>{34}</td>
      <td>{35}</td>
      <td>{36}</td>
    </tr>
    <tr>
      <td>Softlayer 新加坡</td>
      <td>{37}</td>
      <td>{38}</td>
      <td>{39}</td>
    </tr>
    <tr>
      <td>Softlayer 美国 达拉斯</td>
      <td>{40}</td>
      <td>{41}</td>
      <td>{42}</td>
    </tr>
    <tr>
      <td>Softlayer 美国 西雅图</td>
      <td>{43}</td>
      <td>{44}</td>
      <td>{45}</td>
    </tr>
    <tr>
      <td>Softlayer 德国 法兰克福</td>
      <td>{46}</td>
      <td>{47}</td>
      <td>{48}</td>
    </tr>
  </tbody>
</table>
</dev>
<div class="ui hidden divider"></div>
<div class="ui container">
<table class="ui compact striped table">
  <thead>
    <tr>
      <th>节点</th>
      <th>上传速度</th>
      <th>下载速度</th>
      <th>延迟</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>广州电信</td>
      <td>{49}</td>
      <td>{50}</td>
      <td>{51}</td>
    </tr>
    <tr>
      <td>上海电信</td>
      <td>{52}</td>
      <td>{53}</td>
      <td>{54}</td>
    </tr>
    <tr>
      <td>武汉电信</td>
      <td>{55}</td>
      <td>{56}</td>
      <td>{57}</td>
    </tr>
    <tr>
      <td>兰州电信</td>
      <td>{58}</td>
      <td>{59}</td>
      <td>{60}</td>
    </tr>
    <tr>
      <td>福州联通</td>
      <td>{61}</td>
      <td>{62}</td>
      <td>{63}</td>
    </tr>
    <tr>
      <td>上海联通</td>
      <td>{64}</td>
      <td>{65}</td>
      <td>{66}</td>
    </tr>
    <tr>
      <td>武汉联通</td>
      <td>{67}</td>
      <td>{68}</td>
      <td>{69}</td>
    </tr>
    <tr>
      <td>天津联通</td>
      <td>{70}</td>
      <td>{71}</td>
      <td>{72}</td>
    </tr>
    <tr>
      <td>深圳移动</td>
      <td>{73}</td>
      <td>{74}</td>
      <td>{75}</td>
    </tr>
    <tr>
      <td>上海移动</td>
      <td>{76}</td>
      <td>{77}</td>
      <td>{78}</td>
    </tr>
    <tr>
      <td>武汉移动</td>
      <td>{79}</td>
      <td>{80}</td>
      <td>{81}</td>
    </tr>
    <tr>
      <td>天津移动</td>
      <td>{82}</td>
      <td>{83}</td>
      <td>{84}</td>
    </tr>
  </tbody>
</table>
</div>
<div class="ui hidden divider" id="route"></div>
<h2 class="ui center aligned icon header">
  <i class="circular map outline icon"></i>
  路由追踪
</h2>
<div class="ui hidden divider"></div>
<div class="ui container">
<div class="ui top attached tabular menu">
  <a class="item active" data-tab="first">北京电信</a>
  <a class="item" data-tab="second">北京联通</a>
  <a class="item" data-tab="third">北京移动</a>
  <a class="item" data-tab="fourth">上海电信</a>
  <a class="item" data-tab="fifth">上海联通</a>
  <a class="item" data-tab="sixth">上海移动</a>
  <a class="item" data-tab="seventh">广东电信</a>
  <a class="item" data-tab="eighth">广东联通</a>
  <a class="item" data-tab="ninth">广东移动</a>
  <a class="item" data-tab="tenth">所在地IP</a>
</div>
"""


footer = """
</div>
</div>
<div class="ui hidden divider"></div>
<div class="ui visible message">
  <p>CopyRight 2016-2019 <a href="https://www.github.com/DesperadoJ">DesperadoJ</a>. All Right Reserved.   Published By <a href="https://www.desperadoj.com">如风</a></p>
</div>
</body>
<footer>
<script type="text/javascript">
// 平滑滚动支持
// 转换为数字
function intval(v)
{
    v = parseInt(v);
    return isNaN(v) ? 0 : v;
}

// 获取元素信息
function getPos(e)
{
    var l = 0;
    var t  = 0;
    var w = intval(e.style.width);
    var h = intval(e.style.height);
    var wb = e.offsetWidth;
    var hb = e.offsetHeight;
    while (e.offsetParent){
        l += e.offsetLeft + (e.currentStyle?intval(e.currentStyle.borderLeftWidth):0);
        t += e.offsetTop  + (e.currentStyle?intval(e.currentStyle.borderTopWidth):0);
        e = e.offsetParent;
    }
    l += e.offsetLeft + (e.currentStyle?intval(e.currentStyle.borderLeftWidth):0);
    t  += e.offsetTop  + (e.currentStyle?intval(e.currentStyle.borderTopWidth):0);
    return {x:l, y:t, w:w, h:h, wb:wb, hb:hb};
}

// 获取滚动条信息
function getScroll()
{
    var t, l, w, h;

    if (document.documentElement && document.documentElement.scrollTop) {
        t = document.documentElement.scrollTop;
        l = document.documentElement.scrollLeft;
        w = document.documentElement.scrollWidth;
        h = document.documentElement.scrollHeight;
    } else if (document.body) {
        t = document.body.scrollTop;
        l = document.body.scrollLeft;
        w = document.body.scrollWidth;
        h = document.body.scrollHeight;
    }
    return { t: t, l: l, w: w, h: h };
}

// 锚点(Anchor)间平滑跳转
function scroller(el, duration)
{
    if(typeof el != 'object') { el = document.getElementById(el); }

    if(!el) return;

    var z = this;
    z.el = el;
    z.p = getPos(el);
    z.s = getScroll();
    z.clear = function(){window.clearInterval(z.timer);z.timer=null};
    z.t=(new Date).getTime();

    z.step = function(){
        var t = (new Date).getTime();
        var p = (t - z.t) / duration;
        if (t >= duration + z.t) {
            z.clear();
            window.setTimeout(function(){z.scroll(z.p.y, z.p.x)},13);
        } else {
            st = ((-Math.cos(p*Math.PI)/2) + 0.5) * (z.p.y-z.s.t) + z.s.t;
            sl = ((-Math.cos(p*Math.PI)/2) + 0.5) * (z.p.x-z.s.l) + z.s.l;
            z.scroll(st, sl);
        }
    };
    z.scroll = function (t, l){window.scrollTo(l, t)};
    z.timer = window.setInterval(function(){z.step();},13);
}
</script>
<script type="text/javascript">
//Tab功能支持
    $('.menu .item')
    .tab()
    ;
//Message工具
$('.message .close')
  .on('click', function() {
    $(this)
      .closest('.message')
      .transition('fade')
    ;
  })
;
//Model
$('.ui.basic.modal')
  .modal('show')
;
</script>
</footer>
</html>
"""

info = change_to_list("/tmp/zbench/info.txt")

speed = change_to_list("/tmp/zbench/speed.txt")

speed_cn = change_to_list("/tmp/zbench/speed_cn.txt")

bjt = traceroute_to_dict("/tmp/zbench/bjt.txt")
traceroute_to_table("/tmp/zbench/bjt.txt")
bjt_html = dict_to_table(bjt,"first")

bju = traceroute_to_dict("/tmp/zbench/bju.txt")
traceroute_to_table("/tmp/zbench/bju.txt")
bju_html = dict_to_table(bju,"second")

bjm = traceroute_to_dict("/tmp/zbench/bjm.txt")
traceroute_to_table("/tmp/zbench/bjm.txt")
bjm_html = dict_to_table(bjm,"third")

sht = traceroute_to_dict("/tmp/zbench/sht.txt")
traceroute_to_table("/tmp/zbench/sht.txt")
sht_html = dict_to_table(sht,"fourth")

shu = traceroute_to_dict("/tmp/zbench/shu.txt")
traceroute_to_table("/tmp/zbench/shu.txt")
shu_html = dict_to_table(shu,"fifth")

shm = traceroute_to_dict("/tmp/zbench/shm.txt")
traceroute_to_table("/tmp/zbench/shm.txt")
shm_html = dict_to_table(shm,"sixth")

gdt = traceroute_to_dict("/tmp/zbench/gdt.txt")
traceroute_to_table("/tmp/zbench/gdt.txt")
gdt_html = dict_to_table(gdt,"seventh")

gdu = traceroute_to_dict("/tmp/zbench/gdu.txt")
traceroute_to_table("/tmp/zbench/gdu.txt")
gdu_html = dict_to_table(gdu,"eighth")

gdm = traceroute_to_dict("/tmp/zbench/gdm.txt")
traceroute_to_table("/tmp/zbench/gdm.txt")
gdm_html = dict_to_table(gdm,"ninth")

own = traceroute_to_dict("/tmp/zbench/own.txt")
traceroute_to_table("/tmp/zbench/own.txt")
own_html = dict_to_table(own,"tenth")

html = html.format(info[0],info[1],info[2],info[3],info[4],info[5],info[6],info[7],info[8],info[9],info[10],info[11],info[12],info[13],info[14],info[15], \

speed[0],speed[1],speed[2],speed[3],speed[4],speed[5],speed[6],speed[7],speed[8],speed[9],speed[10],speed[11],speed[12],speed[13],speed[14],speed[15],speed[16],speed[17],speed[18],speed[19],speed[20],speed[21],speed[22],speed[23],speed[24],speed[25],speed[26],speed[27],speed[28],speed[29],speed[30],speed[31],speed[32],\

speed_cn[0],speed_cn[1],speed_cn[2],speed_cn[3],speed_cn[4],speed_cn[5],speed_cn[6],speed_cn[7],speed_cn[8],speed_cn[9],speed_cn[10],speed_cn[11],speed_cn[12],speed_cn[13],speed_cn[14],speed_cn[15],speed_cn[16],speed_cn[17],speed_cn[18],speed_cn[19],speed_cn[20],speed_cn[21],speed_cn[22],speed_cn[23],speed_cn[24],speed_cn[25],speed_cn[26],speed_cn[27],speed_cn[28],speed_cn[29],speed_cn[30],speed_cn[31],speed_cn[32],speed_cn[33],speed_cn[34],speed_cn[35])

html = html + bjt_html + bju_html + bjm_html + sht_html + shu_html + shm_html + gdt_html + gdu_html + gdm_html + own_html + footer

web = open("/root/report.html","w")

web.write(html)

web.close()
