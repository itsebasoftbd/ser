<script>
function modalize(title, body)
	{
	    $(".modalize").modal({
            backdrop: 'static',
            keyboard: false  // to prevent closing with Esc button (if you want this too)
        })
        $(".modalize").modal('show');
		$(".modal-title").text(title);
		$(".modal-error").html('');
		$(".modal-html").html(body);
	}
	
function modalMessage(type,title,message){
	$(".modal-body > .modal-error").html('').append('<div class="alert alert-'+type+' alert-has-icon"><div class="alert-icon"><i class="far fa-lightbulb"></i></div><div class="alert-body"><div class="alert-title">'+title+'</div>'+message+'</div></div>').slideDown();
}

function errorMessage(type,title,message){
	$(".errors").html('<div class="alert alert-'+type+' alert-has-icon"><div class="alert-icon"><i class="far fa-lightbulb"></i></div><div class="alert-body"><button class="close" data-dismiss="alert"><span>&times;</span></button><div class="alert-title">'+title+'</div>'+message+'</div></div>').slideDown();
}

function get_permission() {
	$.ajax({
        url: "{$base_url}serverside/data/get_updates.php",
        type: "GET",
        dataType: "JSON",
		cache: false,
        success: function(data)
        {
            if(data.allowinstall == false){
				$(".add-server-alert").removeClass('d-none')
			}else{
				$(".add-server").removeClass('d-none')
			}
        },
        error: function (jqXHR, textStatus, errorThrown)
        {
            swal(`Failed`, `Failed getting data from AJAX.`, `warning`, {
                button: false,
                closeOnClickOutside: false,
                timer: 3000
            }).then(() => {
                location.reload()
            });
        },
        complete: function(){

		}
    });
}

$('document').ready(function()
{

    $.fn.dataTable.ext.errMode = () => swal(`Failed`, `Failed getting data from AJAX.`, `warning`, {
        button: false,
        closeOnClickOutside: false,
        timer: 3000
    }).then(() => {
        location.reload()
    });
	var table = $('.table-listserver').dataTable({
        "bProcessing": true,
        "bServerSide": true,
        "ajax": {
            "url": "/server-serverside",
            "type": "POST"
        },
		"order": [[ 0, "desc" ]],
		"language": {                
                "infoFiltered": ""
            },
		columnDefs: [
    		{ "width": "10%", "targets": 0 },
    		{ "width": "10%", "targets": 1 },
    		{ "width": "10%", "targets": 2 },
    		{ "width": "10%", "targets": 3 },
    		{ "width": "10%", "targets": 4 },
    		{ "orderable": false, "targets": 1 },
    		{ "orderable": false, "targets": 2 },
    		{ "orderable": false, "targets": 3 },
    		{ "orderable": false, "targets": 4 }
  		]
	});
	
	let servertcp = $("#servertcp")
	let serverudp = $("#serverudp")
	let servertype = $("#servertype")

	servertype.change(function (){
		if(servertype.val() === "1" || servertype.val() === "4" || servertype.val() === "8" || servertype.val() === "11"){
			servertcp.prop("readonly", false)
			serverudp.prop("readonly", false)
			servertcp.val('1194')
			serverudp.val('53')
		}else if(servertype.val() === "2" || servertype.val() === "5" || servertype.val() === "9" || servertype.val() === "12"){
			servertcp.prop("readonly", false)
			serverudp.prop("readonly", true)
			servertcp.val('1194')
			serverudp.val('None')
		}else{
			servertcp.prop("readonly", true)
			serverudp.prop("readonly", true)
			servertcp.val('None')
			serverudp.val('None')
		}
	})
	
	var $form = $('.add-server');
	$form.ajaxForm({
		type: "POST",
		url: "{$base_url}serverside/forms/add_server.php",
		data: $form.serialize(),
		dataType: "JSON",
		cache: false,
		beforeSend: function() {
			$(".btn-add-server").addClass("btn-progress")
		},
		success: function(data){
			if(data.response == 1){
    			errorMessage('success', 'Success', data.msg);
    			$(".add-server").trigger("reset");
    			table.DataTable().ajax.reload();
    		}
    		if(data.response == 2){
    			errorMessage('danger','Error', data.msg);
    		}
    		if(data.response == 3){
    			errorMessage('danger','Error', data.errormsg);
    		}
		},
		error: function(jqXHR, textStatus, errorThrown) {
		    gen_user()
			swal(`Failed`, `Failed getting data from AJAX.`, `warning`, {
                button: false,
                closeOnClickOutside: false,
                timer: 3000
            }).then(() => {
                location.reload()
            });
		},
		complete: function(){
			$(".btn-add-server").removeClass("btn-progress")
		}
	});
	
	$(".btn-reset").click(function(){
		$(".add-server").trigger("reset");
	})
	
	//status
	$(".table-listserver").on("click", ".btn-server-stats", function(e)
	{
		let template_html = ''
        let serverip = $(this).data("ip");
        modalize('Statistics', 'Getting information...');
		
        $.ajax({
            url: "{$base_url}serverside/data/get_serverinfo.php",
            data: "server_ip="+serverip,
            type: "GET",
            dataType: "JSON",
    		cache: false,
            success: function(data)
            {
    			if(data.response == 1){
        		    template_html = `<div class="form-group"><input type="text" class="form-control" tabindex="1"  value="`+data.proto+`" readonly></div>
        		                    <div class="form-group"><input type="text" class="form-control" tabindex="1"  value="`+data.ipaddress+`" readonly></div>
        		                    <div class="form-group"><input type="text" class="form-control" tabindex="1"  value="`+data.total_connected+`" readonly></div>
        		                    <div class="form-group"><input type="text" class="form-control" tabindex="1"  value="`+data.bandwidth+`" readonly></div>
        		                    <div class="form-group"><input type="text" class="form-control" tabindex="1"  value="`+data.os+`" readonly></div>
        		                    <div class="form-group"><input type="text" class="form-control" tabindex="1"  value="`+data.distro+`" readonly></div>
        		                    <div class="form-group"><input type="text" class="form-control" tabindex="1"  value="`+data.cpu_model+`" readonly></div>
        		                    <div class="form-group"><input type="text" class="form-control" tabindex="1"  value="`+data.memory+`" readonly></div>
        		                    <div class="form-group"><input type="text" class="form-control" tabindex="1"  value="`+data.disk+`" readonly></div>
        		                    <div class="form-group"><input type="text" class="form-control" tabindex="1"  value="`+data.uptime+`" readonly></div>
        		                    <div class="form-group"><input type="text" class="form-control" tabindex="1"  value="`+data.tcp_status+`" readonly></div>
        		                    <div class="form-group"><input type="text" class="form-control" tabindex="1"  value="`+data.udp_status+`" readonly></div>
        		                    <div class="form-group"><input type="text" class="form-control" tabindex="1"  value="`+data.httpstatus+`" readonly></div>
        		                    <div class="form-group"><input type="text" class="form-control" tabindex="1"  value="`+data.squid3+`" readonly></div>
        		                    <div class="form-group"><input type="text" class="form-control" tabindex="1"  value="`+data.tcpssl+`" readonly></div>
        		                    <div class="form-group"><input type="text" class="form-control" tabindex="1"  value="`+data.udpssl+`" readonly></div>`
    			    modalize('Statistics', template_html);
    			}
    			if(data.response == 2){
    				modalize('Oops...', `<div class="alert alert-danger" role="alert">`+data.msg+`</div>`);
    			}
    			if(data.response == 3){
    				modalize('Oops...', `<div class="alert alert-danger" role="alert">`+data.errormsg+`</div>`);
    			}
            },
            error: function (jqXHR, textStatus, errorThrown)
            {
                swal(`Failed`, `Failed getting data from AJAX.`, `warning`, {
                    button: false,
                    closeOnClickOutside: false,
                    timer: 3000
                }).then(() => {
                    location.reload()
                });
            },
            complete: function(){
    
    		}
        });
	})
	
	//reset
	$(".table-listserver").on("click", ".btn-server-restart", function(e)
	{
		let serverip = $(this).data("ip");
		let servername = $(this).data("name");
		let template_html = `<form class="restartform" autocomplete="off">`
                			+ `<input type="hidden" name="_key" value="{$firenet_encrypt}">`
                			+ `<input type="hidden" name="submitted" value="server_restart">`
                			+ `<input type="hidden" name="serverip" value="`+serverip+`">`
                			+ `<input type="hidden" name="servername" value="`+servername+`">`
                			+ `<p>Are you sure you want to restart server <code>`+servername+`</code> ?</p>`
                			+ `<div class="form-group"><button type="submit" class="btn btn-warning btn-lg btn-block btn-modal" tabindex="4">Restart</button></div>`
                			+ `</form>`;
		modalize('Restart', template_html);
		
		var $form = $('.restartform');
        	$form.ajaxForm({
        		type: "POST",
        		url: "{$base_url}serverside/forms/restart_server.php",
        		data: $form.serialize(),
        		dataType: "JSON",
		        cache: false,
        		beforeSend: function() {
        			$(".btn-modal").addClass("btn-progress");
        		},
        		success: function(data){
        			if(data.response == 1){
    					modalMessage('success', 'Success', data.msg);
    				}
    				if(data.response == 2){
    					modalMessage('danger','Error', data.msg);
    				}
    				if(data.response == 3){
    					modalMessage('danger','Error', data.errormsg);
    				}
        		},
        		error: function(jqXHR, textStatus, errorThrown) {
        			swal(`Failed`, `Failed getting data from AJAX.`, `warning`, {
                        button: false,
                        closeOnClickOutside: false,
                        timer: 3000
                    }).then(() => {
                        location.reload()
                    });
        		},
        		complete: function(){
        		    $(".restartform").remove();
				    $('.table-listserver').DataTable().ajax.reload( null, false );
        		}
        	});
	})
	
	//delete
	$(".table-listserver").on("click", ".btn-server-delete", function(e)
	{
		let serverip = $(this).data("ip");
		let servername = $(this).data("name");
		let template_html = `<form class="deleteform" autocomplete="off">`
                			+ `<input type="hidden" name="_key" value="{$firenet_encrypt}">`
                			+ `<input type="hidden" name="submitted" value="server_delete">`
                			+ `<input type="hidden" name="serverip" value="`+serverip+`">`
                			+ `<input type="hidden" name="servername" value="`+servername+`">`
                			+ `<p>Are you sure you want to delete server <code>`+servername+`</code> ?</p>`
                			+ `<div class="form-group"><button type="submit" class="btn btn-danger btn-lg btn-block btn-modal" tabindex="4">Confirm</button></div>`
                			+ `</form>`;
        modalize('Delete', template_html);
		
		var $form = $('.deleteform');
        	$form.ajaxForm({
        		type: "POST",
        		url: "{$base_url}serverside/forms/delete_server.php",
        		data: $form.serialize(),
        		dataType: "JSON",
		        cache: false,
        		beforeSend: function() {
        			$(".btn-modal").addClass("btn-progress");
        		},
        		success: function(data){
        			if(data.response == 1){
    					modalMessage('success', 'Success', data.msg);
    				}
    				if(data.response == 2){
    					modalMessage('danger','Error', data.msg);
    				}
    				if(data.response == 3){
    					modalMessage('danger','Error', data.errormsg);
    				}
        		},
        		error: function(jqXHR, textStatus, errorThrown) {
        			swal(`Failed`, `Failed getting data from AJAX.`, `warning`, {
                        button: false,
                        closeOnClickOutside: false,
                        timer: 3000
                    }).then(() => {
                        location.reload()
                    });
        		},
        		complete: function(){
        		    $(".deleteform").remove();
				    $('.table-listserver').DataTable().ajax.reload( null, false );
        		}
        	});
	})
	
	$(".btn-vps").on("click", function()
	{
		let template = `
            		<p>Step 1 : Click the buttons below to avail this promos</p>
            		<p>Step 2 : Register as new user to activate this promos!</p>
            		<a href="https://m.do.co/c/b23dca2b7de6" target="_blank" class="btn btn-primary btn-block">Digital Ocean FREE $100 (New User)</a>
            		<a href="https://www.vultr.com/?ref=8824988-6G" target="_blank" class="btn btn-primary btn-block">Vultr FREE $100 (New User)</a>
            		<a href="https://www.vultr.com/?ref=8691668" target="_blank" class="btn btn-primary btn-block">Vultr FREE $25 (New User)</a>
            		<a href="https://hetzner.cloud/?ref=4gAvMLRqQqQv" target="_blank" class="btn btn-primary btn-block">Hetzner FREE €20 (New User)</a>`
        modalize('Vps Promo!', template);
	})
	
	get_permission()
	
	function getD(){
        $.ajax({
            url: "{$base_url}serverside/data/get_data.php",
            type: "GET",
            dataType: "JSON",
        	cache: false,
            success: function(data)
            {
        		if(data.response == 1){
       
                }
                if(data.response == 2){
                	swal(`Error`, data.licmsg, `error`, {
                        button: false,
                        closeOnClickOutside: false,
                        timer: 5000
                    }).then(() => {
                        location.reload()
                    });
                }
                if(data.response == 3){
                	swal(`Error`, data.licmsg, `error`, {
                        button: false,
                        closeOnClickOutside: false,
                        timer: 5000
                    }).then(() => {
                        location.reload()
                    });
                }
            },
            error: function (jqXHR, textStatus, errorThrown)
            {
                swal(`Error`, `Error parsing data.`, `error`, {
                    button: false,
                    closeOnClickOutside: false,
                    timer: 3000
                }).then(() => {
                    location.reload()
                });
            },
            complete: function(){
        
        	}
        });
    }
    getD()
    
    function checkServer(){
        $.ajax({
            url: '{$base_url}serverside/data/check_server.php',
            data: "key={$firenet_encrypt}",
            success: function(data) {
                $('.table-listserver').DataTable().ajax.reload();
            }
        });
    }
    checkServer();
    setInterval(function () {
        checkServer();
    }, 30000);
});
</script>